import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/handle_api_error.dart';

class GlobalErrorObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (newValue is AsyncError) {
      if (provider.toString().contains('currentUserProvider')) {
        return;
      }

      try {
        handleApiError(newValue.error);
      } catch (e) {
        debugPrint("Error in GlobalErrorObserver: $e");
      }
    }
  }
}
