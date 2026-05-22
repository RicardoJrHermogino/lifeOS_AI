import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/theme/app_styles.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final bool autofocus;
  final String? hintText;
  final int? minLines;
  final int? maxLines;

  const AppTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
    this.autofocus = false,
    this.hintText,
    this.minLines,
    this.maxLines,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final primary = AppColors.primary(brightness);
    final secondary = AppColors.secondaryText(brightness);
    final accent = AppColors.accent(brightness);
    final fill = AppColors.elevated(brightness);

    Color borderColor = AppColors.border(brightness);
    double borderWidth = 0.5;
    if (_errorText != null) {
      borderColor = theme.colorScheme.error;
      borderWidth = 1.2;
    } else if (_isFocused) {
      borderColor = accent;
      borderWidth = 1.2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: AppMotion.durationFast,
          curve: AppMotion.enterCurve,
          decoration: BoxDecoration(
            borderRadius: AppRadii.inputRadius,
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: accent.withValues(
                        alpha: brightness == Brightness.dark ? 0.24 : 0.12,
                      ),
                      blurRadius: 24,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: AppRadii.inputRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: AppRadii.inputRadius,
                  border: Border.all(color: borderColor, width: borderWidth),
                ),
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  autofillHints: widget.autofillHints,
                  minLines: widget.minLines,
                  maxLines: widget.obscureText
                      ? 1
                      : (widget.maxLines ?? widget.minLines ?? 1),
                  onChanged: widget.onChanged,
                  style: theme.textTheme.bodyLarge?.copyWith(color: primary),
                  cursorColor: accent,
                  decoration: InputDecoration(
                    labelText: widget.labelText,
                    hintText: widget.hintText,
                    filled: false,
                    prefixIcon: widget.prefixIcon != null
                        ? IconTheme(
                            data: IconThemeData(
                              color: _isFocused ? accent : secondary,
                              size: 20,
                            ),
                            child: widget.prefixIcon!,
                          )
                        : null,
                    suffixIcon: widget.suffixIcon != null
                        ? IconTheme(
                            data: IconThemeData(
                              color: _isFocused ? accent : secondary,
                              size: 20,
                            ),
                            child: widget.suffixIcon!,
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s20,
                      vertical: AppSpacing.s16,
                    ),
                    floatingLabelStyle: theme.textTheme.labelMedium?.copyWith(
                      color: _errorText != null
                          ? theme.colorScheme.error
                          : accent,
                    ),
                    labelStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: secondary,
                    ),
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: secondary,
                    ),
                    errorStyle: const TextStyle(height: 0, fontSize: 0),
                  ),
                  validator: (value) {
                    String? error;
                    if (widget.validator != null) {
                      error = widget.validator!(value);
                    }
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _errorText != error) {
                        setState(() => _errorText = error);
                      }
                    });
                    return error;
                  },
                  onFieldSubmitted: widget.onFieldSubmitted,
                ),
              ),
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: _errorText != null ? 1.0 : 0.0,
          duration: AppMotion.durationFast,
          curve: AppMotion.enterCurve,
          child: AnimatedSize(
            duration: AppMotion.durationFast,
            curve: AppMotion.enterCurve,
            alignment: Alignment.topCenter,
            child: _errorText != null
                ? Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: AppSpacing.s20,
                    ),
                    child: Text(
                      _errorText!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ),
      ],
    );
  }
}
