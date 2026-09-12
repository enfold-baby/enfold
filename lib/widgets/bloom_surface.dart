import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Shared warm surface for Enfold cards and interactive panels.
class BloomSurface extends StatelessWidget {
  const BloomSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.color,
    this.borderColor,
    this.radius = 24,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final resolvedColor = color ?? AppColors.cardSurface(brightness);
    final resolvedBorder =
        borderColor ??
        (brightness == Brightness.dark
            ? AppColors.nightLine
            : AppColors.bark.withValues(alpha: 0.08));
    final borderRadius = BorderRadius.circular(radius);

    final content = Material(
      color: resolvedColor,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: resolvedBorder),
          ),
          child: child,
        ),
      ),
    );

    final wrapped = semanticLabel == null
        ? content
        : Semantics(
            button: onTap != null || onLongPress != null,
            label: semanticLabel,
            child: content,
          );

    if (margin == null) return wrapped;
    return Padding(padding: margin!, child: wrapped);
  }
}
