// lib/utils/riverpod_utils.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> invalidateProvidersAfterDelay(
 {required WidgetRef ref,
  required List<ProviderBase> providers,}
) async {
  // Wait for the typical page transition animation duration to finish.
  await Future.delayed(const Duration(milliseconds: 1200));

  // Invalidate all providers in the list.
  for (final provider in providers) {
    ref.invalidate(provider);
  }
}
