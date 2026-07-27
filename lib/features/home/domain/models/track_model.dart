class TrackModel {
  const TrackModel({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.duration,
    this.isFavorite = false,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final String duration;
  final bool isFavorite;
}
