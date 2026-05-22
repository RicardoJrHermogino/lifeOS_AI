import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/core/widgets/tour_item.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/shared/widgets/app_card.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TourItem(
          tabIndex: 0,
          order: 0,
          title: 'Welcome!',
          description:
              'This is your personalized dashboard with a greeting '
              'and account overview.',
          child: const Text('Home'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.surfaceGradient(brightness),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user?.name ?? 'there'}!',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.0,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'Welcome to Turbo Template',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.secondaryText(brightness),
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),
                TourItem(
                  tabIndex: 0,
                  order: 1,
                  title: 'Your Email',
                  description: 'View your registered email address here.',
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.s8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                        vertical: AppSpacing.s8,
                      ),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppGradients.buttonGradient(brightness),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border(brightness),
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                          Icons.email_outlined,
                          color: AppColors.primary(brightness),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Email',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        user?.email ?? '—',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText(brightness),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                TourItem(
                  tabIndex: 0,
                  order: 2,
                  title: 'Member Since',
                  description: 'See when you joined the platform.',
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.s8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                        vertical: AppSpacing.s8,
                      ),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppGradients.buttonGradient(brightness),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border(brightness),
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.primary(brightness),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Member Since',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        user?.createdAt != null
                            ? _formatDate(user!.createdAt!)
                            : '—',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText(brightness),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
