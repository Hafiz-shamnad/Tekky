import 'dart:async';
import 'package:flutter/foundation.dart';

/// A ChangeNotifier that listens to a Stream and triggers GoRouter refresh
/// whenever the stream emits a value.
///
/// GoRouter needs a Listenable to know when to reevaluate redirect logic.
/// Riverpod providers expose `.stream`, so we wrap it here.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    // Immediately notify once to ensure router initializes correctly
    notifyListeners();

    // Listen to stream and notify router whenever auth changes
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
