import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:win32audio/win32audio.dart';

class VolumeNativeController extends GetxController {
  final RxDouble volume = 0.0.obs;
  final AudioDeviceType _deviceType = AudioDeviceType.output;

  @override
  void onInit() {
    super.onInit();
    if (Platform.isWindows) {
      initVolume();
    }
  }

  Future<void> initVolume() async {
    try {
      final v = await Audio.getVolume(_deviceType);
      volume.value = v;
      print("Init volume (Windows): $v");
    } catch (e) {
      print('Audio.getVolume error: $e');
      volume.value = 0.0;
    }
  }

  Future<void> setVolume(double v) async {
    if (!Platform.isWindows) return;
    try {
      await Audio.setVolume(v, _deviceType);
      volume.value = v;
    } catch (e) {
      print('Audio.setVolume error: $e');
    }
  }

  @override
  void onClose() {
    // win32audio tidak menyediakan remove dengan id di doc umum; jika ada API remove, panggil di sini.
    super.onClose();
  }
}
