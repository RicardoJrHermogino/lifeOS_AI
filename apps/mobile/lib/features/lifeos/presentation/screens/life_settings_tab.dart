import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/core/theme/theme_provider.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/lifeos/data/exports_repository.dart';
import 'package:mobile/features/lifeos/data/settings_repository.dart';
import 'package:mobile/features/lifeos/presentation/providers/export_controller.dart';
import 'package:mobile/features/lifeos/presentation/providers/settings_controller.dart';
import 'package:mobile/shared/widgets/app_card.dart';

class LifeSettingsTab extends ConsumerWidget {
  const LifeSettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        title: const Text('Privacy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            AppCard(
              radius: AppRadii.cardLarge,
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppGradients.buttonGradient(brightness),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border(brightness),
                        width: 0.5,
                      ),
                      boxShadow: AppShadows.button(brightness),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      (user?.name.isNotEmpty == true)
                          ? user!.name[0].toUpperCase()
                          : 'L',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'LifeOS user',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          user?.email ?? 'Private memory account',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryText(brightness),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            _SettingsSection(
              title: 'Memory control',
              children: [
                _SettingsTile(
                  icon: Icons.visibility_outlined,
                  title: 'Transparent memory',
                  subtitle: 'Review what AI extracted before it becomes memory',
                  trailing: Switch(value: true, onChanged: (_) {}),
                ),
                _SettingsTile(
                  icon: Icons.download_outlined,
                  title: 'Export life data',
                  subtitle: 'Prepare memories, transcripts, and insights',
                  onTap: () => _startExport(context, ref),
                ),
                _SettingsTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Delete account',
                  subtitle: 'Remove all memories, captures, and reflections',
                  isDestructive: true,
                  onTap: () => _confirmDeleteAccount(context, ref),
                ),
              ],
            ),
            const _ExportStatusCard(),
            const SizedBox(height: AppSpacing.s20),
            const _SettingsControls(),
            const SizedBox(height: AppSpacing.s20),
            _SettingsSection(
              title: 'Appearance',
              children: [
                _ThemeModeRow(
                  label: 'System',
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  onChanged: (m) => ref
                      .read(themeControllerProvider.notifier)
                      .setThemeMode(m),
                ),
                _ThemeModeRow(
                  label: 'Light',
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: (m) => ref
                      .read(themeControllerProvider.notifier)
                      .setThemeMode(m),
                ),
                _ThemeModeRow(
                  label: 'Dark',
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: (m) => ref
                      .read(themeControllerProvider.notifier)
                      .setThemeMode(m),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s20),
            AppCard(
              padding: EdgeInsets.zero,
              onTap: () => ref.read(authStateProvider.notifier).signOut(),
              child: ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
                title: Text(
                  'Sign out',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => ref.read(authStateProvider.notifier).signOut(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    final divider = Container(height: 0.5, color: AppColors.border(brightness));

    final stitched = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      stitched.add(children[i]);
      if (i < children.length - 1) stitched.add(divider);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.s8),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.secondaryText(brightness),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: stitched),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.isDestructive = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool isDestructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final color = isDestructive
        ? theme.colorScheme.error
        : AppColors.accent(brightness);

    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.secondaryText(brightness),
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.secondaryText(brightness),
          ),
    );
  }
}

Future<void> _startExport(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(exportControllerProvider.notifier).request();
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
  }
}

