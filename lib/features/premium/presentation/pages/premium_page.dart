import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../widgets/primary_button.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  int _selectedPlan = 1; // 0=monthly, 1=annual, 2=family

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(AppIcons.back),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1A00), Color(0xFF0D0D0D)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    const Icon(AppIcons.premium,
                        color: AppColors.gold, size: 56),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'VMusic Premium',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: AppColors.gold),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Unlimited music, zero limits',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Features
                  Text('What you get',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  ..._features.asMap().entries.map(
                        (e) => _FeatureRow(
                          icon: e.value.$1,
                          title: e.value.$2,
                          subtitle: e.value.$3,
                        )
                            .animate(delay: (e.key * 60).ms)
                            .fadeIn()
                            .slideX(begin: -0.1, end: 0),
                      ),
                  const SizedBox(height: AppSpacing.xl),
                  // Plans
                  Text('Choose your plan',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  ..._plans.asMap().entries.map(
                        (e) => _PlanCard(
                          plan: e.value,
                          isSelected: _selectedPlan == e.key,
                          onTap: () =>
                              setState(() => _selectedPlan = e.key),
                        )
                            .animate(delay: (e.key * 80).ms)
                            .fadeIn()
                            .slideY(begin: 0.1, end: 0),
                      ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: 'Start free trial',
                    isFullWidth: true,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Premium activated! Enjoy VMusic.'),
                        ),
                      );
                      context.pop();
                    },
                  ).animate(delay: 400.ms).fadeIn(),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: Text(
                      '3 months free, then \$9.99/month. Cancel anytime.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ).animate(delay: 450.ms).fadeIn(),
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
                  ).animate(delay: 500.ms).fadeIn(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _features = [
    (AppIcons.music, 'Ad-free music', 'Listen without interruptions'),
    (AppIcons.download, 'Offline listening', 'Download up to 10,000 songs'),
    (AppIcons.quality, 'High quality audio', 'Up to 320kbps streaming'),
    (Icons.devices_rounded, 'All devices', 'Listen on any device'),
    (AppIcons.shuffle, 'Unlimited skips', 'Skip as many times as you want'),
  ];

  static const _plans = [
    (
      name: 'Monthly',
      price: '\$9.99',
      period: 'per month',
      badge: '',
      savings: '',
    ),
    (
      name: 'Annual',
      price: '\$7.99',
      period: 'per month',
      badge: 'Best value',
      savings: 'Save 20%',
    ),
    (
      name: 'Family',
      price: '\$14.99',
      period: 'per month',
      badge: 'Up to 6 accounts',
      savings: '',
    ),
  ];
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleSmall),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(AppIcons.check, color: AppColors.primary, size: 18),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final ({
    String name,
    String price,
    String period,
    String badge,
    String savings
  }) plan;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.black, size: 14)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(plan.name,
                          style: Theme.of(context).textTheme.titleSmall),
                      if (plan.badge.isNotEmpty) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            plan.badge,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.black),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (plan.savings.isNotEmpty)
                    Text(plan.savings,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(plan.price,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(plan.period,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


