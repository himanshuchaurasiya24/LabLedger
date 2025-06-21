import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/initials/window_loading_screen.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:async';

Size get initialWindowSize => const Size(700, 350); // 🟩 Initial Size
final ValueNotifier<bool> isLoginScreen = ValueNotifier<bool>(false);
final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);
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
        debugShowCheckedModeBanner: false,
        title: 'LabLedger',
        themeMode: ThemeMode.system,
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
                tertiary:Color(0xFF020711),
                tertiaryFixed: Color(0xFFFFFFFF).withValues(alpha: 0.9)
              ).copyWith(
                surface: Color(0xFFFAFAF6), // ✅ Replace deprecated background
                surfaceContainerHighest: Color(0xFFE8F0F9),
              ),
          scaffoldBackgroundColor: Color(
            0xFFE5E5E5,
          ), // ✅ Replace deprecated background
          appBarTheme: AppBarTheme(backgroundColor: Color(0xFFE5E5E5)),
          fontFamily: 'GoogleSans',
          textTheme: const TextTheme(
            headlineSmall: TextStyle(
              color: Color(0xFF0072B5),
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: TextStyle(fontSize: 20),
            bodyMedium: TextStyle(color: Colors.black87),
            headlineLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
            headlineMedium: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 35,
            ),
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
                tertiary: Color(0xFFFFFFFF).withValues(alpha: 0.9),
                tertiaryFixed:Color(0xFF020711), 
              ).copyWith(
                surface: Color(0xFF1E1E1E),
                surfaceContainerHighest: Color(0xFF2C2C2C),
              ),
          scaffoldBackgroundColor: Color(0xFF171717),
          // ⬅️ Dark mode BG
          fontFamily: 'GoogleSans',
          textTheme: const TextTheme(
            headlineSmall: TextStyle(
              color: Color(0xFF0072B5),
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: TextStyle(fontSize: 20),

            bodyMedium: TextStyle(color: Colors.white70),
            headlineLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
            headlineMedium: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 35,
            ),
          ),
          appBarTheme: AppBarTheme(backgroundColor: Color(0xFF23272F)),
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
        // home: Settings(),
      ),
    );
  }
}

class GlassEffectExample extends StatelessWidget {
  const GlassEffectExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF1C1C1E), // iOS dark background
      body: Center(child: GlassContainer()),
    );
  }
}

class GlassContainer extends StatelessWidget {
  final double width;
  final double height;
  final Widget? child;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  const GlassContainer({
    super.key,
    this.width = 300,
    this.height = 200,
    this.child,
    this.backgroundColor = Colors.white60,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            // .withValues(alpha: alphaValue), // Glass tint
            borderRadius: borderRadius,
            border: Border.all(
              color: backgroundColor,
              // .withValues(
              // alpha: alphaValue,
              // ), // Optional white border
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
