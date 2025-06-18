import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/side_screens/dashboard.dart';
import 'package:labledger/screens/side_screens/settings.dart';
import 'package:window_manager/window_manager.dart';

Widget settingsPageTopBar({
  required BuildContext context,
  required String pageName,
  required Color chipColor,
}) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: appIconName(
              context: context,
              firstName: "Lab",
              secondName: "Ledger",
              // fontSize: 50,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              pageName,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),

          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: customChip(
              chipColor: chipColor,
              backgroundColor: Colors.red[100]!,
              chipTitle: "Go Back ",
              iconWidget: Icon(CupertinoIcons.back, color: chipColor),
              iconVisible: true,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget customChipButton({
  required void Function() onTap,
  required Color chipColor,
  required Color backgroundColor,
  required String chipTitle,
  double? height,
  double? width,
  Widget? iconWidget,
  bool? iconVisible,
}) {
  return GestureDetector(
    onTap: onTap,
    child: customChip(
      chipColor: chipColor,
      backgroundColor: backgroundColor,
      chipTitle: chipTitle,
      height: height,
      width: width,
      iconVisible: iconVisible,
      iconWidget: iconWidget,
    ),
  );
}

Widget customChip({
  required Color chipColor,
  required Color backgroundColor,
  required String chipTitle,
  double? height,
  double? width,
  Widget? iconWidget,
  bool? iconVisible,
}) {
  return Container(
    height: height ?? 40,
    width: width ?? 92,
    decoration: BoxDecoration(
      color: backgroundColor,
      border: BoxBorder.all(
        color: backgroundColor,
        style: BorderStyle.solid,
        strokeAlign: BorderSide.strokeAlignCenter,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(minimalBorderRadius),
    ),
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: iconVisible ?? true,
            child: iconWidget ?? const SizedBox(),
          ),
          Text(
            chipTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: chipColor,
            ),
          ),
        ],
      ),
    ),
  );
}

void setWindowBehavior({bool? isForLogin, bool? removeTitleBar}) async {
  bool isLogin = isForLogin ?? false;
  bool removeTitle = removeTitleBar ?? true;

  if (!isLogin) {
    await windowManager.setSize(const Size(1600, 900), animate: true);
    await windowManager.center();
    await windowManager.setSkipTaskbar(false);
    await windowManager.setTitleBarStyle(
      removeTitle == false ? TitleBarStyle.normal : TitleBarStyle.hidden,
    );
  } else {
    await windowManager.setSize(const Size(700, 350), animate: true);
    await windowManager.center();
    await windowManager.setSkipTaskbar(true);
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  }
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

Widget customButton({
  required BuildContext context,
  required GlobalKey formKey,
  required VoidCallback ontap,
}) {
  return SizedBox(
    height: 45,
    width: double.infinity,
    child: ElevatedButton(
      onPressed: ontap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Text(
        "Update Details",
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    ),
  );
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
          color: Theme.of(context).cardColor,
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
      leading: Icon(
        icon,
        color: ref.read(lightScaffoldColorProvider),
        size: 24,
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: ref.read(lightScaffoldColorProvider),
          fontSize: 24,
        ),
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

Widget mainScreenContentProvider({required int indexNumber}) {
  switch (indexNumber) {
    case 0:
      return Dashboard();
    case 5:
      return Settings();

    default:
      return Text('Invalid index');
  }
}

Widget appIconName({
  required BuildContext context,
  double? fontSize,
  required String firstName,
  required String secondName,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
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
