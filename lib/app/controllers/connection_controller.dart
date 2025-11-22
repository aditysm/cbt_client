import 'dart:async';
import 'dart:io';

import 'package:aplikasi_cbt/app/utils/toast_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';

class ConnectionService extends GetxService {
  final RxBool hasConnection = true.obs;
  final RxList<ConnectivityResult> connectionResults =
      <ConnectivityResult>[ConnectivityResult.none].obs;
  final wifiName = RxnString();
  final carrierName = RxnString();

  late StreamSubscription<List<ConnectivityResult>> _subscription;
  final _networkInfo = NetworkInfo();
  bool _isSnackbarShown = false;

  Future<void> _updateNetworkInfo() async {
    try {
      final wifi = await _networkInfo.getWifiName();
      wifiName.value = wifi;
    } catch (e) {
      print("Gagal ambil nama jaringan: $e");
      wifiName.value = null;
    }
  }

  Future<ConnectionService> init() async {
    await _checkConnection();

    _subscription = Connectivity().onConnectivityChanged.listen(
      (results) async {
        connectionResults.assignAll(results);

        bool connected = false;
        for (var result in results) {
          if (await _hasInternet(result)) {
            connected = true;
            break;
          }
        }

        hasConnection.value = connected;

        if (!connected && !_isSnackbarShown) {
          _isSnackbarShown = true;
          ToastService.show("Tidak ada koneksi internet!");
        }

        if (connected && _isSnackbarShown) {
          Get.closeAllSnackbars();
          _isSnackbarShown = false;
        }
        _updateNetworkInfo();
      },
    );

    return this;
  }

  Future<void> _checkConnection() async {
    final results = await Connectivity().checkConnectivity();
    connectionResults.assignAll(results);

    bool connected = false;
    for (var result in results) {
      if (await _hasInternet(result)) {
        connected = true;
        _updateNetworkInfo();
        break;
      }
    }
    hasConnection.value = connected;
  }

  Future<bool> _hasInternet(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) return false;

    try {
      final lookup = await InternetAddress.lookup('google.com');
      return lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkConnection(
      {Duration timeout = const Duration(seconds: 5)}) async {
    final results = await Connectivity().checkConnectivity();

    bool hasRadioConnection = results.any((r) => r != ConnectivityResult.none);
    if (!hasRadioConnection) return false;

    try {
      final lookup =
          await InternetAddress.lookup('google.com').timeout(timeout);
      return lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  void onInit() {
    init();
    super.onInit();
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
