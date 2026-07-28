import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../widgets/app_text_field.dart';
import '../../../../widgets/primary_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (_emailCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() { _isLoading = false; _emailSent = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _emailSent ? _SuccessView(email: _emailCtrl.text) : _FormView(
            emailCtrl: _emailCtrl,
            isLoading: _isLoading,
            onSend: _sendReset,
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView({
    required this.emailCtrl,
    required this.isLoading,
    required this.onSend,
  });

  final TextEditingController emailCtrl;
  final bool isLoading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Text('Reset password', style: Theme.of(context).textTheme.headlineLarge)
            .animate().fadeIn().slideY(begin: 0.3, end: 0),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "Enter your email and we'll send you a reset link.",
          style: Theme.of(context).textTheme.bodyMedium,
        ).animate(delay: 100.ms).fadeIn(),
        const SizedBox(height: AppSpacing.xxl),
        AppTextField(
          hintText: 'Email address',
          label: 'Email',
          prefixIcon: Icons.email_outlined,
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Send reset link',
          isFullWidth: true,
          isLoading: isLoading,
          onPressed: onSend,
        ).animate(delay: 300.ms).fadeIn(),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_rounded,
                color: AppColors.primary, size: 40),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: AppSpacing.lg),
          Text('Check your inbox', style: Theme.of(context).textTheme.headlineMedium)
              .animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We sent a reset link to\n$email',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ).animate(delay: 300.ms).fadeIn(),
          const SizedBox(height: AppSpacing.xl),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Back to login'),
          ).animate(delay: 400.ms).fadeIn(),
        ],
      ),
    );
  }
}
