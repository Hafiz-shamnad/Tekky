import 'package:tekky/data/models/post_model.dart';
import 'community_api.dart';

class CommunityRepository {
  final CommunityApi api;

  CommunityRepository(this.api);

  Future<List<PostModel>> getFeed() => api.fetchFeed();

  Future<PostModel> createPost(String content) => api.createPost(content);

  Future<PostModel> toggleLike(String postId) => api.toggleLike(postId);

  Future<void> addComment(String postId, String comment) =>
      api.addComment(postId, comment);
}
