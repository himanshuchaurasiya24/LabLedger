import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:window_manager/window_manager.dart';

final ValueNotifier<bool> isLoginScreen = ValueNotifier<bool>(false);

class WindowScaffold extends StatefulWidget {
  final Widget child;
  final bool showAppName;
  final String? customTitle;
  final Widget? centerWidget; // For implementing a search bar or other actions
  final bool allowFullScreen;
  final bool isInitialScreen;
  final double? spaceAfterRow;
  final bool enableSlideTransition; // New parameter to control transition
  
  const WindowScaffold({
    super.key,
    required this.child,
    this.showAppName = true,
    this.customTitle,
    this.centerWidget,
    this.allowFullScreen = true,
    this.isInitialScreen = false,
    this.spaceAfterRow,
    this.enableSlideTransition = true, // Default to true
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
    
    // Initialize slide animation controller with variable duration
    final Duration slideDuration = widget.isInitialScreen 
        ? const Duration(milliseconds: 2000)  // 2 seconds for initial screen
        : const Duration(milliseconds: 1000);  // 500ms for other screens
    
    _slideController = AnimationController(
      duration: slideDuration,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start from right
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: widget.isInitialScreen 
          ? Curves.easeInOutCubic  // Smoother curve for longer animation
          : Curves.easeOutCubic,   // Standard curve for shorter animation
    ));
    
    // Start the slide animation when widget is built
    if (widget.enableSlideTransition) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _slideController.forward();
      });
    } else {
      _slideController.value = 1.0; // Skip animation
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
      await Future.delayed(const Duration(milliseconds: 100));

      await windowManager.setMinimumSize(const Size(800, 600));
      await windowManager.setMaximumSize(const Size(4000, 3000));
      await Future.delayed(const Duration(milliseconds: 150));

      await windowManager.setSize(const Size(1600, 900));
      await Future.delayed(const Duration(milliseconds: 300));

      for (int i = 0; i < 5; i++) {
        await windowManager.center();
        await Future.delayed(const Duration(milliseconds: 150));

        final position = await windowManager.getPosition();

        if (position.dx > 0 && position.dy > 0 && position.dx < 1000) {
          break;
        }
      }

      await windowManager.show();
      await windowManager.focus();

      isLoginScreen.value = false;
    } catch (e) {
      await windowManager.center();
    }
  }

  @override
  void onWindowMaximize() {
    if (mounted) {
      setState(() {
        isMaximized = true;
      });
    }
  }

  @override
  void onWindowUnmaximize() {
    if (mounted) {
      setState(() {
        isMaximized = false;
      });
    }
  }

  @override
  void onWindowEnterFullScreen() async {
    final state = await windowManager.isFullScreen();
    if (mounted) setState(() => isFullScreen = state);
  }

  @override
  void onWindowLeaveFullScreen() async {
    final state = await windowManager.isFullScreen();
    if (mounted) setState(() => isFullScreen = state);
  }

  Future<void> _handleKeyEvent(KeyEvent event) async {
    if (!widget.allowFullScreen) return;

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape && isFullScreen) {
        await windowManager.setFullScreen(false);
      }
      if (event.logicalKey == LogicalKeyboardKey.f11) {
        await windowManager.setFullScreen(!isFullScreen);
      }

      // ✅ Always check actual state after toggle
      final state = await windowManager.isFullScreen();
      if (mounted) setState(() => isFullScreen = state);
    }
  }

  /// **FIXED**: This function is now simpler and more reliable.
  /// It avoids conflicts with the OS's native window handling.
  Future<void> _handleMaximizeRestore() async {
    if (await windowManager.isMaximized()) {
      windowManager.unmaximize();
    } else {
      windowManager.maximize();
    }
  }

  // Handle back button with slide out animation (fast duration)
  Future<void> _handleBackButton() async {
    if (widget.enableSlideTransition && Navigator.of(context).canPop()) {
      final originalDuration = _slideController.duration;
      _slideController.duration = const Duration(milliseconds: 30); // Fast reverse
      
      // Reverse the animation (slides from center to left)
      await _slideController.reverse();
      
      // Restore original duration for next use (though this instance will be disposed)
      _slideController.duration = originalDuration;
    }
    
    // Pop the route
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop();
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (!widget.isInitialScreen) // ✅ Only show back button if not the initial screen
                        GestureDetector(
                          onTap: _handleBackButton, // Updated to use new method
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            color: Colors.transparent,
                            child: Icon(
                              CupertinoIcons.back,
                              size: 35,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),

                      // Title or app name (draggable)
                      GestureDetector(
                        onPanStart: (details) {
                          windowManager.startDragging();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: widget.customTitle != null
                              ? Text(
                                  widget.customTitle!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: currentTheme.brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
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

                  // Center - Draggable area with the centerWidget
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            // **FIXED**: Ensures drag events are caught in empty space
                            // without interfering with other widgets.
                            behavior: HitTestBehavior.translucent,
                            onPanStart: (details) => windowManager.startDragging(),
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                        if (widget.centerWidget != null)
                          Center(child: widget.centerWidget!),
                      ],
                    ),
                  ),

                  // Window control buttons are only shown when not in fullscreen
                  if (!isFullScreen)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _WindowControlButton(
                          icon: LucideIcons.minus,
                          onPressed: () async {
                            await windowManager.minimize();
                          },
                          tooltip: 'Minimize',
                          iconColor: _iconColor,
                          hoverColor: _hoverColor,
                          isClose: false,
                        ),
                        _WindowControlButton(
                          icon: isMaximized ? LucideIcons.copy : LucideIcons.square,
                          onPressed: _handleMaximizeRestore,
                          tooltip: isMaximized ? 'Restore Down' : 'Maximize',
                          iconColor: _iconColor,
                          hoverColor: _hoverColor,
                          isClose: false,
                        ),
                        _WindowControlButton(
                          icon: LucideIcons.x,
                          onPressed: () async {
                            await windowManager.close();
                          },
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
            SizedBox(height: widget.spaceAfterRow ?? 7),
            
            // Your app's main content with slide transition
            Expanded(
              child: widget.enableSlideTransition
                  ? SlideTransition(
                      position: _slideAnimation,
                      child: widget.child,
                    )
                  : widget.child,
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
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: 46,
            height: 50,
            decoration: BoxDecoration(
              color: isHovered
                  ? (widget.isClose ? const Color(0xFFE81123) : widget.hoverColor)
                  : Colors.transparent,
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: isHovered && widget.isClose ? Colors.white : widget.iconColor,
            ),
          ),
        ),
      ),
    );
  }
}