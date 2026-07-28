import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/dummy_data.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../widgets/app_text_field.dart';
import '../../../../widgets/primary_button.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: currentUser.name);
    _bioCtrl = TextEditingController(text: currentUser.bio);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isSaving = false);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(AppIcons.close),
        ),
        title: const Text('Edit profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Stack(
              children: [
                AppNetworkImage(
                  url: currentUser.avatarUrl,
                  width: 100,
                  height: 100,
                  isCircle: true,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.background, width: 2),
                    ),
                    child: const Icon(AppIcons.camera,
                        color: Colors.black, size: 16),
                  ),
                ),
              ],
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              hintText: 'Your name',
              label: 'Name',
              prefixIcon: Icons.person_outline_rounded,
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
            ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              hintText: 'Tell people about yourself',
              label: 'Bio',
              controller: _bioCtrl,
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  const Icon(AppIcons.link,
                      color: AppColors.textMuted, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      currentUser.email,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text('Email',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ).animate(delay: 300.ms).fadeIn(),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Save changes',
              isFullWidth: true,
              isLoading: _isSaving,
              onPressed: _save,
            ).animate(delay: 400.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}
