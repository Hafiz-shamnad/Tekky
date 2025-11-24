// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/storage/secure_storage.dart';
import '../../services/api/auth_api.dart';

/// Holds JWT access token
final authTokenProvider = StateProvider<String?>((ref) => null);

/// Logged-in state boolean
final authStateProvider = StateProvider<bool>((ref) => false);

/// Logged-in user's ID
final currentUserProvider = StateProvider<String?>((ref) => null);

final authInitProvider = FutureProvider<bool>((ref) async {
  try {
    final accessToken = await SecureStorage.getAccessToken();
    final refreshToken = await SecureStorage.getRefreshToken();
    final userId = await SecureStorage.getUserId();

    print("INIT => access=$accessToken refresh=$refreshToken user=$userId");

    if (accessToken == null || refreshToken == null || userId == null) {
      // clear providers
      ref.read(authTokenProvider.notifier).state = null;
      ref.read(currentUserProvider.notifier).state = null;
      ref.read(authStateProvider.notifier).state = false;
      return false;
    }

    // restore saved state
    ref.read(authTokenProvider.notifier).state = accessToken;
    ref.read(currentUserProvider.notifier).state = userId;

    bool valid = false;
    try {
      valid = await AuthApi.refreshAccessToken();
    } catch (e) {
      print("REFRESH ERROR: $e");
      valid = false;
    }

    if (valid) {
      ref.read(authStateProvider.notifier).state = true;
      return true;
    }

    // invalid → logout
    await SecureStorage.clear();
    ref.read(authTokenProvider.notifier).state = null;
    ref.read(currentUserProvider.notifier).state = null;
    ref.read(authStateProvider.notifier).state = false;

    return false;

  } catch (e) {
    print("AUTH INIT FAIL: $e");
    await SecureStorage.clear();
    ref.read(authTokenProvider.notifier).state = null;
    ref.read(currentUserProvider.notifier).state = null;
    ref.read(authStateProvider.notifier).state = false;
    return false;
  }
});
