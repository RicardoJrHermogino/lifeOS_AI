import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/navigation/app_router.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/shared/widgets/app_button.dart';
import 'package:mobile/shared/widgets/lifeos_mark.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authStateProvider.notifier)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    final authState = ref.read(authStateProvider);
    if (authState.hasError) {
      if (!context.mounted) return;

      final error = authState.error;
      String message;
      if (error is DioException) {
        final data = error.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          message = data['message'].toString();
        } else {
          message =
              error.response?.statusMessage ??
              error.message ??
              'Unknown network error';
        }
      } else {
        message = error.toString();
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Sign In Failed',
              message: message,
              contentType: ContentType.failure,
            ),
          ),
        );
    } else if (authState.hasValue && authState.value != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Welcome back!',
              message: 'You have signed in successfully.',
              contentType: ContentType.success,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.surfaceGradient(brightness),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -170,
              left: -110,
              right: -110,
              height: 440,
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: AppGradients.ambientGlow),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 96),
                  child: Form(
                    key: _formKey,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -44),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 62,
                                      height: 62,
                                      decoration: BoxDecoration(
                                        gradient: AppGradients.cardGradient(
                                          brightness,
                                        ),
                                        border: Border.all(
                                          color: AppColors.border(brightness),
                                          width: 0.7,
                                        ),
                                        borderRadius: BorderRadius.circular(22),
                                        boxShadow: AppShadows.card(brightness),
                                      ),
                                      child: LifeOsMark(
                                        size: 40,
                                        onDarkBackground:
                                            brightness == Brightness.dark,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.s24),
                                  Text(
                                    'Welcome Back\nto LifeOS',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          height: 1.05,
                                          color: AppColors.primary(brightness),
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppSpacing.s24),
                                  _AuthTextField(
                                    controller: _emailController,
                                    label: 'E-mail',
                                    hint: 'hello@lifeos.ai',
                                    icon: Icons.mail_outline_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.email],
                                    brightness: brightness,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Email is required';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.s12),
                                  _AuthTextField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    brightness: brightness,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password is required';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                    onFieldSubmitted: (_) => _handleSignIn(),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            AppColors.secondaryText(brightness),
                                        textStyle: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      child: const Text('Forgot password?'),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.s4),
                                  AppButton(
                                    onPressed: isLoading ? null : _handleSignIn,
                                    isLoading: isLoading,
                                    child: const Text('Log in'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(4, (index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  child: _MemoryTile(
                                    index: index,
                                    brightness: brightness,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'New to LifeOS?',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText(brightness),
                        ),
                      ),
                      AppTextButton(
                        onPressed: () => context.push(AppRoutes.register),
                        child: const Text('Sign up'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.brightness,
    this.hint,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = AppColors.secondaryText(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18, bottom: 5),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.elevated(brightness),
            border: Border.all(color: AppColors.border(brightness), width: 0.7),
            borderRadius: BorderRadius.circular(26),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            validator: validator,
            onFieldSubmitted: onFieldSubmitted,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.primary(brightness),
              fontWeight: FontWeight.w500,
            ),
            cursorColor: AppColors.accent(brightness),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: secondary, size: 18),
              suffixIcon: suffixIcon == null
                  ? null
                  : IconTheme(
                      data: IconThemeData(color: secondary, size: 18),
                      child: suffixIcon!,
                    ),
              border: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 15,
              ),
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: secondary.withValues(alpha: 0.65),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MemoryTile extends StatelessWidget {
  const _MemoryTile({required this.index, required this.brightness});

  final int index;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.midnightIndigo,
      AppColors.deepTeal,
      AppColors.softAmber,
      AppColors.blushRose,
    ];

    return Transform.rotate(
      angle: index.isEven ? -0.08 : 0.07,
      child: Container(
        width: 48,
        height: 56,
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            colors[index].withValues(alpha: 0.16),
            AppColors.elevated(brightness),
          ),
          border: Border.all(color: AppColors.border(brightness), width: 0.7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colors[index].withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
