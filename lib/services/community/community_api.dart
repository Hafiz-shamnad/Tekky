// import 'package:dio/dio.dart';
// import 'package:tekky/core/network/api_client.dart';
// import 'package:tekky/data/models/post_model.dart';

// class CommunityApi {
//   final Dio _dio = ApiClient.instance;

//   Future<List<PostModel>> fetchFeed() async {
//     // TODO: update endpoint when backend is ready
//     final response = await _dio.get('/community/feed');

//     final data = response.data as List<dynamic>;
//     return data.map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
//   }

//   Future<PostModel> createPost(String content) async {
//     final response = await _dio.post('/community/posts', data: {'content': content});
//     return PostModel.fromJson(response.data as Map<String, dynamic>);
//   }

//   Future<PostModel> toggleLike(String postId) async {
//     final response = await _dio.post('/community/posts/$postId/like');
//     return PostModel.fromJson(response.data as Map<String, dynamic>);
//   }

//   Future<void> addComment(String postId, String comment) async {
//     await _dio.post('/community/posts/$postId/comments', data: {'content': comment});
//   }
// }

import 'package:tekky/data/models/post_model.dart';

class CommunityApi {
  // MOCK feed for now — no backend needed
  Future<List<PostModel>> fetchFeed() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      PostModel(
        id: '1',
        authorName: 'Hafiz',
        content: 'Welcome to Tekky Community 🎯',
        createdAt: DateTime.now(),
        likesCount: 10,
        isLiked: false,
        commentsCount: 2,
      ),
      PostModel(
        id: '2',
        authorName: 'User123',
        content: 'This platform is going to be big!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        likesCount: 3,
        isLiked: true,
        commentsCount: 1,
      ),
    ];
  }

  // Mock create post
  Future<PostModel> createPost(String content) async {
    await Future.delayed(const Duration(seconds: 1));
    return PostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: 'Hafiz',
      content: content,
      createdAt: DateTime.now(),
      likesCount: 0,
      isLiked: false,
      commentsCount: 0,
    );
  }

  // Mock like toggle
  Future<PostModel> toggleLike(String postId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return PostModel(
      id: postId,
      authorName: 'Hafiz',
      content: 'Welcome to Tekky Community 🎯',
      createdAt: DateTime.now(),
      likesCount: 11,
      isLiked: true,
      commentsCount: 2,
    );
  }

  // Mock comment
  Future<void> addComment(String postId, String comment) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
