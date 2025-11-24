import 'package:riverpod/riverpod.dart';
import '../../../data/models/post_model.dart';
import '../../../services/api/post_api.dart';
import '../../auth/auth_provider.dart'; // <-- required for user ID

// Define the provider for the Notifier
final feedProvider =
    NotifierProvider<FeedNotifier, AsyncValue<List<PostModel>>>(() {
  return FeedNotifier();
});

class FeedNotifier extends Notifier<AsyncValue<List<PostModel>>> {
  // Use a nullable String, but let Riverpod manage its value via watch/read
  late final String? currentUserId; 

  @override
  AsyncValue<List<PostModel>> build() {
    // FIX: Watch or read the current user ID provider. 
    // Since we only need the ID once for the lifespan of the notifier, 
    // and assume the user must be logged in for the feed to exist, 
    // reading it in build() is acceptable if currentUserProvider returns String?.
    // If currentUserProvider is complex, you'd watch the auth state provider.
    
    // Assuming currentUserProvider returns String? (the user ID)
    currentUserId = ref.read(currentUserProvider); 

    // Load the feed data asynchronously
    loadFeed();
    return const AsyncValue.loading();
  }

  // -------------------------
  // OWNER CHECK
  // -------------------------
  bool isOwner(PostModel post) {
    // FIX: Removed unnecessary post.authorId == currentUserId check on currentUserId 
    // itself, as it's already a String?
    return post.authorId == currentUserId;
  }

  // -------------------------
  // REMOVE POST FROM LIST
  // -------------------------
  void removePost(PostModel post) {
    // Only update if state is data (AsyncData)
    if (state case AsyncData(:final value)) {
      final newList = value.where((p) => p.id != post.id).toList();
      state = AsyncValue.data(newList);
    }
  }

  // -------------------------
  // LOAD FEED
  // -------------------------
  Future<void> loadFeed() async {
    // Set state to loading only if it's currently Data or Error, not on initial load.
    // However, for refresh logic, we just proceed.
    // If state is currently data, keep it while loading: state = const AsyncValue.loading().copyWithPrevious(state);
    
    try {
      final postsJson = await PostApi.getFeed();
      final posts = postsJson.map((e) => PostModel.fromJson(e)).toList();
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => loadFeed();

  // -------------------------
  // CREATE POST
  // -------------------------
  Future<void> createPost(String content) async {
    try {
      final newJson = await PostApi.createPost(content);
      final newPost = PostModel.fromJson(newJson);

      // Only update if state is data (AsyncData)
      if (state case AsyncData(:final value)) {
        state = AsyncValue.data([newPost, ...value]);
      } else {
         // If state is not ready (error/loading), reload the whole feed
         state = const AsyncValue.loading();
         loadFeed();
      }
    } catch (e, st) {
      // Handle error during creation, maybe show a snackbar in the UI
      // and keep the current state if possible.
      print("Error creating post: $e");
    }
  }

  // -------------------------
  // LIKE / UNLIKE
  // -------------------------
  Future<void> toggleLike(PostModel post) async {
    // Optimistic UI update: Toggle like status immediately
    final isLiking = !post.isLiked;
    final newPost = post.copyWith(
        isLiked: isLiking,
        likesCount: post.likesCount + (isLiking ? 1 : -1));
    _updatePostInList(post.id, newPost);
    
    try {
      // API call
      final updatedJson = await PostApi.toggleLike(post.id);
      final updatedPost = PostModel.fromJson(updatedJson);

      // Final update with server data
      _updatePostInList(post.id, updatedPost);

    } catch (e) {
      // If API fails, revert the change and show error
      _updatePostInList(post.id, post); 
      // Optionally show error state: state = AsyncValue.error(e, st).copyWithPrevious(state);
    }
  }

  // -------------------------
  // ADD COMMENT
  // -------------------------
  Future<void> addComment(PostModel post, String comment) async {
    // Optimistic UI update: Increase comment count immediately
    final newPost = post.copyWith(commentsCount: post.commentsCount + 1);
    _updatePostInList(post.id, newPost);

    try {
      await PostApi.addComment(post.id, comment);
      // No further update needed if the API response is purely success/failure
    } catch (e) {
      // If API fails, revert the change and show error
      _updatePostInList(post.id, post); 
      // Handle error in UI
    }
  }

  // -------------------------
  // UTILITY: Find and replace a post in the current list
  // -------------------------
  void _updatePostInList(String postId, PostModel newPost) {
    if (state case AsyncData(:final value)) {
      final index = value.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final newList = [...value];
        newList[index] = newPost;
        state = AsyncValue.data(newList);
      }
    }
  }
}