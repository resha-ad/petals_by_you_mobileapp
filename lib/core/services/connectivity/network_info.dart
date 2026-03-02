import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class INetworkInfo {
  Future<bool> get isConnected;
}

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(Connectivity());
});

class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  @override
  Future<bool> get isConnected async {
    // Step 1: Quick connectivity check — if no network interface at all, fail fast
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      return false;
    }

    // Step 2: Try an actual TCP socket connection to a reliable host.
    // InternetAddress.lookup() uses the OS DNS cache and LIES when offline.
    // A socket connection CANNOT be faked by cache — it must reach the server.
    return await _canReachInternet();
  }

  Future<bool> _canReachInternet() async {
    // Try connecting to Cloudflare's DNS (1.1.1.1) on port 53.
    // This is the most reliable real-connectivity check:
    //   - No DNS involved (we use the raw IP)
    //   - Port 53 is almost never firewalled
    //   - Works on both emulator and physical device
    const targets = [
      ('1.1.1.1', 53), // Cloudflare DNS
      ('8.8.8.8', 53), // Google DNS
      ('208.67.222.222', 53), // OpenDNS
    ];

    for (final (host, port) in targets) {
      try {
        final socket = await Socket.connect(
          host,
          port,
          timeout: const Duration(seconds: 3),
        );
        socket.destroy();
        return true; // connected — we have internet
      } on SocketException {
        continue; // try next target
      }
    }
    return false; // all targets failed — truly offline
  }
}
