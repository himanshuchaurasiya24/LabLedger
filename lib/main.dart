import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/authentication/global_error_observer.dart';
import 'package:labledger/providers/theme_providers.dart';
import 'package:labledger/screens/initials/window_loading_screen.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:async';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  await initializeBaseUrl();

  runApp(
    ProviderScope(observers: [GlobalErrorObserver()], child: const MyApp()),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WindowListener {
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
    final themeMode = ref.watch(themeNotifierProvider);
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
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'LabLedger',
        themeMode: themeMode,
        // 🌞 LIGHT THEME
        theme: ThemeData(
          hoverColor: Colors.transparent,
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
                seedColor: const Color(0xFF0072B5),
                primary: const Color(0xFF0072B5), // Deep Blue
                secondary: Colors.teal, // Teal Green
                brightness: Brightness.light,
                tertiary: const Color(0xFF2D2D2D), // Neutral dark text
                tertiaryFixed: const Color(0xFFFFFFFF), // White
                error: Colors.red,
              ).copyWith(
                surface: const Color(0xFFFDFDFD), // modern neutral bg
                surfaceContainerHighest: const Color(
                  0xFFF0F4F8,
                ), // subtle cards
              ),
          scaffoldBackgroundColor: const Color(0xFFF9FAFB),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF9FAFB),
            foregroundColor: Color(0xFF0072B5),
            elevation: 0,
          ),
          fontFamily: 'Ubuntu',
          textTheme: const TextTheme(
            headlineSmall: TextStyle(
              color: Color(0xFF0072B5),
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: TextStyle(fontSize: 20, color: Color(0xFF2D2D2D)),
            bodyMedium: TextStyle(color: Color(0xFF4B5563)),
            headlineLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
            headlineMedium: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 35,
            ),
          ),
          useMaterial3: true,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
              TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),

        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme:
              ColorScheme.fromSeed(
                seedColor: const Color(0xFF0072B5),
                brightness: Brightness.dark,
                primary: const Color(0xFF0072B5),
                secondary: Colors.teal,
                tertiary: const Color(0xFFFFFFFF),
                tertiaryFixed: const Color(0xFF121212),
                error: Colors.red,
              ).copyWith(
                surface: const Color(0xFF1C1C1E),
                surfaceContainerHighest: const Color(0xFF2A2A2C),
              ),
          scaffoldBackgroundColor: const Color(0xFF0F0F10),
          fontFamily: 'Ubuntu',
          textTheme: const TextTheme(
            headlineSmall: TextStyle(
              color: Color(0xFF1AA260),
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: TextStyle(fontSize: 20, color: Colors.white),
            bodyMedium: TextStyle(color: Color(0xFFB0B0B0)),
            headlineLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
            headlineMedium: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 35,
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1C1C1E),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1AA260),
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
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
              TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),

        home: WindowLoadingScreen(),
      ),
    );
  }
}
