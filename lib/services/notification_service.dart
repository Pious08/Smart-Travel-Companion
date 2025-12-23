import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  // Schedule daily reminder
  static Future<void> scheduleDailyReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    final travelAlertsEnabled = prefs.getBool('travelAlertsEnabled') ?? true;

    if (!notificationsEnabled || !travelAlertsEnabled) return;

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminders',
      channelDescription: 'Daily travel reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      'Travel Reminder',
      'Don\'t forget to check your flight status and itinerary!',
      details,
    );
  }

  // Send feature update notification
  static Future<void> sendFeatureUpdate(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;

    if (!notificationsEnabled) return;

    const androidDetails = AndroidNotificationDetails(
      'feature_updates',
      'Feature Updates',
      channelDescription: 'App feature updates',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      'New City Guide Available!',
      'Explore the new $cityName travel guide',
      details,
    );
  }

  // Send promotional notification
  static Future<void> sendPromotionalNotification(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    final promotionalEnabled = prefs.getBool('promotionalNotifications') ?? true;

    if (!notificationsEnabled || !promotionalEnabled) return;

    const androidDetails = AndroidNotificationDetails(
      'promotions',
      'Promotions',
      channelDescription: 'Promotional offers',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      2,
      'Special Offer!',
      message,
      details,
    );
  }

  // Send targeted notification (e.g., for Japan bucket list users)
  static Future<void> sendTargetedNotification(
    String title,
    String message,
    bool hasJapanInBucketList,
  ) async {
    if (!hasJapanInBucketList) return;

    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    final promotionalEnabled = prefs.getBool('promotionalNotifications') ?? true;

    if (!notificationsEnabled || !promotionalEnabled) return;

    const androidDetails = AndroidNotificationDetails(
      'targeted',
      'Targeted Offers',
      channelDescription: 'Personalized travel offers',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      3,
      title,
      message,
      details,
    );
  }

  // Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}