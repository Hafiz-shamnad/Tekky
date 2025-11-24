import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/router/router_refresh.dart'; // <-- add this import
import 'features/auth/screens/login_page.dart';
import 'features/auth/screens/register_page.dart';
import 'features/community/feed/feed_page.dart';
import 'services/community/post/create_post_page.dart';
import 'providers/auth_provider.dart';
import 'features/profile/profile_page.dart';
import 'features/navigation/main_shell.dart';
import 'features/explore/explore_page.dart';
import 'features/explore/add_idea_page.dart';
import 'features/explore/idea_detail_page.dart';
import 'features/profile/edit_profile.dart';
class TekkyApp extends ConsumerWidget {
  const TekkyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authed = ref.watch(authStateProvider);

    final router = GoRouter(
      initialLocation: '/feed',
      refreshListenable: GoRouterRefreshStream(
        ref.watch(authStateProvider.notifier).stream,
      ),

      redirect: (_, state) {
        final loc = state.matchedLocation;

        final isLogin = loc == '/login';
        final isRegister = loc == '/register';

        if (!authed && !isLogin && !isRegister) {
          return '/login';
        }

        if (authed && (isLogin || isRegister)) {
          return '/feed';
        }

        return null;
      },

      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

        ShellRoute(
          builder: (_, __, child) => MainShell(child: child),
          routes: [
            GoRoute(path: '/feed', builder: (_, __) => const FeedPage()),
            GoRoute(path: '/explore', builder: (_, __) => const ExplorePage()),
            GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
            GoRoute(path: '/edit-profile', builder: (_, __) => const EditProfilePage()),
            GoRoute(path: '/create-post', builder: (_, __) => const CreatePostPage()),
            GoRoute(path: '/add-idea', builder: (_, __) => const AddIdeaPage()),
            GoRoute(
              path: '/idea-details',
              builder: (_, state) => IdeaDetailPage(idea: state.extra as Map),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
