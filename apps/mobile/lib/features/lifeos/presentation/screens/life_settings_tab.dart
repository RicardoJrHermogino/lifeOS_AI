import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/core/theme/theme_provider.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
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
                const _SettingsTile(
                  icon: Icons.download_outlined,
                  title: 'Export life data',
                  subtitle: 'Prepare memories, transcripts, and insights',
                ),
                const _SettingsTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Delete memories',
                  subtitle: 'Remove individual memories or all account data',
                  isDestructive: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s20),
            _SettingsSection(
              title: 'AI behavior',
              children: [
                _SettingsTile(
                  icon: Icons.auto_awesome_outlined,
                  title: 'Daily reflections',
                  subtitle:
                      'Generate a grounded summary at the end of each day',
                  trailing: Switch(value: true, onChanged: (_) {}),
                ),
                _SettingsTile(
                  icon: Icons.lightbulb_outline_rounded,
                  title: 'Proactive insights',
                  subtitle:
                      'Allow LifeOS to surface patterns without being asked',
                  trailing: Switch(value: false, onChanged: (_) {}),
                ),
              ],
            ),
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final color = isDestructive
        ? theme.colorScheme.error
        : AppColors.accent(brightness);

    return ListTile(
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
