import 'dart:async';

import 'package:flutter/foundation.dart';

/// Standard go_router adapter: turns any [Stream] into a [Listenable] so
/// GoRouter can re-run its `redirect` callback whenever the stream emits.
///
/// Used to wire `AuthService.instance.onAuthStateChange` (sign in / sign
/// out / token refresh) into the router without GoRouter needing to know
/// anything about Supabase directly.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
