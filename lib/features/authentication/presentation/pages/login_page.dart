import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../widgets/app_text_field.dart';
import '../../../../widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) return;
    await ref
        .read(authStateProvider.notifier)
        .login(email: email, password: password);
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
              Text('Welcome back',
                      style: Theme.of(context).textTheme.headlineLarge)
                  .animate()
                  .fadeIn()
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: AppSpacing.xs),
              Text('Sign in to continue listening',
                      style: Theme.of(context).textTheme.bodyMedium)
                  .animate(delay: 100.ms)
                  .fadeIn(),
              const SizedBox(height: AppSpacing.xxl),
              AppTextField(
                hintText: 'Email address',
                label: 'Email',
                prefixIcon: Icons.email_outlined,
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                hintText: 'Password',
                label: 'Password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                controller: _passwordCtrl,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: const Text('Forgot password?'),
                ),
              ).animate(delay: 400.ms).fadeIn(),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Log in',
                isFullWidth: true,
                isLoading: authState.isLoading,
                onPressed: authState.isLoading ? null : _login,
              ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppSpacing.xl),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text('or continue with',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
                const Expanded(child: Divider()),
              ]).animate(delay: 600.ms).fadeIn(),
              const SizedBox(height: AppSpacing.lg),
              Row(children: [
                Expanded(
                    child: _SocialButton(
                        label: 'Google',
                        icon: Icons.g_mobiledata_rounded,
                        onPressed: () => context.go('/home'))),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                    child: _SocialButton(
                        label: 'Apple',
                        icon: Icons.apple_rounded,
                        onPressed: () => context.go('/home'))),
              ]).animate(delay: 700.ms).fadeIn(),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text("Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium),
                  TextButton(
                    onPressed: () => context.pushReplacement('/register'),
                    child: const Text('Sign up'),
                  ),
                ]),
              ).animate(delay: 800.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton(
      {required this.label, required this.icon, required this.onPressed});
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
      ),
    );
  }
}
