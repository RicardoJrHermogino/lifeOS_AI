import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/theme/app_styles.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final bool elevated;
  final double? radius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.onTap,
    this.margin = EdgeInsets.zero,
    this.elevated = true,
    this.radius,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (widget.onTap != null) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isTappable = widget.onTap != null;
    final borderRadius = widget.radius != null
        ? BorderRadius.circular(widget.radius!)
        : AppRadii.cardRadius;

    final innerDecoration = BoxDecoration(
      gradient: AppGradients.cardGradient(brightness),
      border: Border.all(color: AppColors.border(brightness), width: 0.5),
      borderRadius: borderRadius,
    );

    Widget inner = Container(
      decoration: innerDecoration,
      child: Padding(padding: widget.padding, child: widget.child),
    );

    if (widget.elevated) {
      inner = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: inner,
        ),
      );
    } else {
      inner = ClipRRect(borderRadius: borderRadius, child: inner);
    }

    Widget content = AnimatedContainer(
      duration: AppMotion.durationFast,
      curve: AppMotion.enterCurve,
      margin: widget.margin,
      transform: _isPressed
          ? Matrix4.diagonal3Values(0.98, 0.98, 1)
          : Matrix4.identity(),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: widget.elevated && !_isPressed
            ? AppShadows.card(brightness)
            : null,
      ),
      child: inner,
    );

    if (isTappable) {
      return GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
