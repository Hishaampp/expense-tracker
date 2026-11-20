# Releasing on Google Play

## The upload key (once)

Play bundles are signed with the owner's **upload key**. Every future update must be signed with the same key, so keep it and its password safe and backed up (a password manager, plus a copy of the `.jks` file somewhere private). Never commit it: `.gitignore` excludes `key.properties` and `*.jks`.

1. Create the key, outside the repository (Terminal asks for a password; it never appears on screen):

   ```bash
   mkdir -p ~/ample-keys && keytool -genkeypair -v -keystore ~/ample-keys/ample-upload.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Create `android/key.properties` in the repository (it stays on this Mac only):

   ```properties
   storeFile=/Users/<you>/ample-keys/ample-upload.jks
   storePassword=<the password>
   keyAlias=upload
   keyPassword=<the password>
   ```

Without `key.properties`, `flutter run --release` still works (debug key), but a store bundle refuses to build.

## Building the bundle

```bash
flutter build appbundle --release --flavor play
```

The file is `build/app/outputs/bundle/playRelease/app-play-release.aab`. Check it is signed with the upload key:

```bash
keytool -printcert -jarfile build/app/outputs/bundle/playRelease/app-play-release.aab
```

Upload it to **Internal testing** first. Raise `version:` in `pubspec.yaml` (the number after `+`) for every new upload.

Use the **play** flavor only: it has no SMS permissions. The **sideload** flavor is never uploaded to Play.
