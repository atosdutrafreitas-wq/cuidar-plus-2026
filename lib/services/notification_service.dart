import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show Color;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/medication_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    if (kIsWeb) {
      await _requestFcmPermission();
      return;
    }

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _requestFcmPermission();
  }

  Future<void> _requestFcmPermission() async {
    try {
      await _fcm.requestPermission(
          alert: true, badge: true, sound: true);
    } catch (_) {}
  }

  Future<String?> getFcmToken() async {
    try {
      return await _fcm.getToken();
    } catch (_) {
      return null;
    }
  }

  void _onNotificationTap(NotificationResponse response) {}

  Future<void> scheduleMedicationAlerts({
    required MedicationModel medication,
    required String elderlyName,
  }) async {
    if (kIsWeb) return;

    for (final timeStr in medication.scheduledTimes) {
      final parts = timeStr.split(':');
      if (parts.length != 2) continue;
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      final now = DateTime.now();
      var scheduledDate =
          DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _scheduleLocal(
        id: _notifId(medication.id, timeStr, 30),
        title: 'Lembrete — $elderlyName',
        body: '${medication.name} (${medication.dosage}) em 30 minutos',
        scheduledAt: scheduledDate.subtract(
            Duration(minutes: medication.alertConfig.minutesBefore1)),
        payload: 'medication:${medication.id}',
      );

      await _scheduleLocal(
        id: _notifId(medication.id, timeStr, 2),
        title: 'Hora da medicação — $elderlyName',
        body: '${medication.name} (${medication.dosage}) em 2 minutos!',
        scheduledAt: scheduledDate.subtract(
            Duration(minutes: medication.alertConfig.minutesBefore2)),
        payload: 'medication:${medication.id}',
      );
    }
  }

  Future<void> _scheduleLocal({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  }) async {
    if (scheduledAt.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'cuidar_plus_medications',
      'Medicações',
      channelDescription: 'Alertas de medicação do Cuidar+',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _local.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledAt, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> showHelpAlert({required String elderlyName}) async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'cuidar_plus_help',
      'Ajuda',
      channelDescription: 'Alertas de pedido de ajuda',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      color: Color(0xFFD32F2F),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _local.show(
      99999,
      'PEDIDO DE AJUDA',
      '$elderlyName precisa de ajuda!',
      details,
      payload: 'help',
    );
  }

  Future<void> cancelMedicationAlerts(String medicationId) async {
    if (kIsWeb) return;
    for (int i = 0; i < 100; i++) {
      await _local.cancel(medicationId.hashCode + i);
    }
  }

  Future<void> cancelAll() async {
    if (!kIsWeb) await _local.cancelAll();
  }

  int _notifId(String medicationId, String time, int offsetMinutes) {
    return (medicationId + time + offsetMinutes.toString()).hashCode.abs() %
        2147483647;
  }
}
