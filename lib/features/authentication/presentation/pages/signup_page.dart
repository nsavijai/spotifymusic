import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../widgets/app_text_field.dart';
import '../../../../widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_agreeToTerms) return;
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (name.isEmpty || email.isEmpty || password.isEmpty) return;

    await ref.read(authStateProvider.notifier).register(
          email: email,
          username: name,
          password: password,
        );
    if (!mounted) return;
    if (ref.read(authStateProvider).isAuthenticated) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (_, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage!),
          backgroundColor: AppColors.error,
        ));
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text('Create account',
                      style: Theme.of(context).textTheme.headlineLarge)
                  .animate()
                  .fadeIn()
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: AppSpacing.xs),
              Text('Join millions of music lovers',
                      style: Theme.of(context).textTheme.bodyMedium)
                  .animate(delay: 100.ms)
                  .fadeIn(),
              const SizedBox(height: AppSpacing.xxl),
              AppTextField(
                hintText: 'Your name',
                label: 'Name',
                prefixIcon: Icons.person_outline_rounded,
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                hintText: 'Email address',
                label: 'Email',
                prefixIcon: Icons.email_outlined,
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                hintText: 'Create a password',
                label: 'Password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                controller: _passwordCtrl,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _register(),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppSpacing.md),
              Row(children: [
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: (v) =>
                      setState(() => _agreeToTerms = v ?? false),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _agreeToTerms = !_agreeToTerms),
                    child: Text.rich(TextSpan(
                      text: 'I agree to the ',
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )),
                  ),
                ),
              ]).animate(delay: 500.ms).fadeIn(),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Create account',
                isFullWidth: true,
                isLoading: authState.isLoading,
                onPressed:
                    (_agreeToTerms && !authState.isLoading) ? _register : null,
              ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium),
                  TextButton(
                    onPressed: () => context.pushReplacement('/login'),
                    child: const Text('Log in'),
                  ),
                ]),
              ).animate(delay: 700.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
