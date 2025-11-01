import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:dart_ipify/dart_ipify.dart';

class NetworkHelper {
  static final _info = NetworkInfo();

  static Future<String> getHostName() async {
    try {
      return Platform.localHostname;
    } catch (_) {
      return "UnknownHost";
    }
  }

  static Future<String> getIPAddress() async {
    try {
      final ip = await _info.getWifiIP();
      return ip ?? "UnknownIP";
    } catch (_) {
      return "UnknownIP";
    }
  }

  static Future<String> getMacAddress() async {
    try {
      final mac = await _info.getWifiBSSID();
      return mac ?? "UnknownMAC";
    } catch (_) {
      return "UnknownMAC";
    }
  }

  static Future<String> getPublicIP() async {
    try {
      final ipv4 = await Ipify.ipv4();
      return ipv4;
    } catch (_) {
      return "UnknownPublicIP";
    }
  }
}
