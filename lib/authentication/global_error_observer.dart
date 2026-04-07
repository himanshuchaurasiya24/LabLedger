// providers/global_error_observer.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/handle_api_error.dart';

/// This observer listens to all provider state changes in the app.
class GlobalErrorObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // We only care about providers that have transitioned to an error state.
    if (newValue is AsyncError) {
      // Skip handling errors from startup providers (currentUserProvider)
      // as they're handled separately in window_loading_screen
      if (provider.toString().contains('currentUserProvider')) {
        return;
      }

      try {
        // Call our existing global handler to check if it's a critical error.
        handleApiError(newValue.error);
      } catch (e) {
        debugPrint("Error in GlobalErrorObserver: $e");
      }
    }
  }
}
