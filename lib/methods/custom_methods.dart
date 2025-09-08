import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/providers/theme_providers.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:window_manager/window_manager.dart';

final containerLightColor = Color(0xFFEEEEEE);
final containerDarkColor = Color(0xFF212121);

class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

// Modern Search Bar
class CenterSearchBar extends StatelessWidget {
  final String hintText;
  final Function(String) onSearch;
  final TextEditingController controller;
  final FocusNode searchFocusNode;
  final double? width;
  final VoidCallback? onClear;

  const CenterSearchBar({
    super.key,
    required this.hintText,
    required this.onSearch,
    required this.controller,
    required this.searchFocusNode,
    this.width = 200,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          // Gradient background for modern look
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : const Color(0xFF2A2A2A),
              Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFFF8F9FA)
                  : const Color(0xFF1E1E1E),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          // Enhanced shadow
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
            // Inner shadow for depth
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.05),
              offset: const Offset(0, -1),
              blurRadius: 1,
              spreadRadius: 0,
            ),
          ],
          // Subtle border
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: TextField(
          focusNode: searchFocusNode,
          controller: controller,
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).brightness == Brightness.light
                ? const Color(0xFF2C2C2C)
                : Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            fillColor: Colors.transparent,
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.withValues(alpha: 0.6)
                  : Colors.grey.withValues(alpha: 0.5),
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            // Search icon
            prefixIcon: Icon(
              CupertinoIcons.search,
              size: 20,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.withValues(alpha: 0.7)
                  : Colors.grey.withValues(alpha: 0.6),
            ),
            // Clear button when text is present
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      CupertinoIcons.clear_circled_solid,
                      size: 18,
                      color: Colors.grey.withValues(alpha: 0.6),
                    ),
                    onPressed: () {
                      controller.clear();
                      onSearch('');
                      if (onClear != null) onClear!();
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: onSearch,
        ),
      ),
    );
  }
}

Future<void> setWindowBehavior({
  bool? isForLogin,
  bool? isLoadingScreen,
}) async {
  final isLogin = isForLogin ?? false;
  final isForLoadingScreen = isLoadingScreen ?? false;

  await windowManager.waitUntilReadyToShow(null, () async {
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);

    if (isForLoadingScreen) {
      await windowManager.setSkipTaskbar(false);
      await windowManager.setMinimumSize(const Size(700, 350));
      await windowManager.setMaximumSize(const Size(700, 350));

      await windowManager.setSize(const Size(700, 350));
      await windowManager.center();

      isLoginScreen.value = true;
      return;
    }

    if (isLogin) {
      await windowManager.setSkipTaskbar(false);
      await windowManager.setMinimumSize(const Size(800, 490));
      await windowManager.setMaximumSize(const Size(800, 490));

      await windowManager.setSize(const Size(800, 490));
      await windowManager.center();

      isLoginScreen.value = true;
      return;
    }

    // Else: WindowScaffold will handle main app window setup
  });
}


Widget customBar({
  required BuildContext context,
  required String barText,
  required IconData iconData,
  required Widget child,
}) {
  return Column(
    children: [
      Container(
        height: MediaQuery.of(context).size.height / 10,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? containerLightColor
              : containerDarkColor,
          borderRadius: BorderRadius.circular(minimalBorderRadius),
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
            Icon(iconData, size: 30),
            const SizedBox(width: 12),
            Text(barText, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            child,
          ],
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}

class ThemeToggleBar extends ConsumerWidget {
  const ThemeToggleBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    return customBar(
      context: context,
      barText: "Theme Mode",
      iconData: Theme.of(context).colorScheme.brightness == Brightness.light
          ? Icons.dark_mode_outlined
          : Icons.light_mode_outlined,
      child: DropdownButton<ThemeMode>(
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
    );
  }
}

class PageNavigatorBar extends StatelessWidget {
  const PageNavigatorBar({
    super.key,
    required this.iconData,
    required this.barText,
    required this.goToPage,
  });
  final IconData iconData;
  final String barText;
  final Widget goToPage;
  void onTapFunction({required BuildContext context}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return goToPage;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTapFunction(context: context);
      },
      child: customBar(
        context: context,
        barText: barText,
        iconData: iconData,
        child: IconButton(
          onPressed: () {
            onTapFunction(context: context);
          },
          icon: Icon(Icons.arrow_right_outlined),
        ),
      ),
    );
  }
}

class SidebarItem extends StatefulWidget {
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
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(minimalBorderRadius),
      ),
      child: ListTile(
        leading: Icon(
          widget.icon,
          color: ThemeData.light().scaffoldBackgroundColor,
          size: 24,
        ),
        title: Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: ThemeData.light().scaffoldBackgroundColor,
            fontSize: 24,
          ),
        ),
        onTap: () {
          widget.onTap();
        },
      ),
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
          borderRadius: BorderRadius.circular(minimalBorderRadius),
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

Widget appIconName({
  required BuildContext context,
  double? fontSize,
  required String firstName,
  required String secondName,
  MainAxisAlignment? alignment,
}) {
  return Row(
    mainAxisAlignment: alignment ?? MainAxisAlignment.start,
    children: [
      Text(
        firstName,
        style: TextStyle(
          fontSize: fontSize ?? 40,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      Text(
        secondName,
        style: TextStyle(
          fontSize: fontSize ?? 40,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    ],
  );
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
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: ThemeData.light().scaffoldBackgroundColor,
                  ),
                ),
              ],
            ),
    ],
  );
}

class CustomCardContainer extends StatelessWidget {
  const CustomCardContainer({
    super.key,

    required this.xWidth,
    required this.xHeight,
    required this.child,
  });

  final double xWidth;
  final double xHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * xHeight,
        width: MediaQuery.of(context).size.width * xWidth,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryFixed,
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        child: Padding(
          padding: EdgeInsetsGeometry.only(
            left: defaultPadding / 2,
            right: defaultPadding / 2,
            bottom: defaultPadding / 2,
          ),
          child: child,
        ),
      ),
    );
  }
}
