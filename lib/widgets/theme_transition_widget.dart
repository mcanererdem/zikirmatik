import 'package:flutter/material.dart';
import '../models/theme_model.dart';

class ThemeTransitionContainer extends StatelessWidget {
  final Widget child;
  final ThemeConfig theme;
  final bool isTransitioning;

  const ThemeTransitionContainer({
    Key? key,
    required this.child,
    required this.theme,
    this.isTransitioning = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isTransitioning) {
      return ThemeTransitionWidget(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
        child: Container(
          decoration: BoxDecoration(
            gradient: theme.backgroundGradient,
          ),
          child: child,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: theme.backgroundGradient,
      ),
      child: child,
    );
  }
}

class ThemeTransitionWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const ThemeTransitionWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOutCubic,
  }) : super(key: key);

  @override
  State<ThemeTransitionWidget> createState() => _ThemeTransitionWidgetState();
}

class _ThemeTransitionWidgetState extends State<ThemeTransitionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5, curve: widget.curve),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}
