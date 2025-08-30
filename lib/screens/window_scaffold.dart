// Global ValueNotifier (put this in your main.dart)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:window_manager/window_manager.dart';

final ValueNotifier<bool> isLoginScreen = ValueNotifier<bool>(false);

// Enhanced WindowScaffold with F11 support
class WindowScaffold extends StatefulWidget {
  final Widget child;
  final bool showAppName;
  final String? customTitle;
  final List<Widget>? additionalActions;
  final bool allowFullScreen;
  final bool isInitialScreen; // New parameter to handle first-time centering

  const WindowScaffold({
    super.key,
    required this.child,
    this.showAppName = true,
    this.customTitle,
    this.additionalActions,
    this.allowFullScreen = true,
    this.isInitialScreen = false, // Default to false
  });

  @override
  State<WindowScaffold> createState() => _WindowScaffoldState();
}

class _WindowScaffoldState extends State<WindowScaffold> with WindowListener {
  bool isMaximized = false;
  bool isFullScreen = false;
  late ThemeData currentTheme;
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    _initializeWindow();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    focusNode.dispose();
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
    
    // If this is the initial screen after login/loading, do comprehensive setup
    if (widget.isInitialScreen) {
      await _setupMainAppWindow();
    }
    
    isMaximized = await windowManager.isMaximized();
    isFullScreen = await windowManager.isFullScreen();
    if (mounted) setState(() {});
  }

  // Comprehensive window setup for first main app screen
  Future<void> _setupMainAppWindow() async {
    try {
      
      // Step 1: Reset any existing state
      if (await windowManager.isMaximized()) {
        await windowManager.unmaximize();
        await Future.delayed(const Duration(milliseconds: 150));
      }
      
      if (await windowManager.isFullScreen()) {
        await windowManager.setFullScreen(false);
        await Future.delayed(const Duration(milliseconds: 150));
      }
      
      // Step 2: Update window behavior for main app
      await windowManager.setSkipTaskbar(false);
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Step 3: Set size constraints that allow maximize
      await windowManager.setMinimumSize(const Size(800, 600));
      await windowManager.setMaximumSize(const Size(4000, 3000));
      await Future.delayed(const Duration(milliseconds: 150));
      
      // Step 4: Set target size
      await windowManager.setSize(const Size(1600, 900));
      await Future.delayed(const Duration(milliseconds: 300)); // Longer delay
      
      // Step 5: Aggressive centering sequence
      for (int i = 0; i < 5; i++) {
        await windowManager.center();
        await Future.delayed(const Duration(milliseconds: 150));
        
        // Check if centered correctly
        final position = await windowManager.getPosition();
        
        // If position looks reasonable, break early
        if (position.dx > 0 && position.dy > 0 && position.dx < 1000) {
          break;
        }
      }
      
      // Step 6: Final operations
      await windowManager.show();
      await windowManager.focus();
      
      // Update the global login screen state
      isLoginScreen.value = false;
      
      
    } catch (e) {
      // Fallback
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
  void onWindowEnterFullScreen() {
    if (mounted) {
      setState(() {
        isFullScreen = true;
      });
    }
  }

  @override
  void onWindowLeaveFullScreen() {
    if (mounted) {
      setState(() {
        isFullScreen = false;
      });
    }
  }

  Future<void> _handleMaximizeRestore() async {
    if (isMaximized) {
      await windowManager.unmaximize();
      // Use improved centering logic when restoring
      await Future.delayed(const Duration(milliseconds: 100));
      await _setCenterWindow(const Size(1600, 900), animate: true);
    } else {
      await windowManager.maximize();
    }
  }

  Future<void> _handleKeyEvent(KeyEvent event) async {
    if (!widget.allowFullScreen) return; // Block F11 on login/loading screens
    
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
      }
    }
  }
  // Add this method to your _WindowScaffoldState class

Future<void> _setCenterWindow(Size size, {bool animate = false}) async {
  try {
    // Step 1: Set the window size first
    await windowManager.setSize(size);
    
    // Step 2: Add a delay if animation is requested for smoother transition
    if (animate) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // Step 3: Center the window
    await windowManager.center();
    
    // Step 4: If animation is requested, perform multiple centering attempts
    // to ensure proper positioning (especially useful on multi-monitor setups)
    if (animate) {
      // Multiple centering attempts for better reliability
      for (int i = 0; i < 3; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        await windowManager.center();
      }
    }
    
    // Step 5: Ensure the window is visible and focused
    await windowManager.show();
    await windowManager.focus();
    
    
  } catch (e) {
    // Fallback: Just try to center without size change
    try {
      await windowManager.center();
    } catch (fallbackError) {
      //
    }
  }
}

