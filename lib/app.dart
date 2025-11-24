import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/router/router_refresh.dart'; // <-- add this import
import 'features/auth/splash/splash_page.dart';
import 'features/auth/screens/login_page.dart';
import 'features/auth/screens/register_page.dart';
import 'features/community/feed/feed_page.dart';
import 'services/community/post/create_post_page.dart';
import 'features/auth/auth_provider.dart';
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
    final authState = ref.watch(authStateProvider);

    final router = GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(
        ref.watch(authStateProvider.notifier).stream,
      ),
      redirect: (context, state) {
        final authed = authState;
        final splash = state.matchedLocation == '/';
        final loggingIn = state.matchedLocation == '/login';
        final registering = state.matchedLocation == '/register';

        if (splash) return null;

        // Need login
        if (!authed && !loggingIn && !registering) {
          return '/login';
        }

        // Already logged in: skip login/register
        if (authed && (loggingIn || registering)) {
          return '/feed';
        }

        return null;
      },

      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashPage()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(path: '/feed', builder: (_, __) => const FeedPage()),
            GoRoute(path: '/explore', builder: (_, __) => const ExplorePage()),
            GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
            GoRoute(
              path: '/create-post',
              builder: (_, __) => const CreatePostPage(),
            ),
            GoRoute(
              path: '/add-idea',
              builder: (context, state) => const AddIdeaPage(),
            ),
            GoRoute(
              path: '/idea-details',
              builder: (context, state) {
                final idea = state.extra as Map;
                return IdeaDetailPage(idea: idea);
              },
            ),
            GoRoute(
              path: '/edit-profile',
              builder: (context, state) => const EditProfilePage(),
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
