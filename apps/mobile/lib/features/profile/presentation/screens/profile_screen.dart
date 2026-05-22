import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/core/widgets/tour_item.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/section_header.dart';
import 'package:mobile/shared/widgets/settings_group.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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
          tabIndex: 2,
          order: 0,
          title: 'Your Profile',
          description: 'View and manage your account details here.',
          child: const Text('Profile'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.surfaceGradient(brightness),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
          children: [
            TourItem(
              tabIndex: 2,
              order: 1,
              title: 'Profile Picture',
              description:
                  'Your avatar is generated from your name initial. '
                  'Tap to customize in a future update.',
              child: AppCard(
                radius: AppRadii.cardLarge,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s24),
                child: Column(
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        gradient: AppGradients.buttonGradient(brightness),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border(brightness),
                          width: 1,
                        ),
                        boxShadow: AppShadows.floating(brightness),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: AppColors.elevated(brightness),
                        backgroundImage: user?.image != null
                            ? NetworkImage(user!.image!)
                            : null,
                        child: user?.image == null
                            ? Text(
                                (user?.name.isNotEmpty == true)
                                    ? user!.name[0].toUpperCase()
                                    : '?',
                                style:
                                    theme.textTheme.headlineLarge?.copyWith(
                                  color: AppColors.primary(brightness),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Text(
                      user?.name ?? 'Unknown',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      user?.email ?? '',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.secondaryText(brightness),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            TourItem(
              tabIndex: 2,
              order: 2,
              title: 'Account Details',
              description: 'View your account information at a glance.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Account Information'),
                  SettingsGroup(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.badge_outlined,
                          color: AppColors.primary(brightness),
                        ),
                        title: const Text('User ID'),
                        subtitle: Text(
                          user?.id ?? '—',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: AppColors.secondaryText(brightness),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.email_outlined,
                          color: AppColors.primary(brightness),
                        ),
                        title: const Text('Email'),
                        subtitle: Text(user?.email ?? '—'),
                        trailing: user?.emailVerified == true
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.border(brightness),
                                    width: 0.5,
                                  ),
                                  borderRadius: AppRadii.pillRadius,
                                ),
                                child: Text(
                                  'Verified',
                                  style: theme.textTheme.labelSmall,
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error
                                      .withOpacity(0.12),
                                  borderRadius: AppRadii.pillRadius,
                                ),
                                child: Text(
                                  'Unverified',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.primary(brightness),
                        ),
                        title: const Text('Member Since'),
                        subtitle: Text(
                          user?.createdAt != null
                              ? _formatDate(user!.createdAt!)
                              : '—',
                        ),
                      ),
                      if (user?.updatedAt != null)
                        ListTile(
                          leading: Icon(
                            Icons.update_outlined,
                            color: AppColors.primary(brightness),
                          ),
                          title: const Text('Last Updated'),
                          subtitle: Text(_formatDate(user!.updatedAt!)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
