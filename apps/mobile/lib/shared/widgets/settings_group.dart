import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/shared/widgets/app_card.dart';

class SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  const SettingsGroup({
    super.key,
    required this.children,
    this.margin = const EdgeInsets.symmetric(
      horizontal: AppSpacing.s16,
      vertical: 8,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final divider = Container(height: 0.5, color: AppColors.border(brightness));

    final groupedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      groupedChildren.add(children[i]);
      if (i < children.length - 1) {
        groupedChildren.add(divider);
      }
    }

    return AppCard(
      elevated: true,
      margin: margin,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: groupedChildren,
      ),
    );
  }
}