/// Shows the live status of the most recent data-export request.
class _ExportStatusCard extends ConsumerWidget {
  const _ExportStatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final export = ref.watch(exportControllerProvider);
    if (export == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final expired =
        export.expiresAt != null && export.expiresAt!.isBefore(DateTime.now());
    final isReady = export.status == 'ready' && !expired;
    final isFailed = export.status == 'failed';

    IconData icon;
    String title;
    String subtitle;
    if (export.status == 'pending') {
      icon = Icons.hourglass_top_rounded;
      title = 'Preparing your export…';
      subtitle = 'This can take a moment. You can leave this screen.';
    } else if (isReady) {
      icon = Icons.check_circle_outline;
      title = 'Export ready';
      subtitle = export.expiresAt == null
          ? 'Your data is ready to download.'
          : 'Available until ${_formatExpiry(export.expiresAt!)}.';
    } else if (expired) {
      icon = Icons.link_off_rounded;
      title = 'Download link expired';
      subtitle = 'Request a new export to download your data.';
    } else {
      icon = Icons.error_outline;
      title = 'Export failed';
      subtitle = 'Something went wrong preparing your data.';
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s16),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (export.status == 'pending')
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    icon,
                    size: 20,
                    color: isFailed || expired
                        ? theme.colorScheme.error
                        : AppColors.accent(brightness),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleSmall),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText(brightness),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                if (isReady && export.downloadUrl != null)
                  FilledButton.icon(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy download link'),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: export.downloadUrl!),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Download link copied'),
                        ),
                      );
                    },
                  ),
                if (isFailed || expired)
                  FilledButton(
                    onPressed: () => _startExport(context, ref),
                    child: const Text('Request new export'),
                  ),
                TextButton(
                  onPressed: () =>
                      ref.read(exportControllerProvider.notifier).reset(),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatExpiry(DateTime d) {
  final local = d.toLocal();
  final mm = local.month.toString().padLeft(2, '0');
  final dd = local.day.toString().padLeft(2, '0');
  final hh = local.hour.toString().padLeft(2, '0');
  final min = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$mm-$dd $hh:$min';
}

Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete account?'),
      content: const Text(
        'This permanently removes your account and all memories. This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  final repo = ref.read(exportsRepositoryProvider);
  try {
    await repo.deleteAccount();
    await ref.read(authStateProvider.notifier).signOut();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }
}

/// Privacy, consent and AI-behavior controls backed by the settings API.
class _SettingsControls extends ConsumerWidget {
  const _SettingsControls();

  Future<void> _patch(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> data,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(settingsControllerProvider.notifier).patch(data);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not save: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(settingsControllerProvider);
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppCard(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Text(
          'Could not load settings: $e',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.secondaryText(brightness),
          ),
        ),
      ),
      data: (s) => Column(
        children: [
          _SettingsSection(
            title: 'Privacy & consent',
            children: [
              _SettingsTile(
                icon: Icons.shield_outlined,
                title: 'AI processing',
                subtitle: 'Allow AI to analyze captures into structured memories',
                trailing: Switch(
                  value: s.aiProcessingConsent,
                  onChanged: (v) =>
                      _patch(context, ref, {'aiProcessingConsent': v}),
                ),
              ),
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                title: 'App lock',
                subtitle: 'Require device authentication to open LifeOS',
                trailing: Switch(
                  value: s.appLock,
                  onChanged: (v) => _patch(context, ref, {'appLock': v}),
                ),
              ),
              _SettingsTile(
                icon: Icons.warning_amber_rounded,
                title: 'Sensitive topics',
                subtitle: s.sensitiveTopics.isEmpty
                    ? 'Topics to handle with extra care'
                    : s.sensitiveTopics.join(', '),
                onTap: () => _editSensitiveTopics(context, ref, s),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s20),
          _SettingsSection(
            title: 'AI behavior',
            children: [
              _SettingsTile(
                icon: Icons.tune_rounded,
                title: 'Personalization',
                subtitle: 'Tailor AI output to your past memories',
                trailing: Switch(
                  value: s.aiPersonalization,
                  onChanged: (v) =>
                      _patch(context, ref, {'aiPersonalization': v}),
                ),
              ),
              _SettingsTile(
                icon: Icons.lightbulb_outline_rounded,
                title: 'Proactive insights',
                subtitle: 'Surface patterns without being asked',
                trailing: Switch(
                  value: s.proactiveInsights,
                  onChanged: (v) =>
                      _patch(context, ref, {'proactiveInsights': v}),
                ),
              ),
              _SettingsTile(
                icon: Icons.record_voice_over_outlined,
                title: 'Reflection tone',
                subtitle: _toneLabel(s.reflectionTone),
                onTap: () => _pickTone(context, ref, s.reflectionTone),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s20),
          _SettingsSection(
            title: 'Reminders',
            children: [
              _SettingsTile(
                icon: Icons.notifications_none_rounded,
                title: 'Daily reminder',
                subtitle: 'A gentle nudge to capture your day',
                trailing: Switch(
                  value: s.dailyReminder,
                  onChanged: (v) => _patch(context, ref, {'dailyReminder': v}),
                ),
              ),
              if (s.dailyReminder)
                _SettingsTile(
                  icon: Icons.schedule_rounded,
                  title: 'Reminder time',
                  subtitle: s.reminderTime ?? 'Not set',
                  onTap: () => _pickTime(context, ref, s.reminderTime),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickTone(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final accent = AppColors.accent(Theme.of(ctx).brightness);
        return SimpleDialog(
          title: const Text('Reflection tone'),
          children: [
            for (final tone in const ['warm', 'neutral', 'direct'])
              ListTile(
                title: Text(_toneLabel(tone)),
                trailing: tone == current
                    ? Icon(Icons.check_rounded, color: accent)
                    : null,
                onTap: () => Navigator.of(ctx).pop(tone),
              ),
          ],
        );
      },
    );
    if (picked != null && picked != current && context.mounted) {
      await _patch(context, ref, {'reflectionTone': picked});
    }
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) async {
    TimeOfDay initial = const TimeOfDay(hour: 20, minute: 0);
    if (current != null && current.contains(':')) {
      final parts = current.split(':');
      initial = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 20,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !context.mounted) return;
    final value =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    await _patch(context, ref, {'reminderTime': value});
  }

  Future<void> _editSensitiveTopics(
    BuildContext context,
    WidgetRef ref,
    SettingsModel s,
  ) async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => _SensitiveTopicsDialog(initial: s.sensitiveTopics),
    );
    if (result != null && context.mounted) {
      await _patch(context, ref, {'sensitiveTopics': result});
    }
  }
}

String _toneLabel(String tone) => switch (tone) {
  'warm' => 'Warm and encouraging',
  'neutral' => 'Neutral and factual',
  'direct' => 'Direct and concise',
  _ => tone,
};

class _SensitiveTopicsDialog extends StatefulWidget {
  const _SensitiveTopicsDialog({required this.initial});

  final List<String> initial;

  @override
  State<_SensitiveTopicsDialog> createState() => _SensitiveTopicsDialogState();
}

class _SensitiveTopicsDialogState extends State<_SensitiveTopicsDialog> {
  late List<String> _topics = [...widget.initial];
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final raw = _controller.text.trim();
    if (raw.isEmpty || _topics.contains(raw)) {
      _controller.clear();
      return;
    }
    setState(() => _topics = [..._topics, raw]);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sensitive topics'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LifeOS handles these topics with extra care in AI output.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final t in _topics)
                Chip(
                  label: Text(t),
                  onDeleted: () =>
                      setState(() => _topics = _topics.where((x) => x != t).toList()),
                ),
            ],
          ),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _add(),
            decoration: InputDecoration(
              hintText: 'Add a topic…',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _add,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_topics),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ThemeModeRow extends StatelessWidget {
  const _ThemeModeRow({
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
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final selected = value == groupValue;

    return ListTile(
      onTap: () => onChanged(value),
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: selected
          ? Icon(Icons.check_rounded, color: AppColors.accent(brightness))
          : null,
    );
  }
}
