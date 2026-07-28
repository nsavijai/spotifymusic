import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_color.dart';
import '../theme/app_radius.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.isCircle = false,
  });

  final double width;
  final double height;
  final double? borderRadius;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceElevated,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle
              ? null
              : BorderRadius.circular(borderRadius ?? AppRadius.sm),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.width = 160, this.height = 200});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: width * 0.8,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: width * 0.5,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonTrackTile extends StatelessWidget {
  const SkeletonTrackTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceElevated,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
