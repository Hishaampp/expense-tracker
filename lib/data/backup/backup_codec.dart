import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:expense_tracker/core/failure.dart';
import 'package:expense_tracker/core/result.dart';
import 'package:expense_tracker/data/db/app_database.dart';
import 'package:meta/meta.dart';
import 'package:sqlite3/common.dart';

/// What a restore brought back.
typedef RestoreReport = ({int transactions, int rooms});

/// Encrypted backup files (spec §13): every table as JSON, gzipped, then
/// sealed with AES-256-GCM under a key derived from the user's password
/// with PBKDF2-HMAC-SHA256. Without the password the file is unreadable;
/// a changed byte fails authentication.
class BackupCodec {
  /// Creates the codec. [iterations] is lowered only in tests.
  new(
    this._db, {
    this.iterations = defaultIterations,
    Random? random,
    @visibleForTesting int? schemaVersion,
  }) : _random = random ?? Random.secure(),
       _schema = schemaVersion ?? _db.schemaVersion;

  final int _schema;

  final AppDatabase _db;
  final Random _random;

  /// PBKDF2 rounds: OWASP's 2023 figure for HMAC-SHA256.
  static const int defaultIterations = 600000;

  /// Shortest password accepted.
  static const int minPasswordLength = 8;

  /// What every backup file starts with.
  static const String format = 'expenses-backup-v1';

  /// Tables in the order a restore inserts them (parents first).
  @visibleForTesting
  static const List<String> tables = [
    'accounts',
    'categories',
    'rooms',
    'transactions',
    'raw_captures',
    'transaction_sources',
    'unparsed',
    'budgets',
    'payee_rules',
    'fired_alerts',
    'notices',
    'settings',
  ];

  static final AesGcm _cipher = AesGcm.with256bits();

  Pbkdf2 get _kdf =>
      Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: iterations, bits: 256);

  /// The PBKDF2 rounds used for new backups.
  final int iterations;

  /// The whole database, sealed with [password], as file bytes.
  Future<Result<Uint8List, BackupFailure>> export(String password) async {
    try {
      final data = <String, Object?>{};
      for (final table in tables) {
        final rows = await _db.customSelect('SELECT * FROM $table').get();
        data[table] = [for (final row in rows) row.data];
      }
      final plain = GZipCodec().encode(
        utf8.encode(jsonEncode({'schema': _schema, 'tables': data})),
      );
      final salt = _bytes(16);
      final key = await _kdf.deriveKeyFromPassword(
        password: password,
        nonce: salt,
      );
      final box = await _cipher.encrypt(
        plain,
        secretKey: key,
        nonce: _bytes(12),
      );
      final file = jsonEncode({
        'format': format,
        'kdf': 'pbkdf2-hmac-sha256',
        'iterations': iterations,
        'salt': base64.encode(salt),
        'nonce': base64.encode(box.nonce),
        'mac': base64.encode(box.mac.bytes),
        'data': base64.encode(box.cipherText),
      });
      return Ok(Uint8List.fromList(utf8.encode(file)));
    } on SqliteException {
      return const Err(BackupFileFailed());
    }
  }

  /// Replaces everything in the database with the backup in [bytes],
  /// opened with [password], in one transaction: on any failure nothing
  /// changes.
  Future<Result<RestoreReport, BackupFailure>> restore(
    Uint8List bytes,
    String password,
  ) async {
    final Object? header;
    try {
      header = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      return const Err(BackupNotABackup());
    }
    if (header case {
      'format': BackupCodec.format,
      'iterations': final int rounds,
      'salt': final String salt,
      'nonce': final String nonce,
      'mac': final String mac,
      'data': final String sealed,
    }) {
      final Object? decoded;
      try {
        final key = await Pbkdf2(
          macAlgorithm: Hmac.sha256(),
          iterations: rounds,
          bits: 256,
        ).deriveKeyFromPassword(password: password, nonce: base64.decode(salt));
        final plain = await _cipher.decrypt(
          SecretBox(
            base64.decode(sealed),
            nonce: base64.decode(nonce),
            mac: Mac(base64.decode(mac)),
          ),
          secretKey: key,
        );
        decoded = jsonDecode(utf8.decode(GZipCodec().decode(plain)));
      } on SecretBoxAuthenticationError {
        return const Err(BackupWrongPassword());
      } on FormatException {
        return const Err(BackupNotABackup());
      }
      if (decoded is! Map<String, Object?>) {
        return const Err(BackupNotABackup());
      }
      return await _replace(decoded);
    }
    return const Err(BackupNotABackup());
  }

  Future<Result<RestoreReport, BackupFailure>> _replace(
    Map<String, Object?> content,
  ) async {
    final schema = content['schema'];
    if (schema is! int || schema > _schema) {
      return const Err(BackupTooNew());
    }
    final data = content['tables'];
    if (data is! Map<String, Object?>) return const Err(BackupNotABackup());

    try {
      await _db.transaction(() async {
        for (final table in tables.reversed) {
          await _db.customStatement('DELETE FROM $table');
        }
        for (final table in tables) {
          final rows = data[table];
          if (rows is! List) continue;
          for (final row in rows.cast<Map<String, Object?>>()) {
            final columns = row.keys.toList();
            await _db.customInsert(
              'INSERT INTO $table (${columns.join(', ')}) '
              'VALUES (${List.filled(columns.length, '?').join(', ')})',
              variables: [for (final c in columns) Variable<Object>(row[c])],
            );
          }
        }
      });
    } on SqliteException {
      return const Err(BackupNotABackup());
    }
    // Every screen re-reads what it shows.
    _db.notifyUpdates({
      for (final table in _db.allTables)
        TableUpdate.onTable(table, kind: UpdateKind.insert),
    });
    int count(String table) => switch (data[table]) {
      final List<Object?> rows => rows.length,
      _ => 0,
    };
    return Ok((transactions: count('transactions'), rooms: count('rooms')));
  }

  Uint8List _bytes(int length) => Uint8List.fromList([
    for (var i = 0; i < length; i++) _random.nextInt(256),
  ]);
}
