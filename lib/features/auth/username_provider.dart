import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api/profile_api.dart';

final usernameCheckProvider =
    StateNotifierProvider<UsernameCheckNotifier, AsyncValue<bool?>>(
  (ref) => UsernameCheckNotifier(),
);

class UsernameCheckNotifier extends StateNotifier<AsyncValue<bool?>> {
  UsernameCheckNotifier() : super(const AsyncValue.data(null));

  Timer? _debounce;

  void check(String username) {
    if (username.isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final available = await ProfileApi.checkUsernameAvailability(username);
        state = AsyncValue.data(available);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }
}
