import 'package:flutter/material.dart';

class AnimatedLabProgressIndicator extends StatefulWidget {
  const AnimatedLabProgressIndicator({
    super.key,
    this.firstColor,
    this.secondColor,
  });
  final Color? firstColor;
  final Color? secondColor;

  @override
  State<AnimatedLabProgressIndicator> createState() =>
      _AnimatedLabProgressIndicatorState();
}

class _AnimatedLabProgressIndicatorState
    extends State<AnimatedLabProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Color first;
  late Color second;

  // This method is fine, but we will call it from didChangeDependencies
  void getColor() {
    first =
        widget.firstColor ?? Theme.of(context).colorScheme.primary;
    second =
        widget.secondColor ?? Theme.of(context).colorScheme.secondary;
  }

  @override
  void initState() {
    super.initState();
    // Only initialize the controller here, since it doesn't depend on the theme.
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // loops back and forth
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // --- THIS IS THE FIX ---
    // Initialize all theme-dependent values here.
    // This runs after initState and has a valid context.
    getColor(); // Get the colors using the valid context

    _colorAnimation = ColorTween( // Now create the animation
      begin: first,
      end: second,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return LinearProgressIndicator(
          backgroundColor: Colors.transparent,
          // Use .value which might be null during the very first frame,
          // or provide a default. Using `!` is okay if controller is running.
          valueColor: AlwaysStoppedAnimation<Color>(_colorAnimation.value!),
        );
      },
    );
  }
}