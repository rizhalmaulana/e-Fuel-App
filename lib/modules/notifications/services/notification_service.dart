import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../transactions/penerimaan/services/penerimaan_api_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final PenerimaanApiService _apiService = PenerimaanApiService();

  bool _isInitialized = false;

  Future<void> init() async {
    // Cek jika sudah pernah di-init, stop agar tidak muncul popup lagi/setup ulang
    if (_isInitialized) return;

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      _messaging.onTokenRefresh.listen((newToken) {
        syncTokenToServer(newToken);
      });

      _setupInteractedMessage();
    }

    _isInitialized = true;
  }

  Future<void> syncTokenToServer([String? token]) async {
    try {
      String? fcmToken = token ?? await _messaging.getToken();

      if (fcmToken != null) {
        print("🔥 FCM Token Device: $fcmToken");
        await _apiService.updateFcmToken(fcmToken);
      }
    } catch (e) {
      print("Error syncing token: $e");
    }
  }

  void _setupInteractedMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageNavigation(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        Get.snackbar(
          message.notification!.title ?? 'Notifikasi Baru',
          message.notification!.body ?? '',
          backgroundColor: Colors.white,
          colorText: Colors.black,
          onTap: (_) {
            _handleMessageNavigation(message);
          },
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
        );
      }
    });
  }

  void _handleMessageNavigation(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      String type = message.data['type'] ?? '';
      String transactionId = message.data['id'] ?? '';

      if (type == 'approval_transaksi') {
        Get.toNamed(Routes.PENERIMAAAN_VERIFIKASI_BAST, arguments: {
          'noBast': transactionId,
        });
      }
      else if (type == 'info') {
        Get.toNamed(Routes.HOME);
      }
    }
  }
}