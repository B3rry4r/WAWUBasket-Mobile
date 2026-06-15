# Android release signing

The release APK/AAB are signed with the **upload keystore**. The keystore file
and its passwords are **never committed** (see `.gitignore`). This document
records only the public certificate fingerprints and the setup steps — no
secrets.

## Keystore facts

| Field | Value |
|-------|-------|
| File (local, gitignored) | `wawubasket-upload-keystore.jks` (repo root) and `android/app/upload-keystore.jks` (used by Gradle) |
| Key alias | `upload` |
| Algorithm | RSA 2048 |
| Owner (DN) | `CN=WAWUBasket, OU=Mobile, O=WAWUAfrica, L=Lagos, ST=Lagos, C=NG` |
| Valid until | 2053-10-31 |

## Certificate fingerprints

Register these with Firebase / Google Cloud / any API that needs the app's
signing certificate (Google Sign-In, Maps, etc.):

```
SHA-1:   99:FF:D2:A9:B3:F7:93:84:AE:BF:2C:D0:44:5B:01:B2:F5:6D:4E:AF
SHA-256: 6D:8D:3B:6F:F4:B3:A8:3B:45:0B:8B:F9:73:31:DC:C3:D0:C3:2A:04:F4:76:14:A2:70:89:0D:FB:35:D4:AB:9A
```

Re-print them anytime with:

```bash
keytool -list -v -keystore wawubasket-upload-keystore.jks -alias upload
```

## What lives where

| Item | Location | Committed? |
|------|----------|------------|
| Keystore | `wawubasket-upload-keystore.jks`, `android/app/upload-keystore.jks` | No — gitignored |
| Local signing config | `android/key.properties` | No — gitignored |
| Gradle wiring | `android/app/build.gradle.kts` (`signingConfigs.release`) | Yes |
| CI keystore step | `.github/workflows/release.yml` | Yes |

## Local release build

`android/key.properties` must exist (gitignored) with:

```properties
storePassword=<store password>
keyPassword=<key password>
keyAlias=upload
storeFile=upload-keystore.jks
```

and `android/app/upload-keystore.jks` must be present. Then:

```bash
flutter build appbundle --release   # signed AAB for Play
flutter build apk --release         # signed APK for sideloading
```

If `key.properties` is absent, release builds fall back to debug signing so
contributor builds still work.

## CI release build

Set these **GitHub repository secrets** (Settings → Secrets and variables →
Actions):

| Secret | Meaning |
|--------|---------|
| `KEYSTORE_BASE64` | `base64 -w0 wawubasket-upload-keystore.jks` output |
| `KEYSTORE_PASSWORD` | store password |
| `KEY_PASSWORD` | key password |
| `KEY_ALIAS` | `upload` |

The **Build & Release** workflow decodes the keystore, writes `key.properties`,
and produces signed APK + AAB. Trigger it by pushing a `v*` tag or running it
manually from the Actions tab.

## ⚠️ Back this up

The keystore is **irreplaceable**. If you lose `wawubasket-upload-keystore.jks`
or its password you can never ship an update to the same Play Store listing
again. Store the `.jks` file and both passwords in a password manager /
encrypted backup you control — not just in this repo (it's gitignored) or the
sandbox.
