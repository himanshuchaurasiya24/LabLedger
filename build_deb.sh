#!/usr/bin/env bash

set -euo pipefail

# -------- Package configuration (edit these values when needed) --------
APP_NAME="labledger"
DISPLAY_NAME="LabLedger"
VERSION="2.0.0"
MAINTAINER="LabLedger Team <himanshuchaurasiya24@gmail.com>"
DESCRIPTION="Medical Records Made Simple"
# ----------------------------------------------------------------------

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_DIR="${ROOT_DIR}/build/linux/x64/release/bundle"
DEB_STAGING_DIR="${ROOT_DIR}/build/deb_pkg"
DEB_OUTPUT_DIR="${ROOT_DIR}/build/deb"
INSTALL_DIR="/opt/${APP_NAME}"
ICON_SOURCE="${ROOT_DIR}/assets/images/app_icon.png"
ARCH="$(dpkg --print-architecture)"
DEB_NAME="${APP_NAME}_${VERSION}_${ARCH}.deb"

echo "[1/4] Running flutter clean..."
cd "${ROOT_DIR}"
flutter clean

echo "[2/4] Building Linux release bundle..."
flutter build linux --release --obfuscate --split-debug-info=build/linux/symbols

if [[ ! -d "${BUNDLE_DIR}" ]]; then
  echo "Build bundle not found at: ${BUNDLE_DIR}"
  exit 1
fi

echo "[3/4] Preparing Debian package structure..."
rm -rf "${DEB_STAGING_DIR}"
mkdir -p "${DEB_STAGING_DIR}/DEBIAN"
mkdir -p "${DEB_STAGING_DIR}${INSTALL_DIR}"
mkdir -p "${DEB_STAGING_DIR}/usr/bin"
mkdir -p "${DEB_STAGING_DIR}/usr/share/applications"
mkdir -p "${DEB_STAGING_DIR}/usr/share/icons/hicolor/256x256/apps"

cp -a "${BUNDLE_DIR}/." "${DEB_STAGING_DIR}${INSTALL_DIR}/"

cat > "${DEB_STAGING_DIR}/usr/bin/${APP_NAME}" <<EOF
#!/usr/bin/env bash
exec "${INSTALL_DIR}/${APP_NAME}" "\$@"
EOF
chmod 755 "${DEB_STAGING_DIR}/usr/bin/${APP_NAME}"

cat > "${DEB_STAGING_DIR}/usr/share/applications/${APP_NAME}.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=${DISPLAY_NAME}
Comment=${DESCRIPTION}
Exec=/usr/bin/${APP_NAME}
Icon=${APP_NAME}
Terminal=false
Categories=Office;Utility;
EOF
chmod 644 "${DEB_STAGING_DIR}/usr/share/applications/${APP_NAME}.desktop"

if [[ -f "${ICON_SOURCE}" ]]; then
  cp "${ICON_SOURCE}" "${DEB_STAGING_DIR}/usr/share/icons/hicolor/256x256/apps/${APP_NAME}.png"
else
  echo "Warning: icon file not found at ${ICON_SOURCE}; package will still be built."
fi

INSTALLED_SIZE="$(du -sk "${DEB_STAGING_DIR}" | awk '{print $1}')"

cat > "${DEB_STAGING_DIR}/DEBIAN/control" <<EOF
Package: ${APP_NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Maintainer: ${MAINTAINER}
Installed-Size: ${INSTALLED_SIZE}
Depends: libc6, libstdc++6, libgtk-3-0
Description: ${DESCRIPTION}
EOF
chmod 644 "${DEB_STAGING_DIR}/DEBIAN/control"

echo "[4/4] Building .deb package..."
mkdir -p "${DEB_OUTPUT_DIR}"
dpkg-deb --build --root-owner-group "${DEB_STAGING_DIR}" "${DEB_OUTPUT_DIR}/${DEB_NAME}"

echo "Done: ${DEB_OUTPUT_DIR}/${DEB_NAME}"