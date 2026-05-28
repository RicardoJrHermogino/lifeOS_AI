import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/support/data/tickets_repository.dart';
import 'package:mobile/shared/widgets/app_button.dart';
import 'package:mobile/shared/widgets/app_text_field.dart';

class SupportTicketScreen extends ConsumerStatefulWidget {
  const SupportTicketScreen({super.key});

  @override
  ConsumerState<SupportTicketScreen> createState() =>
      _SupportTicketScreenState();
}

class _SupportTicketScreenState extends ConsumerState<SupportTicketScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _concernController = TextEditingController();
  String _priority = 'medium';
  bool _busy = false;
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _concernController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final subject = _subjectController.text.trim();
    final concern = _concernController.text.trim();

    if (name.isEmpty || subject.isEmpty || concern.isEmpty) {
      _toast('Please fill in your name, subject, and concern.');
      return;
    }
    if (!email.contains('@')) {
      _toast('Please enter a valid email.');
      return;
    }

    setState(() => _busy = true);
    try {
      await ref
          .read(ticketsRepositoryProvider)
          .submit(
            name: name,
            email: email,
            subject: subject,
            priority: _priority,
            concern: concern,
          );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Support request sent. We\'ll be in touch.'),
        ),
      );
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(content: Text('Could not send: $e')));
      setState(() => _busy = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    // Prefill from the signed-in user once.
    final user = ref.watch(currentUserProvider);
    if (!_prefilled && user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _prefilled = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Contact support')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Tell us what you need help with. Please don\'t include private '
              'memory contents — describe the issue only.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText(brightness),
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            AppTextField(
              controller: _nameController,
              labelText: 'Name',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.s16),
            AppTextField(
              controller: _emailController,
              labelText: 'Email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.s16),
            AppTextField(
              controller: _subjectController,
              labelText: 'Subject',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.s16),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
                DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
              ],
              onChanged: (v) => setState(() => _priority = v ?? 'medium'),
            ),
            const SizedBox(height: AppSpacing.s16),
            AppTextField(
              controller: _concernController,
              labelText: 'How can we help?',
              minLines: 4,
              maxLines: 8,
            ),
            const SizedBox(height: AppSpacing.s24),
            AppButton(
              onPressed: _busy ? null : _submit,
              isLoading: _busy,
              child: const Text('Send request'),
            ),
          ],
        ),
      ),
    );
  }
}
