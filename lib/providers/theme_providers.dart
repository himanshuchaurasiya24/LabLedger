
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/providers/secure_storage_provider.dart';

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((
  ref,
) {
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
