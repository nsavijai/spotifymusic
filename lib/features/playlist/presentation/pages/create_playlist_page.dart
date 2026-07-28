import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/dummy_data.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../widgets/app_text_field.dart';
import '../../../../widgets/primary_button.dart';

class CreatePlaylistPage extends StatefulWidget {
  const CreatePlaylistPage({super.key, this.playlist});

  final PlaylistModel? playlist;

  @override
  State<CreatePlaylistPage> createState() => _CreatePlaylistPageState();
}

class _CreatePlaylistPageState extends State<CreatePlaylistPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  bool _isPublic = true;
  bool _isSaving = false;

  bool get _isEditing => widget.playlist != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl =
        TextEditingController(text: widget.playlist?.title ?? '');
    _descCtrl =
        TextEditingController(text: widget.playlist?.description ?? '');
    _isPublic = widget.playlist?.isPublic ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
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
        title: Text(_isEditing ? 'Edit playlist' : 'New playlist'),
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
            // Cover image picker
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: widget.playlist != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: Image.network(
                          widget.playlist!.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(AppIcons.camera,
                              color: AppColors.textMuted, size: 36),
                          const SizedBox(height: AppSpacing.sm),
                          Text('Add cover',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium),
                        ],
                      ),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              hintText: 'My playlist',
              label: 'Playlist name',
              controller: _titleCtrl,
              textInputAction: TextInputAction.next,
            ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              hintText: 'Add an optional description',
              label: 'Description',
              controller: _descCtrl,
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Public playlist',
                          style: Theme.of(context).textTheme.titleSmall),
                      Text('Anyone can see this playlist',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Switch(
                  value: _isPublic,
                  onChanged: (v) => setState(() => _isPublic = v),
                ),
              ],
            ).animate(delay: 300.ms).fadeIn(),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: _isEditing ? 'Save changes' : 'Create playlist',
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
