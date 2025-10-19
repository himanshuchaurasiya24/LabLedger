#!/bin/bash
# =====================================================
# build_deb.sh - Build Flutter Linux app and create .deb
#
# This script builds the Flutter application, then packages it into a
# Debian (.deb) file for easy installation on Debian-based Linux
# distributions like Ubuntu.
#
# Version 5 Changes:
# 1. Added single instance check to prevent multiple app instances
# 2. Improved dock icon detection with proper application ID
# 3. Added debugging information for window class
# =====================================================

set -e

# ---------------------------
# Configuration
# ---------------------------
APP_NAME="labledger"          # internal/binary/package name
DISPLAY_NAME="LabLedger"      # user-facing name
BINARY_NAME="labledger"
DEB_TEMP_DIR="deb_build_tmp"
APP_ID="com.labledger.app"    # Unique application ID

# Source file paths
CONTROL_SRC="linux/deb_files/control"
DESKTOP_SRC="linux/deb_files/${APP_NAME}.desktop"
ICON_SRC="linux/assets/icons/${APP_NAME}.png"

# Flutter build output paths
FLUTTER_LINUX_BUILD_DIR="build/linux/x64/release/bundle"
FLUTTER_LINUX_BINARY="$FLUTTER_LINUX_BUILD_DIR/$BINARY_NAME"
FLUTTER_LIB_DIR="$FLUTTER_LINUX_BUILD_DIR/lib"

# ---------------------------
# Pre-flight Checks
# ---------------------------
# Check for required commands
REQUIRED_CMDS=(flutter dpkg-deb)
for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! command -v $cmd &>/dev/null; then
    echo "Error: Required command '$cmd' is not installed. Please install it to continue."
    exit 1
  fi
done

# ---------------------------
# Build Flutter Linux Binary
# ---------------------------
echo "Building Flutter Linux binary..."
flutter build linux --release

# Check that the build was successful
if [ ! -d "$FLUTTER_LINUX_BUILD_DIR" ]; then
    echo "Error: Flutter build failed. Directory not found: $FLUTTER_LINUX_BUILD_DIR"
    exit 1
fi

# Check that the icon exists
if [ ! -f "$ICON_SRC" ]; then
  echo "Error: App icon not found at $ICON_SRC"
  exit 1
fi

# ---------------------------
# Prepare DEB Build Directory
# ---------------------------
echo "Preparing build directory..."
rm -rf "$DEB_TEMP_DIR"
mkdir -p "$DEB_TEMP_DIR/usr/local/lib/$APP_NAME/lib"
mkdir -p "$DEB_TEMP_DIR/usr/local/bin"
mkdir -p "$DEB_TEMP_DIR/usr/share/icons/hicolor/512x512/apps"
mkdir -p "$DEB_TEMP_DIR/usr/share/applications"
mkdir -p "$DEB_TEMP_DIR/DEBIAN"

# ---------------------------
# Copy Application Files
# ---------------------------
echo "Copying application files..."
# Executable binary
cp "$FLUTTER_LINUX_BINARY" "$DEB_TEMP_DIR/usr/local/lib/$APP_NAME/"

# Plugin shared libraries (.so files)
cp "$FLUTTER_LIB_DIR"/*.so "$DEB_TEMP_DIR/usr/local/lib/$APP_NAME/lib/" || true

# Flutter assets (the 'data' directory)
cp -r "$FLUTTER_LINUX_BUILD_DIR/data" "$DEB_TEMP_DIR/usr/local/lib/$APP_NAME/"

# ---------------------------
# Create Executable Wrapper Script with Single Instance Check
# ---------------------------
echo "Creating executable wrapper script with single instance protection..."
WRAPPER_SCRIPT_PATH="$DEB_TEMP_DIR/usr/local/bin/$BINARY_NAME"

INSTALL_DIR="/usr/local/lib/$APP_NAME"
LIB_DIR="$INSTALL_DIR/lib"

cat <<'EOL' > "$WRAPPER_SCRIPT_PATH"
#!/bin/bash
# Wrapper script to run the main application with single instance check.
INSTALL_DIR="/usr/local/lib/labledger"
LIB_DIR="$INSTALL_DIR/lib"
BINARY_NAME="labledger"
LOCK_FILE="/tmp/labledger.lock"

# Single instance check using flock
exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    echo "LabLedger is already running. Bringing existing window to front..."
    
    # Try to focus the existing window
    if command -v wmctrl &>/dev/null; then
        wmctrl -a "LabLedger" 2>/dev/null || wmctrl -a "labledger" 2>/dev/null
    elif command -v xdotool &>/dev/null; then
        xdotool search --name "LabLedger" windowactivate 2>/dev/null || \
        xdotool search --name "labledger" windowactivate 2>/dev/null
    fi
    
    exit 0
fi

# Explicitly tell the dynamic linker where to find all .so files.
export LD_LIBRARY_PATH="$LIB_DIR:$INSTALL_DIR:$LD_LIBRARY_PATH"

# Change to the main application directory so the executable can find
# the 'data' directory (containing AOT snapshot and assets).
cd "$INSTALL_DIR"

# Execute the binary, passing along any command-line arguments.
exec "./$BINARY_NAME" "$@"
EOL

# Make the wrapper script executable
chmod +x "$WRAPPER_SCRIPT_PATH"


# ---------------------------
# Copy Icon and Desktop File
# ---------------------------
echo "Copying icon..."
cp "$ICON_SRC" "$DEB_TEMP_DIR/usr/share/icons/hicolor/512x512/apps/"

# Also copy to other common sizes for better compatibility
for size in 16 32 48 64 128 256; do
  mkdir -p "$DEB_TEMP_DIR/usr/share/icons/hicolor/${size}x${size}/apps"
  cp "$ICON_SRC" "$DEB_TEMP_DIR/usr/share/icons/hicolor/${size}x${size}/apps/" 2>/dev/null || true
done

echo "Creating .desktop file..."
DESKTOP_FILE="$DEB_TEMP_DIR/usr/share/applications/${APP_NAME}.desktop"

if [ -f "$DESKTOP_SRC" ]; then
  cp "$DESKTOP_SRC" "$DESKTOP_FILE"
else
  echo "Warning: Desktop file not found. Creating a default one."
  cat <<EOL > "$DESKTOP_FILE"
[Desktop Entry]
Version=1.0.0
Type=Application
Name=$DISPLAY_NAME
Exec=$BINARY_NAME
Icon=$APP_NAME
Terminal=false
Categories=Office;Utility;
Comment=Medical Records Made Simple
StartupWMClass=$APP_NAME
StartupNotify=true
EOL
fi

# Ensure StartupWMClass is set correctly
if ! grep -q "^StartupWMClass=" "$DESKTOP_FILE"; then
  echo "Adding StartupWMClass to desktop file..."
  echo "StartupWMClass=$BINARY_NAME" >> "$DESKTOP_FILE"
else
  # Update existing StartupWMClass to ensure it matches
  sed -i "s/^StartupWMClass=.*/StartupWMClass=$BINARY_NAME/" "$DESKTOP_FILE"
