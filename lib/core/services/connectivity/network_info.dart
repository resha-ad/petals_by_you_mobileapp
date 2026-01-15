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
    // First quick check: is there any network connection at all (Wi-Fi/mobile)?
    final result = await _connectivity.checkConnectivity();

    if (result.contains(ConnectivityResult.none)) {
      return false;
    }

    // If we have some kind of connection → do real internet check
    // return await _sacchaiKaiInternetChaKiNai();
    return true;
  }

  // // Real internet connectivity test by trying to resolve a domain
  // Future<bool> _sacchaiKaiInternetChaKiNai() async {
  //   try {
  //     final result = await InternetAddress.lookup('google.com');

  //     return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  //   } on SocketException catch (e) {
  //     return false;
  //   }
  // }
}
