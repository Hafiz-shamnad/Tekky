import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekky/data/models/post_model.dart';
import 'package:tekky/services/community/community_api.dart';
import 'package:tekky/services/community/community_repository.dart';

// Provides API
final communityApiProvider = Provider((ref) => CommunityApi());

// Provides Repository
final communityRepositoryProvider = Provider(
  (ref) => CommunityRepository(ref.watch(communityApiProvider)),
);

// FEED NOTIFIER - using Riverpod's new Notifier class
class FeedNotifier extends Notifier<AsyncValue<List<PostModel>>> {
  late final CommunityRepository _repo;

  @override
  AsyncValue<List<PostModel>> build() {
    _repo = ref.watch(communityRepositoryProvider);
    _loadFeed();
    return const AsyncValue.loading();
  }

  Future<void> _loadFeed() async {
    try {
      final posts = await _repo.getFeed();
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => _loadFeed();

  Future<void> createPost(String content) async {
    final newPost = await _repo.createPost(content);
    final current = state.value ?? [];
    state = AsyncValue.data([newPost, ...current]);
  }

  Future<void> toggleLike(PostModel post) async {
    final updated = await _repo.toggleLike(post.id);
    final current = state.value ?? [];

    final index = current.indexWhere((p) => p.id == post.id);

    if (index != -1) {
      final newList = [...current];
      newList[index] = updated;
      state = AsyncValue.data(newList);
    }
  }

  Future<void> addComment(PostModel post, String comment) async {
    await _repo.addComment(post.id, comment);

    final current = state.value ?? [];
    final index = current.indexWhere((p) => p.id == post.id);

    if (index != -1) {
      final newList = [...current];
      newList[index] =
          post.copyWith(commentsCount: post.commentsCount + 1);
      state = AsyncValue.data(newList);
    }
  }
}

// New provider type
final feedProvider =
    NotifierProvider<FeedNotifier, AsyncValue<List<PostModel>>>(
  () => FeedNotifier(),
);
