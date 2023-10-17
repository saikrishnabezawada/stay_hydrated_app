//import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import 'package:timezone/timezone.dart' as tz;

class NotificationServices {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        // didReceiveLocalNotificationStream.add(
        //   ReceivedNotification(
        //     id: id,
        //     title: title,
        //     body: body,
        //     payload: payload,
        //   ),
        // );
      },
      //notificationCategories: darwinNotificationCategories,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      //linux: initializationSettingsLinux,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        // switch (notificationResponse.notificationResponseType) {
        //   case NotificationResponseType.selectedNotification:
        //     selectNotificationStream.add(notificationResponse.payload);
        //     break;
        //   case NotificationResponseType.selectedNotificationAction:
        //     if (notificationResponse.actionId == navigationActionId) {
        //       selectNotificationStream.add(notificationResponse.payload);
        //     }
        //     break;
        // }
      },
      //onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
            'Stay Hydrated ID', 'Stay Hydrated Name',
            importance: Importance.high),
        iOS: DarwinNotificationDetails());
  }

  Future sendNotifications(
      {int id = 0,
      required String? title,
      required String? body,
      String? payload}) async {
    return flutterLocalNotificationsPlugin.show(
        id, title, body, notificationDetails());
  }

  // Future sendWorkoutDrinkNotifications(){
  //   return flutterLocalNotificationsPlugin.
  // }

  Future sendPeriodicNotifications(
      {required int id, String? title, String? body, String? payload}) async {
    await flutterLocalNotificationsPlugin.periodicallyShow(
        id, title, body, RepeatInterval.values[15], notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exact);

    // return flutterLocalNotificationsPlugin.show(
    //     id, title, body, notificationDetails());
  }

  Future scheduleNotifications(
      {int? id,
      String? title,
      String? body,
      String? payload,
      required DateTime scheduledDateTime}) async {
    return flutterLocalNotificationsPlugin.zonedSchedule(
      id ?? 0,
      title,
      body,

      tz.TZDateTime.now(tz.local).add(Duration()),
      //tz.TZDateTime.from(scheduledDateTime, tz.local),
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void listOfScheduleNotifications(
      {int id = 0,
      String? title,
      String? body,
      String? payload,
      required List<Time> scheduledDateTimeList}) async {
    for (int i = 0; i < scheduledDateTimeList.length; i++) {
      await scheduleDailyNotification(
          id: i,
          title: title ?? "Stay Hydrated",
          body: body ?? "Hey, Time to drink water",
          scheduledTime: scheduledDateTimeList[i]);
    }
  }

  tz.TZDateTime _nextInstanceOfTime(time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.UTC);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);

    // Get the current UTC time.
    final utcDateTime = tz.TZDateTime.now(tz.local).toUtc();
    print("${utcDateTime}");
    // Get the current local time in London.
    final localDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').parse(utcDateTime.toString());

    // Calculate the difference between UTC and local time.
    final timeZoneOffset =
        utcDateTime.timeZoneOffset - localDateTime.timeZoneOffset;

    // print("Scheduled Time: ${scheduledDate.add(timeZoneOffset)}");
    // print("Difference    : ${timeZoneOffset}");
    // print("Duration      : ${scheduledDate.add(Duration(hours: 5))}");
    return scheduledDate.add(timeZoneOffset);
  }

  void checkTimeStamps(time) {
    // Get the current UTC time.
    final utcDateTime = tz.TZDateTime.now(tz.local).toUtc();
    print("${utcDateTime}");
    // Get the current local time in London.
    final localDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').parse(utcDateTime.toString());

    // Calculate the difference between UTC and local time.
    final timeZoneOffset =
        utcDateTime.timeZoneOffset - localDateTime.timeZoneOffset;

    // Print the difference.
    print(
        'The difference between UTC and local time in London is ${timeZoneOffset} hours.');

    print("${utcDateTime.add(timeZoneOffset)}");
    print("${utcDateTime.add(-timeZoneOffset)}");
  }

  Future<void> scheduleDailyNotification(
      {int? id,
      String? title,
      String? body,
      String? payload,
      required Time scheduledTime}) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(id ?? 0, title, body,
        _nextInstanceOfTime(scheduledTime), notificationDetails(),
        // const NotificationDetails(
        //   android: AndroidNotificationDetails('daily notification channel id',
        //       'daily notification channel name',
        //       channelDescription: 'daily notification description'),
        // ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(id) async {
    await flutterLocalNotificationsPlugin.cancel(--id);
  }

  //id, title, body,  notificationDetails());
}
