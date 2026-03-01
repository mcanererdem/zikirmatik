class UserProfile {
  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final int totalZikrs;
  final DateTime? lastZikrDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? preferences;

  UserProfile({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.totalZikrs = 0,
    this.lastZikrDate,
    required this.createdAt,
    required this.updatedAt,
    this.preferences,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      totalZikrs: json['total_zikrs'] ?? 0,
      lastZikrDate: json['last_zikr_date'] != null 
          ? DateTime.parse(json['last_zikr_date'])
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      preferences: json['preferences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'total_zikrs': totalZikrs,
      'last_zikr_date': lastZikrDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'preferences': preferences,
    };
  }

  UserProfile copyWith({
    String? username,
    String? displayName,
    String? avatarUrl,
    int? totalZikrs,
    DateTime? lastZikrDate,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      userId: userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalZikrs: totalZikrs ?? this.totalZikrs,
      lastZikrDate: lastZikrDate ?? this.lastZikrDate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'UserProfile(userId: $userId, username: $username, totalZikrs: $totalZikrs)';
  }
}
