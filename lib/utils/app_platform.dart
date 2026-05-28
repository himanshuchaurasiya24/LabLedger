export 'app_platform_base.dart';

import 'app_platform_base.dart';

import 'app_platform_stub.dart'
    if (dart.library.io) 'app_platform_io.dart'
    as platform;

AppPlatform currentAppPlatform() => platform.currentAppPlatformImpl();
