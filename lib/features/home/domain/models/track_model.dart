class TrackModel {
  const TrackModel({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.duration,
    this.isFavorite = false,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      title: json['title'] as String? ?? 'Untitled',
      subtitle: json['artist'] as String? ?? 'Unknown artist',
      imageUrl: json['cover_image'] as String? ?? '',
      duration: json['duration'] as String? ?? '0:00',
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  final String title;
  final String subtitle;
  final String imageUrl;
  final String duration;
  final bool isFavorite;
}
