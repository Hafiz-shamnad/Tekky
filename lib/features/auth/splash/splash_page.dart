import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/storage/secure_storage.dart';
import '../auth_provider.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    final accessToken = await SecureStorage.getAccessToken();

    if (accessToken != null) {
      ref.read(authStateProvider.notifier).state = true;
      context.go('/feed'); // logged in
    } else {
      ref.read(authStateProvider.notifier).state = false;
      context.go('/login'); // not logged in
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
