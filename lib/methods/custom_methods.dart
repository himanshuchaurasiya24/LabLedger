import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/main_screens/dashboard.dart';
import 'package:labledger/screens/main_screens/settings.dart';
import 'package:window_manager/window_manager.dart';

void setWindowBehavior({bool? isForLogin}) async {
  bool isLogin = isForLogin ?? false;
  if (!isLogin) {
    await windowManager.setSize(const Size(1280, 720), animate: true);
    await windowManager.center();
    await windowManager.setSkipTaskbar(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
  } else {
    await windowManager.setSize(const Size(700, 350), animate: true);
    await windowManager.center();
    await windowManager.setSkipTaskbar(true);
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  }
}

Widget customTextField({
  // required GlobalKey,
  required String labelText,
  required TextEditingController controller,
}) {
  return TextFormField(
    validator: (value) {
      if (value != null) {
        if (value.isEmpty) {
          return "Enter $labelText";
        }
        return null;
      }
      return null;
    },

    controller: controller,
    obscureText: true,
    decoration: InputDecoration(
      labelText: labelText,
      prefixIcon: const Icon(Icons.lock_outline),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

class ThemeToggleBar extends ConsumerWidget {
  const ThemeToggleBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.color_lens_outlined, size: 20),
          const SizedBox(width: 12),
          const Text(
            'Theme Mode',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          DropdownButton<ThemeMode>(
            value: themeMode,
            dropdownColor: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            underline: const SizedBox.shrink(),
            onChanged: (mode) {
              if (mode != null) {
                themeNotifier.toggleTheme(mode);
              }
            },
            items: const [
              DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
            ],
          ),
        ],
      ),
    );
  }
}


class SidebarItem extends ConsumerWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(icon, color: ref.read(lightScaffoldColorProvider)),
      title: Text(
        label,
        style: TextStyle(color: ref.read(lightScaffoldColorProvider)),
      ),
      onTap: onTap,
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  const SummaryCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              count,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

Widget mainScreenContentProvider({required int indexNumber}) {
  switch (indexNumber) {
    case 0:
      return Dashboard();
    case 7:
      return Settings();

    default:
      return Text('Invalid index');
  }
}

/// Returns the app icon and name widget, adapting the icon to the current theme.
Widget appIconNameWidget({
  required BuildContext context,
  bool? forLogInScreen,
}) {
  String assetLocation = 'assets/images/light.png';
  bool isForLogInScreen = forLogInScreen ?? false;
  if (isForLogInScreen) {
    assetLocation = 'assets/images/app_icon.png';
  } else {
    assetLocation = 'assets/images/light.png';
  }

  return Column(
    children: [
      const SizedBox(height: 20),
      Image.asset(assetLocation, width: 160, height: 160),
      const SizedBox(height: 10),
      isForLogInScreen
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Lab",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  "Ledger",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "LabLedger",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: ThemeData.light().scaffoldBackgroundColor,
                  ),
                ),
              ],
            ),
    ],
  );
}
