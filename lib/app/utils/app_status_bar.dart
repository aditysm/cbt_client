import 'dart:io';
import 'dart:async';
import 'package:aplikasi_cbt/app/controllers/volume_controller.dart';
import 'package:aplikasi_cbt/app/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:aplikasi_cbt/app/controllers/connection_controller.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';

class AppStatusBar extends StatefulWidget {
  final String role;
  final String kioskInfo;
  final bool fromUjian;

  const AppStatusBar({
    super.key,
    this.role = "Siswa",
    this.fromUjian = false,
    this.kioskInfo = "Akses dibatasi (Kiosk Mode)",
  });

  @override
  State<AppStatusBar> createState() => _AppStatusBarState();
}

class _AppStatusBarState extends State<AppStatusBar> {
  late Timer _timer;
  final RxString timeString = "".obs;
  final RxString dateString = "".obs;

  final RxDouble volume = 0.0.obs;
  final volumeController = VolumeController.instance;
  final nativeVolumeController = Get.find<VolumeNativeController>();
  final dbService = Get.find<DatabaseService>();
  @override
  void initState() {
    super.initState();

    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());

    if (Platform.isAndroid || Platform.isIOS) {
      volumeController.addListener((v) => volume.value = v);
      volumeController.getVolume().then((v) => volume.value = v);
    } else if (Platform.isWindows) {
      ever(nativeVolumeController.volume, (v) {
        volume.value = v;
      });

      Future.microtask(() async {
        await nativeVolumeController.initVolume();
        volume.value = nativeVolumeController.volume.value;
      });
    }
  }

  void _updateTime() async {
    final waktuServerResult = await dbService.query(
      "SELECT DATE_FORMAT(SYSDATE(), '%Y-%m-%d %H:%i:%s') AS serverTime",
    );

    DateTime now;
    if (waktuServerResult.isNotEmpty) {
      final serverTimeStr = waktuServerResult.first['serverTime'] as String;
      now = DateTime.parse(serverTimeStr);
    } else {
      now = DateTime.now();
    }
    timeString.value = DateFormat("HH:mm").format(now);
    dateString.value = DateFormat("dd/MM/yyyy").format(now);
  }

  @override
  void dispose() {
    _timer.cancel();
    if (Platform.isAndroid || Platform.isIOS) {
      volumeController.removeListener();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionService = Get.put(ConnectionService());
    final isDesktop = MediaQuery.of(context).size.width > 1005;
    double baseFont = 12;
    double baseIcon = !isDesktop ? 18 : 20;

    return Obx(() {
      final current = connectionService.connectionResults.firstWhere(
        (r) => r != ConnectivityResult.none,
        orElse: () => ConnectivityResult.none,
      );

      IconData wifiIcon;
      String? messageWifi;

      switch (current) {
        case ConnectivityResult.wifi:
          wifiIcon = Icons.wifi;
          final wifiName = connectionService.wifiName.value;
          messageWifi =
              wifiName != null ? "Terhubung ke $wifiName" : "Terhubung ke WiFi";
          break;

        case ConnectivityResult.mobile:
          wifiIcon = Icons.network_cell;
          final provider =
              connectionService.carrierName.value ?? "Jaringan Seluler";
          messageWifi = "Terhubung ke $provider";
          break;

        case ConnectivityResult.ethernet:
          wifiIcon = Icons.settings_ethernet;
          messageWifi = "Terhubung ke Ethernet";
          break;

        case ConnectivityResult.none:
        default:
          wifiIcon = Icons.wifi_off;
          messageWifi = "Tidak Terhubung";
          break;
      }

      IconData volumeIcon;
      if (volume.value == 0) {
        volumeIcon = Icons.volume_off;
      } else if (volume.value < 0.5) {
        volumeIcon = Icons.volume_down;
      } else {
        volumeIcon = Icons.volume_up;
      }

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: !isDesktop ? 10 : 18,
          vertical: !isDesktop ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          border: Border(
            top: BorderSide(color: Colors.grey.shade800, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: "Keluar Aplikasi",
              icon: Icon(
                Icons.power_settings_new,
                color: Colors.red.shade400,
                size: baseIcon + 2,
              ),
              onPressed: () {
                AllMaterial.exitApp(fromUjian: widget.fromUjian);
              },
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: "Volume: ${(volume.value * 100).toInt()}%",
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Get.bottomSheet(
                        Container(
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.35,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: Obx(() {
                            IconData icon;
                            if (volume.value == 0) {
                              icon = Icons.volume_off;
                            } else if (volume.value < 0.5) {
                              icon = Icons.volume_down;
                            } else {
                              icon = Icons.volume_up;
                            }

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, color: Colors.white, size: 40),
                                Slider(
                                  value: volume.value,
                                  min: 0,
                                  max: 1,
                                  divisions: 100,
                                  onChanged: (v) {
                                    volume.value = v;
                                    if (Platform.isWindows) {
                                      nativeVolumeController.setVolume(v);
                                    } else {
                                      volumeController.setVolume(v);
                                    }
                                  },
                                ),
                                Text(
                                  "Volume: ${(volume.value * 100).toInt()}%",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                          }),
                        ),
                      );
                    },
                    child: Icon(
                      volumeIcon,
                      size: baseIcon,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Tooltip(
                  message: messageWifi,
                  child: Icon(
                    wifiIcon,
                    size: baseIcon,
                    color: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(width: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Obx(() => Text(
                          timeString.value,
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: baseFont,
                          ),
                        )),
                    Obx(() => Text(
                          dateString.value,
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: baseFont,
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
