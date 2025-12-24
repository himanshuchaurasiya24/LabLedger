import 'package:package_info_plus/package_info_plus.dart';

final appName = 'LabLedger';
// Removed hardcoded version - now read from pubspec.yaml dynamically
final appDescription = 'Medical Records Made Simple';
final double defaultPadding = 12;
final double defaultRadius = 12;
final double defaultHeight = 20;
final double defaultWidth = 20;
final double initialWindowWidth = 1600;
final double initialWindowHeight = 900;
final double minimalBorderRadius = 6;
final double tintedContainerHeight = 304;
final String developer = "Himanshu Chaurasiya";
const int maxFileSize = 1 * 1024 * 1024;

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
