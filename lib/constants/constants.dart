import 'package:package_info_plus/package_info_plus.dart';

const appName = 'LabLedger';
// Removed hardcoded version - now read from pubspec.yaml dynamically
const appDescription = 'Medical Records Made Simple';
const double defaultPadding = 12;
const double defaultRadius = 12;
const double defaultHeight = 20;
const double defaultWidth = 20;
const double initialWindowWidth = 1600;
const double initialWindowHeight = 900;
const double minimalBorderRadius = 6;
const double tintedContainerHeight = 304;
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
