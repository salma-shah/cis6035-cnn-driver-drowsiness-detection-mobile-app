import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifService {
  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'drowsiness_alarm';
  static const String channelName = 'Drowsiness Alarms';
  static const String channelDescription =
      'Alerts for detected driver drowsiness';

  // initialize everything
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(
      settings: initializationSettings,
    );

    await createChannel();

    // android 13+ notification permission
    final androidImplementation =
        notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation
        ?.requestNotificationsPermission();
  }


  // notif channel
  Future<void> createChannel() async {
    const channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      playSound: true,
    );

    final androidImplementation =
        notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation
        ?.createNotificationChannel(channel);
  }

  // warning

  Future<void> showWarning() async {
    const androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails =
        NotificationDetails(
      android: androidDetails,
    );

    await notifications.show(
      id: 100,
      title: 'Drowsiness Warning',
      body:
          'Signs of driver drowsiness detected.',
      notificationDetails:
          notificationDetails,
    );
  }

  // critical

  Future<void> showCritical() async {
    const androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
    );

    const notificationDetails =
        NotificationDetails(
      android: androidDetails,
    );

    await notifications.show(
      id: 101,
      title: 'CRITICAL DROWSINESS ALERT',
      body:
          'Severe drowsiness detected. Please stop driving.',
      notificationDetails:
          notificationDetails,
    );
  }

  // cancel all warnings
  Future<void> cancelWarning() async {
    await notifications.cancel(
      id: 100,
    );
  }

  Future<void> cancelCritical() async {
    await notifications.cancel(
      id: 101,
    );
  }

  Future<void> cancelAll() async {
    await notifications.cancelAll();
  }

  Future<void> dispose() async {
    await cancelAll();
  }
}