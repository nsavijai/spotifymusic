class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.avatarUrl,
    required this.isPremium,
    required this.followersCount,
    required this.followingCount,
    required this.bio,
    this.isActive = true,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? json['username'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ??
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80',
      isPremium: json['is_premium'] as bool? ?? false,
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      bio: json['bio'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  final String id;
  final String email;
  final String username;
  final String name;
  final String avatarUrl;
  final bool isPremium;
  final int followersCount;
  final int followingCount;
  final String bio;
  final bool isActive;

  AuthUser copyWith({
    String? name,
    String? bio,
    String? avatarUrl,
  }) =>
      AuthUser(
        id: id,
        email: email,
        username: username,
        name: name ?? this.name,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isPremium: isPremium,
        followersCount: followersCount,
        followingCount: followingCount,
        bio: bio ?? this.bio,
        isActive: isActive,
      );
}
