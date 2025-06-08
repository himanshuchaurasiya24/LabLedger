import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/screens/initials/window_loading_screen.dart';
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
        themeMode: ThemeMode.light,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: MaterialColor(0xFF0072B5, <int, Color>{
            50: Color(0xFFE1F0F9),
            100: Color(0xFFB3DAEF),
            200: Color(0xFF80C3E4),
            300: Color(0xFF4DADD9),
            400: Color(0xFF269CD1),
            500: Color(0xFF0072B5),
            600: Color(0xFF0066A3),
            700: Color(0xFF005A91),
            800: Color(0xFF004E7F),
            900: Color(0xFF00375F),
          }),
          colorScheme:
              ColorScheme.fromSeed(
                seedColor: Color(0xFF0072B5),
                primary: Color(0xFF0072B5),
                secondary: Color(0xFF1AA260),
                brightness: Brightness.light,
              ).copyWith(
                surface: Color(0xFFFAFAF6), // ✅ Replace deprecated background
                surfaceContainerHighest: Color(0xFFE8F0F9),
              ),
          scaffoldBackgroundColor:
              Colors.grey[200]!, // ✅ Replace deprecated background
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0072B5),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          fontFamily: 'GoogleSans',
          textTheme: const TextTheme(
            headlineSmall: TextStyle(
              color: Color(0xFF0072B5),
              fontWeight: FontWeight.bold,
            ),
            bodyMedium: TextStyle(color: Colors.black87),
          ),
        ),

        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme:
              ColorScheme.fromSeed(
                seedColor: Color(0xFF0072B5),
                brightness: Brightness.dark,
                primary: Color(0xFF0072B5),
                secondary: Color(0xFF1AA260),
              ).copyWith(
                surface: Color(0xFF1E1E1E),
                surfaceContainerHighest: Color(0xFF2C2C2C),
              ),
          scaffoldBackgroundColor: Color(0xFF23272F),
          // ⬅️ Dark mode BG
          fontFamily: 'GoogleSans',
          textTheme: const TextTheme(
            headlineSmall: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            bodyMedium: TextStyle(color: Colors.white70),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0072B5),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1AA260),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF1AA260),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0072B5)),
            ),
          ),
          useMaterial3: true,
          splashFactory: InkRipple.splashFactory,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.windows: ZoomPageTransitionsBuilder(),
              TargetPlatform.linux: ZoomPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
            },
          ),
          scrollbarTheme: ScrollbarThemeData(
            thumbVisibility: WidgetStateProperty.all(true),
            thickness: WidgetStateProperty.all(8),
            radius: const Radius.circular(4),
          ),
        ),

        home: WindowLoadingScreen(onLoginScreen: isLoginScreen),
      ),
    );
  }
}
