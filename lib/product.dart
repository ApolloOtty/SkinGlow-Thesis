import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _notifications.initialize(settings);
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final androidDetails = const AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final androidDetails = const AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

class Product {
  String name;
  DateTime openingDate;
  int? expirationInMonths;
  DateTime? expirationDate;
  String? imagePath;
  String? goodComments;
  String? badComments;

  Product({
    required this.name,
    required this.openingDate,
    this.expirationInMonths,
    this.expirationDate,
    this.imagePath,
    this.goodComments,
    this.badComments,
  }) {
    scheduleNotifications();
  }

  bool get isExpired {
    final expiration = expirationDate ??
        (expirationInMonths != null
            ? DateTime(
                openingDate.year, openingDate.month + expirationInMonths!)
            : null);
    if (expiration != null && DateTime.now().isAfter(expiration)) {
      NotificationService.showNotification(
        id: hashCode,
        title: 'Product Expired',
        body: '$name has expired!',
      );
      return true;
    }
    return false;
  }

  void scheduleNotifications() {
    final expiration = expirationDate ??
        (expirationInMonths != null
            ? DateTime(
                openingDate.year, openingDate.month + expirationInMonths!)
            : null);

    if (expiration != null) {
      final expirationNotificationTime =
          expiration.subtract(const Duration(days: 1));
      final nearExpirationNotificationTime =
          expiration.subtract(const Duration(days: 7));

      NotificationService.scheduleNotification(
        id: hashCode,
        title: 'Product Expiration Alert',
        body: '$name is expiring soon!',
        scheduledDate: nearExpirationNotificationTime,
      );

      NotificationService.scheduleNotification(
        id: hashCode + 1,
        title: 'Product Expired',
        body: '$name has expired!',
        scheduledDate: expirationNotificationTime,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'openingDate': openingDate.toIso8601String(),
      'expirationInMonths': expirationInMonths,
      'expirationDate': expirationDate?.toIso8601String(),
      'imagePath': imagePath,
      'goodComments': goodComments,
      'badComments': badComments,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      openingDate: DateTime.parse(json['openingDate']),
      expirationInMonths: json['expirationInMonths'],
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'])
          : null,
      imagePath: json['imagePath'],
      goodComments: json['goodComments'],
      badComments: json['badComments'],
    );
  }
}
