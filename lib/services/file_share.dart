import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Hands files to the system share sheet and picks files to read (spec
/// §13): the user saves a backup to Files, Drive or iCloud themselves. The
/// app never uploads anything.
abstract interface class FileShare {
  /// Writes [bytes] to a temporary file called [name] and opens the share
  /// sheet with it. Returns whether the user shared it.
  Future<bool> share({
    required String name,
    required Uint8List bytes,
    required String mimeType,
  });

  /// Lets the user pick one file and returns its bytes, or null when they
  /// cancel.
  Future<Uint8List?> pick();
}

/// [FileShare] over `share_plus`, `file_picker` and `path_provider`.
class SystemFileShare implements FileShare {
  /// Creates the service.
  const new();

  @override
  Future<bool> share({
    required String name,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    try {
      final result = await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path, mimeType: mimeType)]),
      );
      return result.status == ShareResultStatus.success;
    } finally {
      // The temporary copy goes once the sheet closes.
      if (file.existsSync()) await file.delete();
    }
  }

  @override
  Future<Uint8List?> pick() async {
    final picked = await FilePicker.pickFiles();
    if (picked.isEmpty) return null;
    return await picked.single.readAsBytes();
  }
}
