import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labledger/screens/window_loading_screen.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(700, 350), // 🟩 Initial Size
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

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  bool isFullScreen = false;
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
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape && isFullScreen) {
            await windowManager.setFullScreen(false);
            await windowManager.setSize(const Size(1280, 720), animate: true);
            await windowManager.center();
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
          primarySwatch: Colors.deepPurple,
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
        home: WindowLoadingScreen(),
      ),
    );
  }
}
