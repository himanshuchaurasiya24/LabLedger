import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final messageNotifierProvider =
    StateNotifierProvider<MessageNotifier, MessagePlatform>((ref) {
      throw UnimplementedError('messageNotifierProvider must be overridden');
    });

const messagePlatformPreferenceKey = 'message_platform';

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

MessagePlatform messagePlatformFromPreferences(SharedPreferences preferences) {
  final storedValue = preferences.getString(messagePlatformPreferenceKey);
  return _resolveSelection(messagePlatformFromStorage(storedValue));
}

class MessageNotifier extends StateNotifier<MessagePlatform> {
  final SharedPreferences preferences;

  MessageNotifier({
    required MessagePlatform initialPlatform,
    required this.preferences,
  }) : super(_resolveSelection(initialPlatform));

  void ensureStoredSelection() {
    if (preferences.getString(messagePlatformPreferenceKey) !=
        state.storageValue) {
      preferences.setString(messagePlatformPreferenceKey, state.storageValue);
    }
  }

  Future<void> selectMessagePlatform(MessagePlatform platform) async {
    final resolvedValue = _resolveSelection(platform);
    state = resolvedValue;
    await preferences.setString(
      messagePlatformPreferenceKey,
      resolvedValue.storageValue,
    );
  }
}

MessagePlatform _resolveSelection(MessagePlatform platform) {
  if (platform == MessagePlatform.whatsapp && !_supportsWhatsApp()) {
    return _defaultMessagePlatform();
  }

  return platform;
}

MessagePlatform _defaultMessagePlatform() {
  if (kIsWeb) {
    return MessagePlatform.whatsappWebUi;
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.macOS => MessagePlatform.whatsapp,
    TargetPlatform.windows => MessagePlatform.whatsapp,
    TargetPlatform.linux => MessagePlatform.whatsappWebUi,
    _ => MessagePlatform.localSmsGateway,
  };
}

bool _supportsWhatsApp() {
  if (kIsWeb) {
    return false;
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.macOS => true,
    TargetPlatform.windows => true,
    _ => false,
  };
}
