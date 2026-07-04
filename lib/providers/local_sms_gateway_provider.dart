import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const localSmsGatewayUrlKey = 'local_sms_gateway_url';
const localSmsGatewayPhoneKeyKey = 'local_sms_gateway_phone_key';
const localSmsGatewayMessageKeyKey = 'local_sms_gateway_message_key';

class LocalSmsGatewayConfig {
  final String url;
  final String phoneKey;
  final String messageKey;

  const LocalSmsGatewayConfig({
    required this.url,
    required this.phoneKey,
    required this.messageKey,
  });

  LocalSmsGatewayConfig copyWith({
    String? url,
    String? phoneKey,
    String? messageKey,
  }) {
    return LocalSmsGatewayConfig(
      url: url ?? this.url,
      phoneKey: phoneKey ?? this.phoneKey,
      messageKey: messageKey ?? this.messageKey,
    );
  }
}

class LocalSmsGatewayConfigNotifier
    extends StateNotifier<LocalSmsGatewayConfig> {
  final SharedPreferences preferences;

  LocalSmsGatewayConfigNotifier(this.preferences)
      : super(
          LocalSmsGatewayConfig(
            url: preferences.getString(localSmsGatewayUrlKey) ?? 'http://192.168.',
            phoneKey: preferences.getString(localSmsGatewayPhoneKeyKey) ?? 'phone',
            messageKey: preferences.getString(localSmsGatewayMessageKeyKey) ?? 'message',
          ),
        );

  Future<void> updateConfig({
    required String url,
    required String phoneKey,
    required String messageKey,
  }) async {
    state = LocalSmsGatewayConfig(
      url: url,
      phoneKey: phoneKey,
      messageKey: messageKey,
    );
    await preferences.setString(localSmsGatewayUrlKey, url);
    await preferences.setString(localSmsGatewayPhoneKeyKey, phoneKey);
    await preferences.setString(localSmsGatewayMessageKeyKey, messageKey);
  }
}

final localSmsGatewayConfigProvider = StateNotifierProvider<
    LocalSmsGatewayConfigNotifier, LocalSmsGatewayConfig>((ref) {
  throw UnimplementedError('localSmsGatewayConfigProvider must be overridden');
});
