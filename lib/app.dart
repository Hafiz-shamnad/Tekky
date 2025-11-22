import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/splash/splash_page.dart';
import 'features/community/feed/feed_page.dart';
import 'services/community/post/create_post_page.dart';

class TekkyApp extends StatelessWidget {
  const TekkyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const SplashPage(),
        ),
        GoRoute(
          path: '/feed',
          builder: (_, __) => const FeedPage(),
        ),
        GoRoute(
          path: '/create-post',
          builder: (_, __) => const CreatePostPage(),
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
