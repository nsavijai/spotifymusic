import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../widgets/primary_button.dart';

// ─── About Page ───────────────────────────────────────────────────────────────

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(AppIcons.back),
        ),
        title: const Text('About VMusic'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.music_note_rounded,
                  color: Colors.black, size: 44),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: AppSpacing.md),
            Text('VMusic',
                style: Theme.of(context).textTheme.headlineMedium)
                .animate(delay: 100.ms).fadeIn(),
            Text('Version 1.0.0',
                style: Theme.of(context).textTheme.bodyMedium)
                .animate(delay: 150.ms).fadeIn(),
            const SizedBox(height: AppSpacing.xl),
            const _InfoCard(
              title: 'Our mission',
              content:
                  'VMusic is built to give everyone access to a world-class music streaming experience. We believe music should be accessible, beautiful, and personal.',
            ).animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: AppSpacing.md),
            const _InfoCard(
              title: 'Technology',
              content:
                  'Built with Flutter for a seamless cross-platform experience. Powered by a modern backend with real-time recommendations.',
            ).animate(delay: 250.ms).fadeIn(),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => context.push('/terms'),
                  child: const Text('Terms'),
                ),
                TextButton(
                  onPressed: () => context.push('/privacy'),
                  child: const Text('Privacy'),
                ),
              ],
            ).animate(delay: 300.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}

// ─── Help Page ────────────────────────────────────────────────────────────────

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(AppIcons.back),
        ),
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          ..._faqs.asMap().entries.map(
                (e) => _FaqTile(faq: e.value)
                    .animate(delay: (e.key * 60).ms)
                    .fadeIn(),
              ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              children: [
                const Icon(AppIcons.help,
                    color: AppColors.primary, size: 32),
                const SizedBox(height: AppSpacing.sm),
                Text('Still need help?',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text('Contact our support team',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Contact support',
                  onPressed: () {},
                ),
              ],
            ),
          ).animate(delay: 400.ms).fadeIn(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  static const _faqs = [
    (
      q: 'How do I download songs for offline listening?',
      a: 'Tap the download icon on any song, album, or playlist. Downloads require a Premium subscription.',
    ),
    (
      q: 'How do I cancel my subscription?',
      a: 'Go to Profile > Settings > Subscription and tap "Cancel subscription". Your access continues until the end of the billing period.',
    ),
    (
      q: 'Why is my music not playing?',
      a: 'Check your internet connection. If the issue persists, try restarting the app or clearing the cache in Settings.',
    ),
    (
      q: 'How do I create a playlist?',
      a: 'Go to Library and tap the + button in the top right corner. Give your playlist a name and start adding songs.',
    ),
  ];
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.faq});

  final ({String q, String a}) faq;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ExpansionTile(
        title: Text(widget.faq.q,
            style: Theme.of(context).textTheme.titleSmall),
        trailing: Icon(
          _expanded ? AppIcons.chevronDown : AppIcons.chevronRight,
          color: AppColors.textMuted,
        ),
        onExpansionChanged: (v) => setState(() => _expanded = v),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: Text(widget.faq.a,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

// ─── Terms Page ───────────────────────────────────────────────────────────────

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(AppIcons.back),
        ),
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last updated: January 2025',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.lg),
            ..._sections.map(
              (s) => _InfoCard(title: s.$1, content: s.$2),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  static const _sections = [
    (
      'Acceptance of Terms',
      'By accessing or using VMusic, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our service.',
    ),
    (
      'Use of Service',
      'VMusic grants you a limited, non-exclusive, non-transferable license to access and use the service for personal, non-commercial purposes.',
    ),
    (
      'User Content',
      'You retain ownership of any content you submit to VMusic. By submitting content, you grant VMusic a worldwide license to use, reproduce, and distribute that content.',
    ),
    (
      'Prohibited Activities',
      'You may not use VMusic to violate any laws, infringe intellectual property rights, distribute malware, or engage in any activity that disrupts the service.',
    ),
  ];
}

// ─── Privacy Page ─────────────────────────────────────────────────────────────

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(AppIcons.back),
        ),
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last updated: January 2025',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.lg),
            ..._sections.map(
              (s) => _InfoCard(title: s.$1, content: s.$2),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  static const _sections = [
    (
      'Information We Collect',
      'We collect information you provide directly, such as your name, email, and payment information. We also collect usage data to improve your experience.',
    ),
    (
      'How We Use Your Information',
      'We use your information to provide and improve our service, personalize your experience, process payments, and communicate with you.',
    ),
    (
      'Data Sharing',
      'We do not sell your personal information. We may share data with trusted partners who help us operate our service, subject to confidentiality agreements.',
    ),
    (
      'Your Rights',
      'You have the right to access, correct, or delete your personal data. Contact our support team to exercise these rights.',
    ),
  ];
}

// ─── 404 Page ─────────────────────────────────────────────────────────────────

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '404',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate(delay: 100.ms).fadeIn(),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "The page you're looking for doesn't exist or has been moved.",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ).animate(delay: 200.ms).fadeIn(),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Go home',
                onPressed: () => context.go('/home'),
              ).animate(delay: 300.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
