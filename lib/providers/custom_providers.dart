import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final String baseURL = 'http://127.0.0.1:8000/';
final double defaultPadding = 24;
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});
final splashScreenTimeProvider = Provider<Duration>((ref) {
  return const Duration(seconds: 3); // Duration for splash screen
});
final tokenProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  return await storage.read(key: 'access_token');
});
final appNameProvider = Provider<String>((ref) {
  return 'LabLedger';
});
final appVersionProvider = Provider<String>((ref) {
  return '1.0.0';
});
final appDescriptionProvider = Provider<String>((ref) {
  return 'Medical Records Made Simple';
});
final baseUrlProvider = Provider<String>((ref) {
  return baseURL; // Replace with your actual base URL
});

final splashAppNameProvider = Provider<Widget>((ref) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Lab",
        style: TextStyle(
          fontSize: 90,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 0, 110, 164),
        ),
      ),
      Text(
        "Ledger",
        style: TextStyle(
          fontSize: 90,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 2, 166, 36),
        ),
      ),
    ],
  );
});

/// Returns the app icon and name widget, adapting the icon to the current theme.
Widget appIconNameWidget({
  required BuildContext context,
  bool? forLogInScreen,
}) {
  String assetLocation = 'assets/images/light.png';
  bool isForLogInScreen = forLogInScreen ?? false;
  if (isForLogInScreen) {
    assetLocation = 'assets/images/app_icon.png';
  } else {
    assetLocation = 'assets/images/light.png';
  }

  return Column(
    children: [
      const SizedBox(height: 20),
      Image.asset(assetLocation, width: 160, height: 160),
      const SizedBox(height: 10),
      isForLogInScreen
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Lab",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  "Ledger",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "LabLedger",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: ThemeData.light().scaffoldBackgroundColor,
                  ),
                ),
              ],
            ),
    ],
  );
}


final lightScaffoldColorProvider = Provider<Color>((ref) {
  return ThemeData.light().scaffoldBackgroundColor;
});

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ThemeNotifier(storage);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'theme_mode';
  final FlutterSecureStorage _storage;

  ThemeNotifier(this._storage) : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final mode = await _storage.read(key: _key);
    switch (mode) {
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'light':
        state = ThemeMode.light;
        break;
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> toggleTheme(ThemeMode mode) async {
    state = mode;

    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };

    await _storage.write(key: _key, value: value);
  }
}