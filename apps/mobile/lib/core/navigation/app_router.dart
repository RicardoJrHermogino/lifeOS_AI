import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:mobile/features/home/presentation/screens/home_screen.dart';
import 'package:mobile/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:mobile/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Named route paths used across the app.
class AppRoutes {
  AppRoutes._();

  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const home = '/';
}

/// Provides the [GoRouter] instance configured with redirect logic
/// based on authentication and onboarding state.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refreshNotifier = ValueNotifier<int>(0);

  ref.listen(authStateProvider, (_, _) {
    refreshNotifier.value++;
  });
  ref.listen(hasCompletedOnboardingProvider, (_, _) {
    refreshNotifier.value++;
  });

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      if (authState.isLoading) return null;

      final isAuthenticated = authState.value != null;
      final isOnboardingDone = ref.read(hasCompletedOnboardingProvider);
      final isOnOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final isOnLogin = state.matchedLocation == AppRoutes.login;
      final isOnRegister = state.matchedLocation == AppRoutes.register;
      final isOnAuthRoute = isOnLogin || isOnRegister;

      if (!isAuthenticated) {
        return isOnAuthRoute ? null : AppRoutes.login;
      }

      if (!isOnboardingDone) {
        return isOnOnboarding ? null : AppRoutes.onboarding;
      }

      if (isOnOnboarding || isOnAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );

  ref.onDispose(() {
    refreshNotifier.dispose();
    router.dispose();
  });

  return router;
}
