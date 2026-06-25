import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../features/courses/data/course_models.dart';
import '../theme/app_colors.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    required this.course,
    required this.onTap,
    this.compact = false,
    this.owned = false,
    super.key,
  });

  final CourseSummary course;
  final VoidCallback onTap;
  final bool compact;
  final bool owned;

  @override
  Widget build(BuildContext context) {
    final image = _CourseImage(url: course.courseImageUrl);
    final info = _CourseInfo(course: course, owned: owned);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Card(
        child: compact
            ? SizedBox(
                width: 240,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    image,
                    Padding(padding: const EdgeInsets.all(12), child: info),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 112, child: image),
                    const SizedBox(width: 12),
                    Expanded(child: info),
                  ],
                ),
              ),
      ),
    );
  }
}

class _CourseImage extends StatelessWidget {
  const _CourseImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: url == null || url!.isEmpty
            ? Container(
                color: AppColors.primary,
                child: const Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 36,
                ),
              )
            : CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: AppColors.line),
                errorWidget: (_, _, _) => Container(
                  color: AppColors.primary,
                  child: const Icon(Icons.school, color: Colors.white),
                ),
              ),
      ),
    );
  }
}

class _CourseInfo extends StatelessWidget {
  const _CourseInfo({required this.course, required this.owned});

  final CourseSummary course;
  final bool owned;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'd');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          course.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          course.instructorName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 16, color: AppColors.accent),
                const SizedBox(width: 3),
                Text(course.averageRating.toStringAsFixed(1)),
              ],
            ),
            Text('${course.totalReviews} danh gia'),
            Text(_formatLevel(course.level)),
          ],
        ),
        const SizedBox(height: 8),
        owned
            ? const _OwnedPill()
            : Text(
                course.isFree ? 'Mien phi' : formatter.format(course.price),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
      ],
    );
  }
}

class _OwnedPill extends StatelessWidget {
  const _OwnedPill();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          'Da so huu',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

String _formatLevel(String level) {
  switch (level.toUpperCase()) {
    case 'BEGINNER':
      return 'Co ban';
    case 'INTERMEDIATE':
      return 'Trung cap';
    case 'ADVANCED':
      return 'Nang cao';
    default:
      return level;
  }
}
