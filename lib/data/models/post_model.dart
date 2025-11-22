class PostModel {
  final String id;
  final String authorName;
  final String? authorAvatarUrl;
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;
  final int commentsCount;

  PostModel({
    required this.id,
    required this.authorName,
    this.authorAvatarUrl,
    required this.content,
    required this.createdAt,
    required this.likesCount,
    required this.isLiked,
    required this.commentsCount,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'].toString(),
      authorName: json['authorName'] ?? 'Unknown',
      authorAvatarUrl: json['authorAvatarUrl'],
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      likesCount: json['likesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      commentsCount: json['commentsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'isLiked': isLiked,
      'commentsCount': commentsCount,
    };
  }

  PostModel copyWith({
    String? id,
    String? authorName,
    String? authorAvatarUrl,
    String? content,
    DateTime? createdAt,
    int? likesCount,
    bool? isLiked,
    int? commentsCount,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }
}
