#!/bin/bash
# =====================================================
# build_deb.sh - Build Flutter Linux app and create .deb
# Dynamic versioning based on DEBIAN/control or .desktop
# =====================================================

set -e

# ---------------------------
# Configuration
# ---------------------------
APP_NAME="labledger"          # internal/binary/package name
DISPLAY_NAME="LabLedger"      # user-facing name
BINARY_NAME="labledger"
DEB_TEMP_DIR="deb_build_tmp"

CONTROL_SRC="linux/deb_files/control"
DESKTOP_SRC="linux/deb_files/${APP_NAME}.desktop"
ICON_SRC="linux/assets/icons/${APP_NAME}.png"
FLUTTER_LINUX_BINARY="build/linux/x64/release/bundle/$BINARY_NAME"

# Required commands
REQUIRED_CMDS=(flutter dpkg-deb)

for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! command -v $cmd &>/dev/null; then
    echo "Error: $cmd is not installed."
    exit 1
  fi
done

# ---------------------------
# Build Flutter Linux binary
# ---------------------------
echo "Building Flutter Linux binary..."
flutter build linux

# ---------------------------
# Check icon exists
# ---------------------------
if [ ! -f "$ICON_SRC" ]; then
  echo "Error: App icon not found at $ICON_SRC"
  exit 1
fi

# ---------------------------
# Prepare temporary DEB build directory
# ---------------------------
rm -rf "$DEB_TEMP_DIR"
mkdir -p "$DEB_TEMP_DIR/usr/local/bin"
mkdir -p "$DEB_TEMP_DIR/usr/share/icons/hicolor/512x512/apps"
mkdir -p "$DEB_TEMP_DIR/usr/share/applications"
mkdir -p "$DEB_TEMP_DIR/DEBIAN"

# ---------------------------
# Copy Linux binary
# ---------------------------
cp "$FLUTTER_LINUX_BINARY" "$DEB_TEMP_DIR/usr/local/bin/"

# ---------------------------
# Copy icon
# ---------------------------
cp "$ICON_SRC" "$DEB_TEMP_DIR/usr/share/icons/hicolor/512x512/apps/"

# ---------------------------
# Copy desktop file
# ---------------------------
if [ -f "$DESKTOP_SRC" ]; then
  cp "$DESKTOP_SRC" "$DEB_TEMP_DIR/usr/share/applications/"
else
  echo "Warning: Desktop file not found. Creating default one."
  cat <<EOL > "$DEB_TEMP_DIR/usr/share/applications/${APP_NAME}.desktop"
[Desktop Entry]
Version=1.0.0
Type=Application
Name=$DISPLAY_NAME
Exec=/usr/local/bin/$BINARY_NAME
Icon=$APP_NAME
Terminal=false
Categories=Utility;
EOL
fi

# ---------------------------
# Copy control file
# ---------------------------
CONTROL_DEST="$DEB_TEMP_DIR/DEBIAN/control"
if [ -f "$CONTROL_SRC" ]; then
  cp "$CONTROL_SRC" "$CONTROL_DEST"
else
  echo "Warning: Control file not found. Creating default one."
  cat <<EOL > "$CONTROL_DEST"
Package: $APP_NAME
Version=1.0.0
Section: utils
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, libglib2.0-0
Maintainer: Himanshu Chaurasiya <himanshuchaurasiya24@gmail.com>
Description: $DISPLAY_NAME - Flutter Linux desktop app
 A simple lab management app built in Flutter.
EOL
fi

# ---------------------------
# Determine version dynamically
# ---------------------------
VERSION=""

# Try to read from control
if grep -iq '^Version:' "$CONTROL_DEST"; then
  VERSION=$(grep -i '^Version:' "$CONTROL_DEST" | awk '{print $2}')
fi

# Fallback: read from .desktop
if [ -z "$VERSION" ]; then
  DESKTOP_FILE="$DEB_TEMP_DIR/usr/share/applications/${APP_NAME}.desktop"
  if grep -iq '^Version=' "$DESKTOP_FILE"; then
    VERSION=$(grep -i '^Version=' "$DESKTOP_FILE" | cut -d= -f2)
  fi
fi

# Default if still empty
if [ -z "$VERSION" ]; then
  VERSION="1.0.0"
  echo "Warning: Could not detect version. Using $VERSION"
fi

# ---------------------------
# Build the .deb package
# ---------------------------
OUTPUT_DEB="${APP_NAME}_${VERSION}_amd64.deb"
dpkg-deb --build --root-owner-group "$DEB_TEMP_DIR" "$OUTPUT_DEB"

echo -e "\n✅ Linux .deb package built successfully: $OUTPUT_DEB"
echo "Old packages are preserved. Versioned builds will not overwrite each other."
