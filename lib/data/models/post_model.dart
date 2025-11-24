class PostModel {
  final String id;

  // Author
  final String authorId;
  final String authorName;
  final String authorUsername;
  final String? authorAvatarUrl;

  // Post content
  final String content;
  final DateTime createdAt;

  // Engagement
  final int likesCount;
  final bool isLiked;
  final int commentsCount;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorUsername,
    this.authorAvatarUrl,
    required this.content,
    required this.createdAt,
    required this.likesCount,
    required this.isLiked,
    required this.commentsCount,
  });

  // ----------- FROM JSON -----------
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'].toString(),

      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName'] ?? 'Unknown',
      authorUsername: json['authorUsername'] ?? 'user',
      authorAvatarUrl: json['authorAvatarUrl'],

      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),

      likesCount: json['likesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      commentsCount: json['commentsCount'] ?? 0,
    );
  }

  // ----------- TO JSON -----------
  Map<String, dynamic> toJson() {
    return {
      'id': id,

      'authorId': authorId,
      'authorName': authorName,
      'authorUsername': authorUsername,
      'authorAvatarUrl': authorAvatarUrl,

      'content': content,
      'createdAt': createdAt.toIso8601String(),

      'likesCount': likesCount,
      'isLiked': isLiked,
      'commentsCount': commentsCount,
    };
  }

  // ----------- COPY WITH -----------
  PostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorUsername,
    String? authorAvatarUrl,
    String? content,
    DateTime? createdAt,
    int? likesCount,
    bool? isLiked,
    int? commentsCount,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }
}