// Alternative implementation with more control over positioning
// Future<void> _setCenterWindowAdvanced(Size size, {bool animate = false}) async {
//   try {
//     // Get screen dimensions using window_manager
//     final bounds = await windowManager.getBounds();
    
//     // Set the size first
//     await windowManager.setSize(size);
    
//     if (animate) {
//       await Future.delayed(const Duration(milliseconds: 100));
//     }
    
//     // Method 1: Use built-in center function
//     await windowManager.center();
    
//     // Method 2: If you need manual positioning (uncomment if needed)
//     /*
//     // Get the primary monitor size (you might need to use a platform channel for this)
//     // For now, we'll use approximate values or get from system
    
//     // Example manual centering (adjust these values based on your screen)
//     const screenWidth = 1920.0;  // Replace with actual screen width
//     const screenHeight = 1080.0; // Replace with actual screen height
    
//     final left = (screenWidth - size.width) / 2;
//     final top = (screenHeight - size.height) / 2;
    
//     await windowManager.setPosition(Offset(left, top));
//     */
    
//     // Additional centering attempts for reliability
//     if (animate) {
//       for (int i = 0; i < 2; i++) {
//         await Future.delayed(const Duration(milliseconds: 75));
//         await windowManager.center();
//       }
//     }
    
//     // Ensure window is in the correct state
//     if (await windowManager.isMinimized()) {
//       await windowManager.restore();
//     }
    
//     await windowManager.show();
//     await windowManager.focus();
    
//     print('Window centered successfully to ${size.width}x${size.height}');
    
//   } catch (e) {
//     print('Error in advanced centering: $e');
//     // Simple fallback
//     await windowManager.center();
//   }
// }

// Helper method to get screen dimensions (if needed)
// Future<Size?> _getScreenSize() async {
//   try {
//     // Note: window_manager doesn't directly provide screen size
//     // You might need to use additional packages or platform channels
//     // This is a placeholder that returns null
    
//     // Option 1: Use desktop_window package additionally
//     // Option 2: Use platform channels to get native screen size
//     // Option 3: Use screen_retriever package
    
//     return null; // Placeholder
//   } catch (e) {
//     print('Could not get screen size: $e');
//     return null;
//   }
// }

  Color get _titleBarColor => currentTheme.brightness == Brightness.dark
      ? const Color(0xFF2D2D30)
      : Colors.white;

  Color get _borderColor => currentTheme.brightness == Brightness.dark
      ? const Color(0xFF3E3E42)
      : Colors.grey.withValues(alpha:  0.2);

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
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        body: Column(
          children: [
            // Hide title bar in fullscreen mode
            if (!isFullScreen)
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: _titleBarColor,
                  border: Border(
                    bottom: BorderSide(
                      color: _borderColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Left side - App name or custom title
                    if (widget.showAppName || widget.customTitle != null)
                      Expanded(
                        child: GestureDetector(
                          onPanStart: (details) {
                            windowManager.startDragging();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
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
                                    firstName: " Lab",
                                    secondName: "Ledger",
                                    fontSize: 24,
                                  ),
                          ),
                        ),
                      ),
                    
                    // Center - Additional actions if provided
                    if (widget.additionalActions != null)
                      Row(children: widget.additionalActions!),
                    
                    // Spacer if no app name
                    if (!widget.showAppName && widget.customTitle == null)
                      Expanded(
                        child: GestureDetector(
                          onPanStart: (details) {
                            windowManager.startDragging();
                          },
                          child: Container(),
                        ),
                      ),
                    
                    // Window controls on the right
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Minimize button
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
                        // Maximize/Restore button
                        _WindowControlButton(
                          icon: isMaximized ? LucideIcons.copy : LucideIcons.square,
                          onPressed: _handleMaximizeRestore,
                          tooltip: isMaximized ? 'Restore Down' : 'Maximize',
                          iconColor: _iconColor,
                          hoverColor: _hoverColor,
                          isClose: false,
                        ),
                        // Close button
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
            // Your content
            Expanded(child: widget.child),
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
                  ? (widget.isClose 
                      ? const Color(0xFFE81123)
                      : widget.hoverColor)
                  : Colors.transparent,
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: isHovered && widget.isClose
                  ? Colors.white
                  : widget.iconColor,
            ),
          ),
        ),
      ),
    );
  }
}