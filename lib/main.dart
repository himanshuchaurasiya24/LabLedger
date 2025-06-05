import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/screens/window_loading_screen.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:async';

Size get initialWindowSize => const Size(700, 350); // 🟩 Initial Size
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: initialWindowSize,
    center: true,
    title: 'LabLedger',
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  bool isFullScreen = false;
  final ValueNotifier<bool> isLoginScreen = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _checkFullScreen();
  }

  Future<void> _checkFullScreen() async {
    bool isFullScreen = await windowManager.isFullScreen();
    setState(() {
      this.isFullScreen = isFullScreen;
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowEnterFullScreen() {
    setState(() {
      isFullScreen = true;
    });
  }

  @override
  void onWindowLeaveFullScreen() {
    setState(() {
      isFullScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: (event) async {
        if (isLoginScreen.value) return; // ⛔ Block keys on login screen
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape && isFullScreen) {
            await windowManager.setFullScreen(false);
          }
          if (event.logicalKey == LogicalKeyboardKey.f11) {
            if (!isFullScreen) {
              await windowManager.setFullScreen(true);
            } else {
              await windowManager.setFullScreen(false);
            }
            await _checkFullScreen();
          }
        }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LabLedger',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFEFF7F6),
          primaryColor: const Color(0xFF006D77),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006D77),
          primary: const Color(0xFF006D77),
          secondary: const Color(0xFF83C5BE),
        ),
          primarySwatch: MaterialColor(
            0xFF006D77,
            <int, Color>{
              50: Color(0xFFE0F2F1),
              100: Color(0xFFB2DFDB),
              200: Color(0xFF80CBC4),
              300: Color(0xFF4DB6AC),
              400: Color(0xFF26A69A),
              500: Color(0xFF006D77),
              600: Color(0xFF00897B),
              700: Color(0xFF00796B),
              800: Color(0xFF00695C),
              900: Color(0xFF004D40),
            },
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3:
              true, // Enable Material You design (optional but recommended)
          splashFactory: InkRipple
              .splashFactory, // Ripple effect works on all platforms nicely
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.windows:
                  ZoomPageTransitionsBuilder(), // better for desktop
              TargetPlatform.linux: ZoomPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
            },
          ),
          // Optionally, customize scrollbar behavior for desktop
          scrollbarTheme: ScrollbarThemeData(
            thumbVisibility: WidgetStateProperty.all(true),
            thickness: WidgetStateProperty.all(8),
            radius: Radius.circular(4),
          ),
        ),
        home: WindowLoadingScreen(onLoginScreen: isLoginScreen,),
      ),
    );
  }
}
