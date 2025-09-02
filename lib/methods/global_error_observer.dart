// providers/global_error_observer.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/methods/handle_api_error.dart';

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
      // Call our existing global handler to check if it's a critical error.
      handleApiError(newValue.error);
    }
  }
}