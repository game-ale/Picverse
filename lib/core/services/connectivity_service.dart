import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Wraps [Connectivity] to expose a broadcast stream of online/offline state
/// and a synchronous check of the last known status.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  late final StreamController<bool> _controller;
  late StreamSubscription<List<ConnectivityResult>> _sub;
  bool _isOnline = true;

  bool get isOnline => _isOnline;
  Stream<bool> get onConnectivityChanged => _controller.stream;

  ConnectivityService() {
    _controller = StreamController<bool>.broadcast();
  }

  Future<void> init() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);

    _sub = _connectivity.onConnectivityChanged.listen((results) {
      final online = !results.contains(ConnectivityResult.none);
      if (online != _isOnline) {
        _isOnline = online;
        _controller.add(online);
      }
    });
  }

  void dispose() {
    _sub.cancel();
    _controller.close();
  }
}
