import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/providers/theme_providers.dart';
import 'package:labledger/screens/window_scaffold.dart';
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

class CenterSearchBar extends StatelessWidget {
  final String hintText;
  final Function(String) onSearch; // <-- take value
  final TextEditingController controller;
  final FocusNode searchFocusNode;
  final double? width;
  const CenterSearchBar({
    super.key,
    required this.hintText,
    required this.onSearch,
    required this.controller,
    required this.searchFocusNode,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      width: width,
      child: Center(
        child: TextField(
          focusNode: searchFocusNode,
          controller: controller,
          decoration: InputDecoration(
            fillColor: Theme.of(context).brightness == Brightness.light
                ? containerLightColor
                : containerDarkColor,
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(minimalBorderRadius),
            ),
            hintText: hintText,
          ),
          onChanged: onSearch, // <-- pass directly
        ),
      ),
    );
  }
}

Widget pageHeader({
  required BuildContext context,
  required Widget? centerWidget,
}) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          appIconName(
            context: context,
            firstName: "Lab",
            secondName: "Ledger",
            fontSize: 45,
          ),
          centerWidget ?? const SizedBox(),

          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            hoverColor: Colors.transparent,
            color: Colors.red[100],
            icon: Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: Colors.red[400],
                borderRadius: BorderRadius.circular(defaultPadding / 2),
              ),
              child: Icon(
                Icons.close,
                size: 35,
                color: Theme.of(context).colorScheme.tertiaryFixed,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

Future<void> setWindowBehavior({bool? isForLogin, bool? isLoadingScreen}) async {
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


class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    this.isObscure = false,
    required this.labelText,
    this.keyboardType,
    this.passwordController,
    this.isConfirm,
    this.readOnly,
    this.maxLines,
    this.onChanged,
    this.valueLimit,
    this.fillColor,
    this.hoverColor,
  });

  final TextEditingController controller;
  final bool? isObscure;
  final String labelText;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final TextEditingController? passwordController;
  final bool? isConfirm;
  final bool? readOnly;
  final int? maxLines;
  final int? valueLimit;
  final Color? fillColor;
  final Color? hoverColor;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isObscure = false;
  @override
  void initState() {
    super.initState();
    isObscure = widget.isObscure! ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: widget.onChanged,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines ?? 1,
      obscureText: isObscure,
      readOnly: widget.readOnly ?? false,
      validator: (value) {
        if (widget.isConfirm == true && widget.passwordController != null) {
          if (value != widget.passwordController!.text) {
            return 'Password does\'nt match';
          }
        }
        if (value != null && value.trim().isEmpty) {
          return 'Please enter ${widget.labelText}';
        }
        if (widget.valueLimit != null &&
            widget.keyboardType == TextInputType.number &&
            value != null) {
          int pValue = int.tryParse(value)!;
          if (pValue > widget.valueLimit!) {
            return 'Range is only upto ${widget.valueLimit}';
          }
        }
        if (value != null && widget.keyboardType == TextInputType.number) {
          final intvalue = int.tryParse(value);
          if (intvalue == null) {
            return 'Invalid ${widget.labelText}';
          }
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: widget.isObscure!
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isObscure = !isObscure;
                  });
                },
                icon: const Icon(Icons.visibility),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
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
  MainAxisAlignment? alignment
}) {
  return Row(
    mainAxisAlignment: alignment?? MainAxisAlignment.start,
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
