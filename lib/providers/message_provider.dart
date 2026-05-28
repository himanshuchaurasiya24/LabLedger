import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/utils/app_platform.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  );
});

final messageNotifierProvider =
    StateNotifierProvider<MessageNotifier, MessagePlatform>((ref) {
      final preferences = ref.watch(sharedPreferencesProvider);
      return MessageNotifier(preferences);
    });

enum MessagePlatform { localSmsGateway, whatsappWebUi, whatsapp }

extension MessagePlatformX on MessagePlatform {
  String get storageValue {
    return switch (this) {
      MessagePlatform.localSmsGateway => 'local_sms_gateway',
      MessagePlatform.whatsappWebUi => 'whatsapp_web_ui',
      MessagePlatform.whatsapp => 'whatsapp',
    };
  }

  String get label {
    return switch (this) {
      MessagePlatform.localSmsGateway => 'Local SMS Gateway',
      MessagePlatform.whatsappWebUi => 'WhatsApp WebUi',
      MessagePlatform.whatsapp => 'WhatsApp',
    };
  }

  IconData get icon {
    return switch (this) {
      MessagePlatform.localSmsGateway => Icons.sms_outlined,
      MessagePlatform.whatsappWebUi => Icons.web_outlined,
      MessagePlatform.whatsapp => Icons.chat_bubble_outline,
    };
  }
}

MessagePlatform messagePlatformFromStorage(String? value) {
  return switch (value) {
    'local_sms_gateway' => MessagePlatform.localSmsGateway,
    'whatsapp_web_ui' => MessagePlatform.whatsappWebUi,
    'whatsapp' => MessagePlatform.whatsapp,
    _ => _defaultMessagePlatform(),
  };
}

List<MessagePlatform> availableMessagePlatforms() {
  final platforms = <MessagePlatform>[
    MessagePlatform.localSmsGateway,
    MessagePlatform.whatsappWebUi,
  ];

  if (_supportsWhatsApp()) {
    platforms.add(MessagePlatform.whatsapp);
  }

  return platforms;
}

class MessageNotifier extends StateNotifier<MessagePlatform> {
  static const _key = 'message_platform';

  final SharedPreferences _preferences;

  MessageNotifier(this._preferences) : super(_defaultMessagePlatform()) {
    _loadMessagePlatform();
  }

  void _loadMessagePlatform() {
    final storedValue = _preferences.getString(_key);
    final resolvedValue = _resolveSelection(
      messagePlatformFromStorage(storedValue),
    );

    state = resolvedValue;

    if (storedValue != resolvedValue.storageValue) {
      _preferences.setString(_key, resolvedValue.storageValue);
    }
  }

  Future<void> selectMessagePlatform(MessagePlatform platform) async {
    final resolvedValue = _resolveSelection(platform);
    state = resolvedValue;
    await _preferences.setString(_key, resolvedValue.storageValue);
  }

  MessagePlatform _resolveSelection(MessagePlatform platform) {
    if (platform == MessagePlatform.whatsapp && !_supportsWhatsApp()) {
      return _defaultMessagePlatform();
    }

    return platform;
  }
}

MessagePlatform _defaultMessagePlatform() {
  return switch (currentAppPlatform()) {
    AppPlatform.linux => MessagePlatform.whatsappWebUi,
    AppPlatform.macos => MessagePlatform.whatsapp,
    AppPlatform.windows => MessagePlatform.whatsapp,
    AppPlatform.web => MessagePlatform.whatsappWebUi,
    AppPlatform.other => MessagePlatform.localSmsGateway,
  };
}

bool _supportsWhatsApp() {
  return switch (currentAppPlatform()) {
    AppPlatform.macos => true,
    AppPlatform.windows => true,
    _ => false,
  };
}
