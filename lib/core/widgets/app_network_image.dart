import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../theme/app_radius.dart';
import 'loading_skeleton.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    this.borderRadius,
    this.isCircle = false,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double width;
  final double height;
  final double? borderRadius;
  final bool isCircle;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => LoadingSkeleton(
        width: width,
        height: height,
        borderRadius: borderRadius,
        isCircle: isCircle,
      ),
      errorWidget: (_, __, ___) => Container(
        width: width,
        height: height,
        color: AppColors.surface,
        child: const Icon(Icons.music_note_rounded, color: AppColors.textMuted),
      ),
    );

    if (isCircle) {
      return ClipOval(child: image);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.md),
      child: image,
    );
  }
}
