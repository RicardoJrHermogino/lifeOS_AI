import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/profile/presentation/screens/profile_screen.dart';

class ProfileIconButton extends ConsumerWidget {
  const ProfileIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final brightness = Theme.of(context).brightness;
    final initial = user?.name.isNotEmpty == true
        ? user!.name[0].toUpperCase()
        : user?.email.isNotEmpty == true
        ? user!.email[0].toUpperCase()
        : 'L';

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.s8),
      child: IconButton(
        tooltip: 'Profile',
        constraints: const BoxConstraints.tightFor(width: 52, height: 52),
        padding: EdgeInsets.zero,
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            sheetAnimationStyle: const AnimationStyle(
              duration: Duration(milliseconds: 420),
              reverseDuration: Duration(milliseconds: 300),
            ),
            builder: (_) => const FractionallySizedBox(
              heightFactor: 0.92,
              child: ProfileScreen(),
            ),
          );
        },
        icon: CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.elevated(brightness),
          backgroundImage: user?.image != null
              ? NetworkImage(user!.image!)
              : null,
          child: user?.image == null
              ? Text(
                  initial,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primary(brightness),
                    fontWeight: FontWeight.w800,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
