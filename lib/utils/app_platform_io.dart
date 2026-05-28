import 'dart:io';

import 'app_platform_base.dart';

AppPlatform currentAppPlatformImpl() {
  return switch (Platform.operatingSystem) {
    'linux' => AppPlatform.linux,
    'macos' => AppPlatform.macos,
    'windows' => AppPlatform.windows,
    _ => AppPlatform.other,
  };
}
