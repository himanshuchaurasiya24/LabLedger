import 'package:package_info_plus/package_info_plus.dart';

const appName = 'LabLedger';
const appDescription = 'Medical Records Made Simple';
const double tinyPadding = 6;
const double minimalPadding = 4;
const double smallPadding = 8;
const double defaultPadding = 12;
const double mediumPadding = 16;
const double largePadding = 20;
const double xlargePadding = 24;

const double tinyRadius = 4;
const double minimalBorderRadius = 6;
const double smallRadius = 8;
const double defaultRadius = 12;
const double mediumRadius = 16;
const double largeRadius = 20;

const double defaultHeight = 20;
const double defaultWidth = 20;
const double initialWindowWidth = 1600;
const double initialWindowHeight = 900;

const double tintedContainerHeight = 304;

const double largeIconSize = 36;
const double defaultIconSize = 20;
const double smallIconSize = 16;
const double minimalIconSize = 14;

const double smallFontSize = 12;
const String developer = "Himanshu Chaurasiya";
const int maxFileSizeMb = 5;
const int maxFileSize = maxFileSizeMb * 1024 * 1024;

// Version helpers - Single source of truth from pubspec.yaml
Future<String> getAppVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version; // e.g., "1.0.0"
}

Future<String> getAppBuildNumber() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.buildNumber; // e.g., "1"
}

Future<String> getFullAppVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return '${packageInfo.version}+${packageInfo.buildNumber}'; // e.g., "1.0.0+1"
}
