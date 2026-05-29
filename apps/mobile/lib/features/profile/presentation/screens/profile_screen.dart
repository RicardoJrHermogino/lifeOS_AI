import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/core/theme/theme_provider.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/home/presentation/providers/home_tab_controller.dart';
import 'package:mobile/features/lifeos/data/settings_repository.dart';
import 'package:mobile/features/lifeos/presentation/providers/settings_controller.dart';
import 'package:mobile/features/support/presentation/screens/support_ticket_screen.dart';
import 'package:mobile/services/notifications/notification_service.dart';
import 'package:mobile/shared/widgets/lifeos_mark.dart';
import 'package:showcaseview/showcaseview.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final ShowcaseView _showcaseView;

  @override
  void initState() {
    super.initState();
    _showcaseView = ShowcaseView.register();
  }

  @override
  void dispose() {
    _showcaseView.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.surfaceGradient(brightness),
          ),
          child: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border(brightness),
                      borderRadius: AppRadii.pillRadius,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                _ProfileHeader(brightness: brightness),
                const SizedBox(height: AppSpacing.s20),
                _ProfileSummaryCard(user: user),
                const SizedBox(height: AppSpacing.s16),
                _AccountDetailsCard(user: user, formatDate: _formatDate),
                const SizedBox(height: AppSpacing.s16),
                _AccentActionTile(
                  title: 'Set up Memory Profile',
                  onTap: () => _showMemoryProfileSheet(context),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'Add context so LifeOS can organize memories around your goals, people, and routines.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText(brightness),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                _SectionCard(
                  children: [
                    _ReminderRow(),
                    _Divider(brightness: brightness),
                    _ThemeRow(
                      themeMode: themeMode,
                      onChanged: (mode) => ref
                          .read(themeControllerProvider.notifier)
                          .setThemeMode(mode),
                    ),
                    _Divider(brightness: brightness),
                    _InfoRow(
                      title: 'Privacy & Access',
                      subtitle: 'Export, deletion, and consent controls',
                      icon: Icons.shield_outlined,
                      onTap: _openPrivacyTab,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),
                _SectionCard(
                  children: [
                    _InfoRow(
                      title: 'Contact Support',
                      subtitle: 'Report an issue or ask a question',
                      icon: Icons.support_agent_rounded,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SupportTicketScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),
                _AccentActionTile(
                  title: 'Sign Out',
                  isDestructive: true,
                  onTap: _confirmSignOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openPrivacyTab() {
    ref.read(homeTabControllerProvider.notifier).setIndex(4);
    Navigator.of(context).pop();
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in with your account anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await ref.read(authStateProvider.notifier).signOut();
  }

  void _showMemoryProfileSheet(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceColor(brightness),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final settings = ref.watch(settingsControllerProvider);

          Future<void> patch(Map<String, dynamic> data) async {
            await ref.read(settingsControllerProvider.notifier).patch(data);
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: settings.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Memory Profile', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.s12),
                    Text('Could not load settings: $e'),
                  ],
                ),
                data: (s) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Memory Profile', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      'Tune how LifeOS uses your memories for reflections and insight.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText(brightness),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    _SheetSwitch(
                      title: 'Personalized reflections',
                      subtitle: 'Use saved memories to shape summaries.',
                      value: s.aiPersonalization,
                      onChanged: (v) => patch({'aiPersonalization': v}),
                    ),
                    _SheetSwitch(
                      title: 'Proactive insights',
                      subtitle: 'Surface patterns after enough memories exist.',
                      value: s.proactiveInsights,
                      onChanged: (v) => patch({'proactiveInsights': v}),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          ref
                              .read(homeTabControllerProvider.notifier)
                              .setIndex(0);
                          Navigator.of(context).pop();
                          Navigator.of(this.context).pop();
                        },
                        child: const Text('Go to Capture'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        LifeOsMark(size: 34, onDarkBackground: brightness == Brightness.dark),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: Text(
            'LifeOS Account',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary(brightness),
            ),
          ),
        ),
        Material(
          color: AppColors.elevated(brightness),
          shape: const CircleBorder(),
          child: IconButton(
            tooltip: 'Close',
            constraints: const BoxConstraints.tightFor(width: 42, height: 42),
            icon: const Icon(Icons.close_rounded, size: 22),
            color: AppColors.primary(brightness),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final initial = user?.name.isNotEmpty == true
        ? user!.name[0].toUpperCase()
        : user?.email.isNotEmpty == true
        ? user!.email[0].toUpperCase()
        : 'L';

    return _PlainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.softIndigo,
            backgroundImage: user?.image != null
                ? NetworkImage(user!.image!)
                : null,
            child: user?.image == null
                ? Text(
                    initial,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.midnightIndigo,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            user?.name ?? 'LifeOS user',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.primary(brightness),
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            'Account info and settings',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryText(brightness),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountDetailsCard extends StatelessWidget {
  const _AccountDetailsCard({required this.user, required this.formatDate});

  final dynamic user;
  final String Function(DateTime date) formatDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return _PlainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.primary(brightness),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          _DetailLine(label: 'User ID', value: user?.id ?? '-'),
          _DetailLine(label: 'Email', value: user?.email ?? '-'),
          _DetailLine(
            label: 'Member Since',
            value: user?.createdAt != null ? formatDate(user!.createdAt!) : '-',
          ),
          if (user?.updatedAt != null)
            _DetailLine(
              label: 'Last Updated',
              value: formatDate(user!.updatedAt!),
            ),
        ],
      ),
    );
  }
}

class _AccentActionTile extends StatelessWidget {
  const _AccentActionTile({
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return _PlainCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: isDestructive
              ? theme.colorScheme.error
              : AppColors.accent(brightness),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _PlainCard(
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: AppColors.accent(brightness), size: 22),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: AppColors.primary(brightness),
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.secondaryText(brightness),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.secondaryText(brightness),
        size: 24,
      ),
      onTap: onTap,
    );
  }
}

class _ReminderRow extends ConsumerWidget {
  const _ReminderRow();

  Future<void> _patch(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> data,
  ) async {
    try {
      await ref.read(settingsControllerProvider.notifier).patch(data);
      final updated = ref.read(settingsControllerProvider).value;
      if (updated != null) await _reconcileReminder(updated);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save: $e')));
    }
  }

  Future<void> _reconcileReminder(SettingsModel s) async {
    final svc = NotificationService.instance;
    final time = s.reminderTime;
    if (s.dailyReminder && time != null && time.contains(':')) {
      final parts = time.split(':');
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null && minute != null) {
        await svc.scheduleDailyReminder(hour: hour, minute: minute);
        return;
      }
    }
    await svc.cancelDailyReminder();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(settingsControllerProvider);
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return async.when(
      loading: () => const ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text('Notifications'),
        trailing: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (e, _) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(Icons.error_outline, color: theme.colorScheme.error),
        title: const Text('Notifications'),
        subtitle: Text('$e'),
      ),
      data: (s) => SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Icon(
          Icons.notifications_none_rounded,
          color: AppColors.accent(brightness),
          size: 22,
        ),
        title: Text(
          'Notifications',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.primary(brightness),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          s.dailyReminder ? 'Daily reminder is on' : 'Daily reminder is off',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.secondaryText(brightness),
          ),
        ),
        value: s.dailyReminder,
        onChanged: (v) => _patch(context, ref, {'dailyReminder': v}),
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({required this.themeMode, required this.onChanged});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    final label = switch (themeMode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        Icons.contrast_rounded,
        color: AppColors.accent(brightness),
        size: 22,
      ),
      title: Text(
        'Appearance',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: AppColors.primary(brightness),
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.secondaryText(brightness),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.secondaryText(brightness),
        size: 24,
      ),
      onTap: () => _showThemeSheet(context),
    );
  }

  void _showThemeSheet(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceColor(brightness),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Appearance', style: theme.textTheme.titleMedium),
              ),
              const SizedBox(height: AppSpacing.s12),
              _ThemeOption(
                label: 'System',
                value: ThemeMode.system,
                groupValue: themeMode,
                onChanged: onChanged,
              ),
              _ThemeOption(
                label: 'Light',
                value: ThemeMode.light,
                groupValue: themeMode,
                onChanged: onChanged,
              ),
              _ThemeOption(
                label: 'Dark',
                value: ThemeMode.dark,
                groupValue: themeMode,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String label;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final selected = value == groupValue;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_rounded, color: AppColors.accent(brightness))
          : null,
      onTap: () {
        onChanged(value);
        Navigator.of(context).pop();
      },
    );
  }
}

class _PlainCard extends StatelessWidget {
  const _PlainCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final radius = AppRadii.cardRadius;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: AppShadows.card(brightness),
          ),
          child: Ink(
            decoration: BoxDecoration(
              color: _profileCardColor(brightness),
              borderRadius: radius,
              border: Border.all(
                color: AppColors.border(brightness),
                width: 0.7,
              ),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }

  Color _profileCardColor(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return Color.alphaBlend(
        AppColors.warmStone.withValues(alpha: 0.08),
        AppColors.charcoal,
      );
    }

    return Color.alphaBlend(
      Colors.white.withValues(alpha: 0.84),
      AppColors.warmStone,
    );
  }
}

class _SheetSwitch extends StatelessWidget {
  const _SheetSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.secondaryText(brightness),
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Divider(
        height: 1,
        thickness: 0.6,
        color: AppColors.border(brightness),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.secondaryText(brightness),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.primary(brightness),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
