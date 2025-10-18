#!/bin/bash
# =====================================================
# build_deb.sh - Build Flutter Linux app and create .deb
#
# This script builds the Flutter application, then packages it into a
# Debian (.deb) file for easy installation on Debian-based Linux
# distributions like Ubuntu.
#
# Version 3 Changes:
# 1. Improved the wrapper script to be more robust. It now changes
#    directory to the application's location before running. This ensures
#    both shared libraries (.so files) and Flutter assets (the 'data'
#    directory) are found correctly by the executable at runtime.
# =====================================================

set -e

# ---------------------------
# Configuration
# ---------------------------
APP_NAME="labledger"          # internal/binary/package name
DISPLAY_NAME="LabLedger"      # user-facing name
BINARY_NAME="labledger"
DEB_TEMP_DIR="deb_build_tmp"

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
mkdir -p "$DEB_TEMP_DIR/usr/local/lib/$APP_NAME/lib" # MODIFIED: Create a 'lib' subdir
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
cp "$FLUTTER_LIB_DIR"/*.so "$DEB_TEMP_DIR/usr/local/lib/$APP_NAME/lib/" || true # MODIFIED: Copy to 'lib' subdir

# Flutter assets (the 'data' directory)
cp -r "$FLUTTER_LINUX_BUILD_DIR/data" "$DEB_TEMP_DIR/usr/local/lib/$APP_NAME/"

# ---------------------------
# Create Executable Wrapper Script (ROBUST FIX)
# ---------------------------
echo "Creating executable wrapper script..."
WRAPPER_SCRIPT_PATH="$DEB_TEMP_DIR/usr/local/bin/$BINARY_NAME"

INSTALL_DIR="/usr/local/lib/$APP_NAME"
LIB_DIR="$INSTALL_DIR/lib"

# MODIFIED: This new wrapper is more robust.
# 1. It explicitly sets LD_LIBRARY_PATH to the new lib directory.
# 2. It changes the working directory so the app can find the 'data' folder.
cat <<EOL > "$WRAPPER_SCRIPT_PATH"
#!/bin/bash
# Wrapper script to run the main application.
INSTALL_DIR="$INSTALL_DIR"
LIB_DIR="$LIB_DIR"

# Explicitly tell the dynamic linker where to find all .so files.
export LD_LIBRARY_PATH="\$LIB_DIR:\$INSTALL_DIR:\$LD_LIBRARY_PATH"

# Change to the main application directory so the executable can find
# the 'data' directory (containing AOT snapshot and assets).
# This is the crucial step to fix the 'Invalid ELF path' error.
cd "\$INSTALL_DIR"

# Execute the binary, passing along any command-line arguments.
exec "./$BINARY_NAME" "\$@"
EOL

# Make the wrapper script executable
chmod +x "$WRAPPER_SCRIPT_PATH"


# ---------------------------
# Copy Icon and Desktop File
# ---------------------------
echo "Copying icon..."
cp "$ICON_SRC" "$DEB_TEMP_DIR/usr/share/icons/hicolor/512x512/apps/"

echo "Copying .desktop file..."
if [ -f "$DESKTOP_SRC" ]; then
  cp "$DESKTOP_SRC" "$DEB_TEMP_DIR/usr/share/applications/"
else
  echo "Warning: Desktop file not found. Creating a default one."
  cat <<EOL > "$DEB_TEMP_DIR/usr/share/applications/${APP_NAME}.desktop"
[Desktop Entry]
Version=1.0.0
Type=Application
Name=$DISPLAY_NAME
Exec=$BINARY_NAME
Icon=$APP_NAME
Terminal=false
Categories=Utility;
EOL
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
Maintainer: Your Name <your.email@example.com>
Description: $DISPLAY_NAME - Medical Records Made Simple
EOL
fi

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
  DESKTOP_FILE="$DEB_TEMP_DIR/usr/share/applications/${APP_NAME}.desktop"
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
echo "You can now install it with: sudo dpkg -i $OUTPUT_DEB && sudo apt-get -f install"


