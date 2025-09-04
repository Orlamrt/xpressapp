// services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Controllers/controller.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _onNotificationTap(response);
      },
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      if (response.payload!.startsWith('session_')) {
        Get.toNamed('/calendar');
      } else if (response.payload!.startsWith('chat_')) {
        Get.toNamed('/chats');
      } else if (response.payload!.startsWith('task_')) {
        Get.toNamed('/tasks');
      }
    }
  }

  // NOTIFICACIONES PARA CITAS (AgendarView)
  Future<void> showAppointmentConfirmation(
    String patientName,
    DateTime dateTime,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'appointments_channel',
          'Confirmaciones de Cita',
          channelDescription: 'Notificaciones de confirmación de citas',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await notificationsPlugin.show(
      10,
      '✅ Cita Confirmada',
      'Cita con $patientName el ${_formatDate(dateTime)} a las ${_formatTime(dateTime)}',
      details,
      payload: 'session_${dateTime.millisecondsSinceEpoch}',
    );
  }

  Future<void> showAppointmentReminder(
    String patientName,
    DateTime sessionTime,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'reminders_channel',
          'Recordatorios de Cita',
          channelDescription: 'Recordatorios para sesiones programadas',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await notificationsPlugin.zonedSchedule(
      11,
      '⏰ Recordatorio de Cita',
      'Tienes una cita con $patientName en 30 minutos',
      tz.TZDateTime.from(
        sessionTime.subtract(const Duration(minutes: 30)),
        tz.local,
      ),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'session_${sessionTime.millisecondsSinceEpoch}',
    );
  }

  // NOTIFICACIONES PARA CHAT
  Future<void> showNewMessageNotification(
    String senderName,
    String message,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'chat_channel',
          'Mensajes de Chat',
          channelDescription: 'Notificaciones de nuevos mensajes',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await notificationsPlugin.show(
      20,
      '💬 Nuevo mensaje de $senderName',
      message.length > 50 ? '${message.substring(0, 50)}...' : message,
      details,
      payload: 'chat_$senderName',
    );
  }

  // NOTIFICACIONES PARA TAREAS
  Future<void> showTaskAssignment(String taskName, String assignedBy) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'tasks_channel',
          'Asignación de Tareas',
          channelDescription: 'Notificaciones de tareas asignadas',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await notificationsPlugin.show(
      30,
      '📋 Nueva Tarea Asignada',
      '$assignedBy te asignó la tarea: $taskName',
      details,
      payload: 'task_$taskName',
    );
  }

  Future<void> showTaskCompletionNotification(String taskName) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'tasks_channel',
          'Completación de Tareas',
          channelDescription: 'Notificaciones de tareas completadas',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await notificationsPlugin.show(
      31,
      '✅ Tarea Completada',
      'La tarea "$taskName" ha sido completada',
      details,
      payload: 'task_completed',
    );
  }

  // NOTIFICACIONES DE PROGRESO
  Future<void> showProgressAchievement(String achievement) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'progress_channel',
          'Logros de Progreso',
          channelDescription: 'Notificaciones de logros y progreso',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await notificationsPlugin.show(
      40,
      '🎉 ¡Nuevo Logro!',
      achievement,
      details,
    );
  }

  // NOTIFICACIONES PARA TERAPEUTAS
  Future<void> showTherapistHiredNotification(String therapistName) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'therapists_channel',
          'Contratación de Terapeutas',
          channelDescription: 'Notificaciones de contratación de terapeutas',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await notificationsPlugin.show(
      50,
      '👨‍⚕️ Terapeuta Contratado',
      'Has contratado a $therapistName como tu terapeuta',
      details,
      payload: 'therapist_$therapistName',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }
}
