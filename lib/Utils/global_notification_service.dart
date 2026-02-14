import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';

class GlobalNotificationService {
  static Future<void> show({
    required String title,
    required String message,
    Color bgColor = Colors.green,
  }) async {
    _playRingtoneSafe();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.rawSnackbar(
        title: title,
        message: message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: bgColor,
        //colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        borderRadius: 12,
      );
    });
  }

  static Future<void> _playRingtoneSafe() async {
    if (kIsWeb) return;

    try {
      await FlutterRingtonePlayer().play(
        android: AndroidSounds.notification,
        ios: IosSounds.glass,
        volume: 1.0,
        looping: false,
        
      );
    } catch (_) {
      // Plugin not registered or unsupported platform.
    }
  }
}
