
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
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
  return 'http://127.0.0.1:8000/'; // Replace with your actual base URL
});