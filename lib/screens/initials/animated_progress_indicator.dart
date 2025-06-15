import 'package:flutter/material.dart';

class AnimatedLabProgressIndicator extends StatefulWidget {
  const AnimatedLabProgressIndicator({super.key});

  @override
  State<AnimatedLabProgressIndicator> createState() =>
      _AnimatedLabProgressIndicatorState();
}

class _AnimatedLabProgressIndicatorState
    extends State<AnimatedLabProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  final Color blue = const Color(0xFF0072B5);
  final Color green = const Color(0xFF1AA260);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // loops back and forth

    _colorAnimation = ColorTween(begin: blue, end: green).animate(_controller);
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
          valueColor: AlwaysStoppedAnimation<Color>(_colorAnimation.value!),
        );
      },
    );
  }
}
