import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:loyalty_card_app/core/models/loyalty_card.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(initSettings);
    _isInitialized = true;
  }

  Future<void> scheduleCardExpiryNotification(LoyaltyCard card) async {
    if (!_isInitialized) await initialize();

    if (card.expiryDate == null) return;

    final now = DateTime.now();
    final expiryDate = card.expiryDate!;
    
    // Schedule notification 7 days before expiry
    final notificationDate = expiryDate.subtract(const Duration(days: 7));
    
    if (notificationDate.isAfter(now)) {
      await _notifications.zonedSchedule(
        card.id.hashCode,
        'Card Expiry Reminder',
        'Your ${card.name} card expires in 7 days!',
        tz.TZDateTime.from(notificationDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'card_expiry_channel',
            'Card Expiry Notifications',
            channelDescription: 'Notifications for card expiry reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
} 