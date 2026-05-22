import 'package:flutter/material.dart';
import '../../core/theme/app_styles.dart';

class AppButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isSecondary;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isSecondary = false,
    this.isLoading = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (widget.onPressed == null || widget.isLoading) return;
    if (_isPressed != value) setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final enabled = widget.onPressed != null && !widget.isLoading;
    final accent = AppColors.accent(brightness);

    final foreground = widget.isSecondary
        ? AppColors.primary(brightness)
        : AppColors.onAccent(brightness);

    final gradient = widget.isSecondary
        ? AppGradients.surfaceGradient(brightness)
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent,
              Color.alphaBlend(
                AppColors.primaryText.withValues(alpha: 0.18),
                accent,
              ),
            ],
          );

    final border = widget.isSecondary
        ? Border.all(
            color: enabled
                ? accent.withValues(
                    alpha: brightness == Brightness.dark ? 0.28 : 0.18,
                  )
                : AppColors.border(brightness),
            width: 1,
          )
        : null;

    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: enabled ? widget.onPressed : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: AppMotion.durationFast,
          curve: AppMotion.springCurve,
          child: AnimatedContainer(
            duration: AppMotion.durationFast,
            curve: AppMotion.enterCurve,
            height: 56,
            decoration: BoxDecoration(
              gradient: enabled
                  ? gradient
                  : LinearGradient(
                      colors: [
                        AppColors.border(brightness),
                        AppColors.border(brightness),
                      ],
                    ),
              border: border,
              borderRadius: AppRadii.pillRadius,
              boxShadow: enabled && !_isPressed
                  ? AppShadows.button(brightness)
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s32),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foreground,
                      ),
                    )
                  : DefaultTextStyle(
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w600,
                      ),
                      child: IconTheme(
                        data: IconThemeData(color: foreground, size: 20),
                        child: widget.child,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const AppTextButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
        textStyle: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      child: child,
    );
  }
}
