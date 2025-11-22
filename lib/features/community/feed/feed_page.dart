import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tekky/data/models/post_model.dart';
import 'feed_providers.dart';

class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed'),
        actions: [
          IconButton(
            onPressed: () => context.go('/create-post'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: feedState.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(
              child: Text('No posts yet. Be the first to post!'),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(feedProvider.notifier).refresh(),
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return _PostCard(post: post);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  final PostModel post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(feedProvider.notifier);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.authorName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(post.content),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () => notifier.toggleLike(post),
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                  ),
                ),
                Text('${post.likesCount}'),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () async {
                    final comment = await _showCommentDialog(context);
                    if (comment != null && comment.trim().isNotEmpty) {
                      notifier.addComment(post, comment.trim());
                    }
                  },
                  icon: const Icon(Icons.comment),
                ),
                Text('${post.commentsCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showCommentDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add Comment'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Write a comment...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }
}
