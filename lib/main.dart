import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'features/auth/splash/splash_page.dart';
import 'app.dart';

void main() {
  runApp(const ProviderScope(child: AppStart()));
}

class AppStart extends ConsumerWidget {
  const AppStart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(authInitProvider);

    return init.when(
      loading: () => const MaterialApp(
        home: SplashPage(),
        debugShowCheckedModeBanner: false,
      ),
      error: (e, _) => MaterialApp(
        home: Scaffold(body: Center(child: Text("Error: $e"))),
      ),
      data: (_) => const TekkyApp(),
    );
  }
}
