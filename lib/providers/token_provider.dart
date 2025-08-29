import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final tokenProvider = FutureProvider.autoDispose<String?>((ref) {
  final storage = FlutterSecureStorage();
  return storage.read(key: 'access_token');
});
