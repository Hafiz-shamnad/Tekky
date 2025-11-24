import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/storage/secure_storage.dart';
import '../../services/api/auth_api.dart';

/// Holds JWT access token
final authTokenProvider = StateProvider<String?>((ref) => null);

/// Logged-in state boolean
final authStateProvider = StateProvider<bool>((ref) => false);

/// Logged-in user's ID
final currentUserProvider = StateProvider<String?>((ref) => null);

/// Initialize auth on app start
final authInitProvider = FutureProvider<bool>((ref) async {
  final accessToken = await SecureStorage.getAccessToken();
  final refreshToken = await SecureStorage.getRefreshToken();
  final userId = await SecureStorage.getUserId();

  if (accessToken == null || refreshToken == null) {
    // User is NOT logged in
    ref.read(authTokenProvider.notifier).state = null;
    ref.read(authStateProvider.notifier).state = false;
    ref.read(currentUserProvider.notifier).state = null;
    return false;
  }

  // Restore saved values
  ref.read(authTokenProvider.notifier).state = accessToken;
  ref.read(currentUserProvider.notifier).state = userId;

  // 🔥 FIXED: refreshAccessToken takes ZERO arguments
  final valid = await AuthApi.refreshAccessToken();

  if (valid) {
    ref.read(authStateProvider.notifier).state = true;
  } else {
    ref.read(authStateProvider.notifier).state = false;
  }

  return valid;
});
