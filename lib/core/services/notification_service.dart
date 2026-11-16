import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../constants/notification_messages.dart';
import 'storage_service.dart';

/// NotificationService handles scheduling 13-hour inactivity reminders
/// with a customized, pleasant water-pour sound effect at a gentle volume.
class NotificationService extends GetxService {
  static NotificationService get to => Get.find<NotificationService>();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _inactivityNotificationId = 1301;
  static const String _channelId = 'water_bottle_reminder_channel';
  static const String _channelName = 'Bottle Pour Reminder';
  static const String _channelDesc =
      'Notifications sent when you have been away from the water puzzle.';
  static const String _soundName = 'pour_soft';

  bool _isInitialized = false;

  Future<NotificationService> init() async {
    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      // Create Android Notification Channel with custom sound
      final AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound(_soundName),
      );

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Request notification permission for Android 13+
      await _requestPermissions();

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully.');
    } catch (e) {
      debugPrint('NotificationService: Init error: $e');
    }

    return this;
  }

  Future<void> _requestPermissions() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('NotificationService: Permission request error: $e');
    }
  }

  /// Cancels existing reminder and schedules a new 13-hour inactivity notification.
  /// Called whenever the app is closed, paused, or minimized.
  Future<void> schedule13HourReminder() async {
    if (!_isInitialized) return;

    try {
      // Cancel previous scheduled notification if any
      await _notifications.cancel(id: _inactivityNotificationId);

      final scheduledDate =
          tz.TZDateTime.now(tz.local).add(const Duration(hours: 13));

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(_soundName),
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentSound: true,
        sound: '$_soundName.wav',
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Pick next unique engaging message from 100-message pool (rotates sequentially without repeating)
      final pool = NotificationMessages.pool;
      final msgIndex = StorageService.to.getNextNotificationIndex(pool.length);
      final message = pool[msgIndex];

      await _notifications.zonedSchedule(
        id: _inactivityNotificationId,
        title: message.title,
        body: message.body,
        scheduledDate: scheduledDate,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      debugPrint(
          'NotificationService: Scheduled #$msgIndex ("${message.title}") for $scheduledDate');
    } catch (e) {
      debugPrint('NotificationService: schedule13HourReminder error: $e');
    }
  }

  /// Cancels the scheduled reminder when user opens and actively plays the app.
  Future<void> cancelReminder() async {
    if (!_isInitialized) return;
    try {
      await _notifications.cancel(id: _inactivityNotificationId);
      debugPrint('NotificationService: Pending 13-hour reminder canceled.');
    } catch (e) {
      debugPrint('NotificationService: cancelReminder error: $e');
    }
  }
}
