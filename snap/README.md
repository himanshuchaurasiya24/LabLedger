# Building LabLedger Snap Package

This guide explains how to build the LabLedger snap package.

## Prerequisites

Install snapcraft:
```bash
sudo snap install snapcraft --classic
```

## Building the Snap

### Option 1: Build Locally (Recommended for Testing)

From the project root directory:
```bash
snapcraft
```

This will:
- Read the version from `pubspec.yaml` automatically
- Use the description from the snapcraft.yaml
- Include the app icon from `assets/images/app_icon.png`
- Build a complete snap package

### Option 2: Build in a Clean Environment

For production builds, use a clean container:
```bash
snapcraft --use-lxd
```

Or with multipass:
```bash
snapcraft --use-multipass
```

## Installing the Built Snap

After building, you'll have a `.snap` file in the current directory.

### Install Locally
```bash
sudo snap install --dangerous labledger_*.snap
```

### Install with Devmode (for debugging)
```bash
sudo snap install --dangerous --devmode labledger_*.snap
```

## Running the Application

After installation:
```bash
labledger
```

Or launch from your application menu.

## Version Management

The snap version is automatically read from `pubspec.yaml` using the `parse-info` feature.

To update the version:
1. Edit the `version` field in `pubspec.yaml`
2. Rebuild the snap

Example:
```yaml
# pubspec.yaml
version: 1.0.1+2  # Change this
```

## Snap Configuration Details

### Version Source
- **Source**: `pubspec.yaml` (line 5)
- **Method**: `parse-info` feature in snapcraft
- **Single Source of Truth**: ✅ Same as Flutter app

### Description
- **Source**: Defined in `snapcraft.yaml`
- **Value**: "Medical Records Made Simple" (from constants.dart)

### Icon
- **Source**: `assets/images/app_icon.png`
- **Copy**: Also placed in `snap/gui/icon.png`

## Troubleshooting

### Build Fails
```bash
# Clean and retry
snapcraft clean
snapcraft
```

### Version Not Detected
Ensure `parse-info: [pubspec.yaml]` is present in the `labledger` part of `snapcraft.yaml`.

### Icon Not Showing
The icon is embedded in the snap. Check:
```bash
unsquashfs -l labledger_*.snap | grep icon
```

## Publishing to Snap Store

1. **Create a Snap Store account**: https://snapcraft.io/account
2. **Register the name**:
   ```bash
   snapcraft register labledger
   ```
3. **Build and upload**:
   ```bash
   snapcraft
   snapcraft upload labledger_*.snap
   ```
4. **Release to a channel**:
   ```bash
   snapcraft release labledger <revision> stable
   ```

## Architecture Support

Currently configured for:
- **amd64** (x86_64)

To add more architectures, edit `snapcraft.yaml`:
```yaml
architectures:
  - build-on: amd64
  - build-on: arm64
  - build-on: armhf
```

## Confinement

- **Current**: `strict` (recommended for store)
- **For development**: Change to `devmode` in `snapcraft.yaml` if needed

## File Structure

```
snap/
├── snapcraft.yaml       # Main snap configuration
└── gui/
    ├── labledger.desktop  # Desktop entry
    └── icon.png          # Application icon
```

## Clean Up

To remove build artifacts:
```bash
snapcraft clean
```

To remove the snap parts cache:
```bash
snapcraft clean --use-lxd
```
