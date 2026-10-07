# Android build and release

> **Status: configured, not yet built or device-tested.** The export presets in `export_presets.cfg` follow Godot 4.3 conventions but have not been exercised, because the Android SDK and export templates were not available in the environment that created them. Treat the first real export as a verification step.

## One-time setup (on a machine with Godot 4.3 and Android tooling)

1. Install JDK 17 and the Android SDK (platform-tools, build-tools 34, platform 34, CMake and NDK as Godot 4.3 documents).
2. In Godot: Editor > Editor Settings > Export > Android, set the SDK path and JDK path.
3. Install the 4.3 export templates (Editor > Manage Export Templates).
4. For the AAB preset, install the Android build template: Project > Install Android Build Template.

## Presets

| Preset | Output | Use |
| --- | --- | --- |
| `Android APK (testing)` | `build/the-archive.apk` | Debug-signed APK for device testing |
| `Android AAB (release)` | `build/the-archive.aab` | Gradle-built App Bundle for Play distribution |

Tests, tools and docs are excluded from exports; shipped content in `content/` is included.

## Commands

```bash
mkdir -p build
godot --headless --path . --export-debug   "Android APK (testing)" build/the-archive.apk
godot --headless --path . --export-release "Android AAB (release)" build/the-archive.aab
```

## Signing: never commit credentials

The presets contain **no** keystore paths or passwords. Provide release signing through environment variables that Godot reads:

```bash
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH=/secure/location/release.keystore
export GODOT_ANDROID_KEYSTORE_RELEASE_USER=<alias>
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD=<password>
```

Keep the keystore outside the repository. `*.keystore`, `*.jks` and `.env` are git-ignored. In CI, store these as encrypted secrets and never echo them.

## Device test checklist (not yet performed)

- Install the APK on a mid-range device; confirm cold start and autosave restore after being killed
- Home button / app switch: confirm autosave on pause and restore on return
- Back button behaviour
- Rotation and notch/cutout safe areas
- UI scaling across small and large screens
- Memory and frame time over a long session
- Saves survive an app update
- Downloaded pack under `user://packs/` loads and a corrupt one is rejected
