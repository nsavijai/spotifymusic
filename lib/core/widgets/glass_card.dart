import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_radius.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blur = 12,
    this.opacity = 0.15,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double blur;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.lg),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.child,
    required this.colors,
    this.padding,
    this.borderRadius,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  final Widget child;
  final List<Color> colors;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Alignment begin;
  final Alignment end;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.lg),
        gradient: LinearGradient(colors: colors, begin: begin, end: end),
      ),
      child: child,
    );
  }
}
