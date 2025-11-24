import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api/profile_api.dart';

class ProfileNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  ProfileNotifier() : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final data = await ProfileApi.getMyProfile();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile({
    String? username,
    String? name,
    String? avatarUrl,
    String? bio,
  }) async {
    final updated = await ProfileApi.updateProfile(
      username: username,
      name: name,
      avatarUrl: avatarUrl,
      bio: bio,
    );

    state = AsyncValue.data(updated);
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<Map<String, dynamic>>>(
  (ref) => ProfileNotifier(),
);