fi

# Ensure StartupNotify is enabled
if ! grep -q "^StartupNotify=" "$DESKTOP_FILE"; then
  echo "StartupNotify=true" >> "$DESKTOP_FILE"
fi

# ---------------------------
# Create DEBIAN/control File
# ---------------------------
echo "Creating DEBIAN control file..."
CONTROL_DEST="$DEB_TEMP_DIR/DEBIAN/control"
if [ -f "$CONTROL_SRC" ]; then
  cp "$CONTROL_SRC" "$CONTROL_DEST"
else
  echo "Warning: Control file not found. Creating a default one."
  cat <<EOL > "$CONTROL_DEST"
Package: $APP_NAME
Version: 1.0.0
Section: utils
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, libglib2.0-0
Recommends: wmctrl
Maintainer: Your Name <your.email@example.com>
Description: $DISPLAY_NAME - Medical Records Made Simple
 A Flutter-based application for managing medical records.
 This package includes single instance protection.
EOL
fi

# ---------------------------
# Create postinst script to update icon cache
# ---------------------------
echo "Creating postinst script..."
cat <<'EOL' > "$DEB_TEMP_DIR/DEBIAN/postinst"
#!/bin/bash
set -e

# Update icon cache
if command -v gtk-update-icon-cache &>/dev/null; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor/ 2>/dev/null || true
fi

# Update desktop database
if command -v update-desktop-database &>/dev/null; then
    update-desktop-database /usr/share/applications 2>/dev/null || true
fi

exit 0
EOL

chmod +x "$DEB_TEMP_DIR/DEBIAN/postinst"

# ---------------------------
# Determine Version for Package Name
# ---------------------------
VERSION=""
# Try to read version from control file
if grep -iq '^Version:' "$CONTROL_DEST"; then
  VERSION=$(grep -i '^Version:' "$CONTROL_DEST" | awk '{print $2}')
fi
# Fallback: read from .desktop file
if [ -z "$VERSION" ]; then
  if grep -iq '^Version=' "$DESKTOP_FILE"; then
    VERSION=$(grep -i '^Version=' "$DESKTOP_FILE" | cut -d= -f2)
  fi
fi
# Default if still empty
if [ -z "$VERSION" ]; then
  VERSION="1.0.0"
  echo "Warning: Could not detect version. Using default: $VERSION"
fi
echo "Using version: $VERSION"

# ---------------------------
# Build the .deb Package
# ---------------------------
OUTPUT_DEB="${DISPLAY_NAME}_v${VERSION}_amd64.deb"
echo "Building package '$OUTPUT_DEB'..."
dpkg-deb --build --root-owner-group "$DEB_TEMP_DIR" "$OUTPUT_DEB"

echo -e "\n✅ Linux .deb package built successfully: $OUTPUT_DEB"
echo ""
echo "Installation instructions:"
echo "  sudo dpkg -i $OUTPUT_DEB && sudo apt-get -f install"
echo ""
echo "📝 Features included:"
echo "  ✓ Single instance protection (prevents multiple app instances)"
echo "  ✓ Automatic icon cache update on install"
echo "  ✓ Dock icon support"
echo ""
echo "🔍 If dock icon still doesn't show, check the window class after launching:"
echo "  xprop WM_CLASS"
echo "  (Click on the app window when cursor changes)"