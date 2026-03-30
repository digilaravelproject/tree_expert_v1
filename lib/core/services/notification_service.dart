import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class AppNotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin pluginInstance = FlutterLocalNotificationsPlugin();

  Future<AppNotificationService> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await pluginInstance.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle click
      },
    );
    return this;
  }

  Future<void> showSyncProgress({
    required int id,
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'sync_channel_v1',
      'Data Sync',
      channelDescription: 'Upload progress',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
    );

    final NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await pluginInstance.show(id, title, body, platformDetails);
  }

  Future<void> showSyncComplete({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'sync_complete_v1',
      'Sync Finished',
      channelDescription: 'Success notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await pluginInstance.show(id, title, body, platformDetails);
  }

  Future<void> cancel(int id) async {
    await pluginInstance.cancel(id);
  }
}
