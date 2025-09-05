// screens/window_scaffold.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:window_manager/window_manager.dart';

final ValueNotifier<bool> isLoginScreen = ValueNotifier<bool>(false);

class WindowScaffold extends StatefulWidget {
  final Widget child;
  final bool showAppName;
  final String? customTitle;
  final Widget? centerWidget;
  final bool allowFullScreen;
  final bool isInitialScreen;
  final double? spaceAfterRow;
  final bool enableSlideTransition;

  const WindowScaffold({
    super.key,
    required this.child,
    this.showAppName = true,
    this.customTitle,
    this.centerWidget,
    this.allowFullScreen = true,
    this.isInitialScreen = false,
    this.spaceAfterRow,
    this.enableSlideTransition = true,
  });

  @override
  State<WindowScaffold> createState() => _WindowScaffoldState();
}

class _WindowScaffoldState extends State<WindowScaffold>
    with WindowListener, TickerProviderStateMixin {
  bool isMaximized = false;
  bool isFullScreen = false;
  late ThemeData currentTheme;
  late FocusNode focusNode;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    _initializeWindow();
    windowManager.addListener(this);

    final Duration slideDuration = widget.isInitialScreen
        ? const Duration(milliseconds: 2000)
        : const Duration(milliseconds: 1000);

    _slideController = AnimationController(
      duration: slideDuration,
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(1.0, 0.0), // Start from right
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: widget.isInitialScreen
                ? Curves.easeInOutCubic
                : Curves.easeOutCubic,
          ),
        );

    if (widget.enableSlideTransition) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _slideController.forward();
      });
    } else {
      _slideController.value = 1.0;
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    focusNode.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentTheme = Theme.of(context);
  }

  Future<void> _initializeWindow() async {
    await windowManager.ensureInitialized();
    await windowManager.setMaximizable(true);
    await windowManager.setMinimizable(true);
    if (widget.isInitialScreen) {
      await _setupMainAppWindow();
    }
    isMaximized = await windowManager.isMaximized();
    isFullScreen = await windowManager.isFullScreen();
    if (mounted) setState(() {});
  }

  Future<void> _setupMainAppWindow() async {
    try {
      if (await windowManager.isMaximized()) {
        await windowManager.unmaximize();
        await Future.delayed(const Duration(milliseconds: 150));
      }
      if (await windowManager.isFullScreen()) {
        await windowManager.setFullScreen(false);
        await Future.delayed(const Duration(milliseconds: 150));
      }
      await windowManager.setSkipTaskbar(false);
      await windowManager.setMinimumSize(const Size(800, 600));
      await windowManager.setMaximumSize(const Size(4000, 3000));
      await Future.delayed(const Duration(milliseconds: 150));
      await windowManager.setSize(const Size(1600, 900));
      await Future.delayed(const Duration(milliseconds: 300));
      for (int i = 0; i < 5; i++) {
        await windowManager.center();
        await Future.delayed(const Duration(milliseconds: 150));
        final position = await windowManager.getPosition();
        if (position.dx > 0 && position.dy > 0) break;
      }
      await windowManager.show();
      await windowManager.focus();
      isLoginScreen.value = false;
    } catch (e) {
      debugPrint("Error setting up main window: $e");
      await windowManager.center();
    }
  }

  @override
  void onWindowMaximize() => setState(() => isMaximized = true);
  @override
  void onWindowUnmaximize() => setState(() => isMaximized = false);
  @override
  void onWindowEnterFullScreen() => setState(() => isFullScreen = true);
  @override
  void onWindowLeaveFullScreen() => setState(() => isFullScreen = false);

  Future<void> _handleKeyEvent(KeyEvent event) async {
    if (!widget.allowFullScreen) return;
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.f11) {
        await windowManager.setFullScreen(!isFullScreen);
      } else if (event.logicalKey == LogicalKeyboardKey.escape &&
          isFullScreen) {
        await windowManager.setFullScreen(false);
      }
    }
  }

  Future<void> _handleMaximizeRestore() async {
    if (await windowManager.isMaximized()) {
      windowManager.unmaximize();
    } else {
      windowManager.maximize();
    }
  }

  Future<void> _handleBackButton() async {
    if (!Navigator.of(context).canPop()) return;
    if (widget.enableSlideTransition) {
      _slideController.duration = const Duration(milliseconds: 250);
      await _slideController.reverse();
    }
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Color get _iconColor => currentTheme.brightness == Brightness.dark
      ? const Color(0xFFCCCCCC)
      : const Color(0xFF5A5A5A);
  Color get _hoverColor => currentTheme.brightness == Brightness.dark
      ? const Color(0xFF3E3E42)
      : const Color(0xFFE5E5E5);

  @override
  Widget build(BuildContext context) {
    // Note: All ref.listen blocks have been removed from here.
    return KeyboardListener(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  Row(
                    children: [
                      if (!widget.isInitialScreen)
                        Padding(
                          padding: EdgeInsets.only(
                            left: defaultPadding,
                            top: defaultPadding / 2,
                          ),
                          child: GestureDetector(
                            onTap: _handleBackButton,
                            child: Container(
                              width: 50,
                              height: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  defaultRadius,
                                ),
                                color: Colors.red[400],
                              ),
                              child: Center(
                                child: Icon(
                                  CupertinoIcons.back,
                                  size:
                                      24, // Slightly smaller for better proportion
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withValues(alpha: 0.95)
                                      : Colors.white,
                                  shadows: [
                                    // Icon shadow for better visibility
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                      GestureDetector(
                        onPanStart: (_) => windowManager.startDragging(),
                        child: Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.only(left: defaultPadding),
                          alignment: Alignment.center,
                          child: widget.customTitle != null
                              ? Text(
                                  widget.customTitle!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : appIconName(
                                  context: context,
                                  firstName: "Lab",
                                  secondName: "Ledger",
                                  fontSize: 35,
                                ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanStart: (_) => windowManager.startDragging(),
                      child: Padding(
                        padding: EdgeInsets.only(top: defaultPadding / 2),
                        child: Center(child: widget.centerWidget),
                      ),
                    ),
                  ),
                  if (!isFullScreen)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _WindowControlButton(
                          icon: LucideIcons.minus,
                          onPressed: () => windowManager.minimize(),
                          tooltip: 'Minimize',
                          iconColor: _iconColor,
                          hoverColor: _hoverColor,
                          isClose: false,
                        ),
                        _WindowControlButton(
                          icon: isMaximized
                              ? LucideIcons.copy
                              : LucideIcons.square,
                          onPressed: _handleMaximizeRestore,
                          tooltip: isMaximized ? 'Restore Down' : 'Maximize',
                          iconColor: _iconColor,
                          hoverColor: _hoverColor,
                          isClose: false,
                        ),
                        _WindowControlButton(
                          icon: LucideIcons.x,
                          onPressed: () => windowManager.close(),
                          tooltip: 'Close',
                          iconColor: _iconColor,
                          hoverColor: _hoverColor,
                          isClose: true,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (!isFullScreen) SizedBox(height: widget.spaceAfterRow ?? 7),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                child: widget.enableSlideTransition
                    ? SlideTransition(
                        position: _slideAnimation,
                        child: widget.child,
                      )
                    : widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color iconColor;
  final Color hoverColor;
  final bool isClose;

  const _WindowControlButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    required this.iconColor,
    required this.hoverColor,
    required this.isClose,
  });

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: 46,
            height: 50,
            color: _isHovered
                ? (widget.isClose ? const Color(0xFFE81123) : widget.hoverColor)
                : Colors.transparent,
            child: Icon(
              widget.icon,
              size: 16,
              color: _isHovered && widget.isClose
                  ? Colors.white
                  : widget.iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
