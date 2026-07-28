import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _downloadOnWifi = true;
  bool _highQualityStreaming = false;
  bool _crossfade = true;
  String _audioQuality = 'High';
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(AppIcons.back),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          // Appearance
          const _SectionLabel(label: 'Appearance'),
          _SettingsTile(
            icon: AppIcons.theme,
            title: 'Theme',
            subtitle: 'Dark',
            onTap: () {},
          ).animate(delay: 50.ms).fadeIn(),
          _SettingsTile(
            icon: AppIcons.language,
            title: 'Language',
            subtitle: _language,
            onTap: () => _showLanguagePicker(),
          ).animate(delay: 80.ms).fadeIn(),

          // Audio
          const _SectionLabel(label: 'Audio'),
          _SettingsTile(
            icon: AppIcons.quality,
            title: 'Streaming quality',
            subtitle: _audioQuality,
            onTap: () => _showQualityPicker(),
          ).animate(delay: 110.ms).fadeIn(),
          _SettingsSwitchTile(
            icon: AppIcons.equalizer,
            title: 'High quality streaming',
            subtitle: 'Uses more data',
            value: _highQualityStreaming,
            onChanged: (v) => setState(() => _highQualityStreaming = v),
          ).animate(delay: 130.ms).fadeIn(),
          _SettingsSwitchTile(
            icon: AppIcons.music,
            title: 'Crossfade',
            subtitle: 'Smooth transitions between songs',
            value: _crossfade,
            onChanged: (v) => setState(() => _crossfade = v),
          ).animate(delay: 150.ms).fadeIn(),

          // Notifications
          const _SectionLabel(label: 'Notifications'),
          _SettingsSwitchTile(
            icon: AppIcons.notifications,
            title: 'Push notifications',
            subtitle: 'New releases and recommendations',
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ).animate(delay: 180.ms).fadeIn(),

          // Downloads
          const _SectionLabel(label: 'Downloads'),
          _SettingsSwitchTile(
            icon: AppIcons.wifi,
            title: 'Download over Wi-Fi only',
            subtitle: 'Saves mobile data',
            value: _downloadOnWifi,
            onChanged: (v) => setState(() => _downloadOnWifi = v),
          ).animate(delay: 210.ms).fadeIn(),
          _SettingsTile(
            icon: AppIcons.storage,
            title: 'Storage',
            subtitle: '0 MB used',
            onTap: () {},
          ).animate(delay: 230.ms).fadeIn(),

          // Account
          const _SectionLabel(label: 'Account'),
          _SettingsTile(
            icon: AppIcons.premium,
            title: 'Subscription',
            subtitle: 'VMusic Premium',
            onTap: () => context.push('/premium'),
          ).animate(delay: 260.ms).fadeIn(),
          _SettingsTile(
            icon: AppIcons.privacy,
            title: 'Privacy',
            onTap: () => context.push('/privacy'),
          ).animate(delay: 280.ms).fadeIn(),

          // About
          const _SectionLabel(label: 'About'),
          _SettingsTile(
            icon: AppIcons.info,
            title: 'About VMusic',
            onTap: () => context.push('/about'),
          ).animate(delay: 310.ms).fadeIn(),
          _SettingsTile(
            icon: AppIcons.help,
            title: 'Help & Support',
            onTap: () => context.push('/help'),
          ).animate(delay: 330.ms).fadeIn(),
          _SettingsTile(
            icon: AppIcons.link,
            title: 'Terms of Service',
            onTap: () => context.push('/terms'),
          ).animate(delay: 350.ms).fadeIn(),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'VMusic v1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ).animate(delay: 400.ms).fadeIn(),
        ],
      ),
    );
  }

  void _showQualityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PickerSheet(
        title: 'Streaming quality',
        options: const ['Low', 'Normal', 'High', 'Very High'],
        selected: _audioQuality,
        onSelect: (v) => setState(() => _audioQuality = v),
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PickerSheet(
        title: 'Language',
        options: const ['English', 'Spanish', 'French', 'German', 'Japanese'],
        selected: _language,
        onSelect: (v) => setState(() => _language = v),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 0),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: subtitle != null
          ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing: const Icon(AppIcons.chevronRight,
          color: AppColors.textMuted, size: 18),
      onTap: onTap,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 0),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: subtitle != null
          ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          ...options.map(
            (o) => ListTile(
              title: Text(o, style: Theme.of(context).textTheme.bodyLarge),
              trailing: o == selected
                  ? const Icon(AppIcons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                onSelect(o);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
