import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Timer? _timer;

  //id generator
  static int _id = 0;
  static int get id => _id++;

  static void initialize() {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
        )
      ],
    );
  }

  static void sendPeriodicNotification() {
    //timer to run show notification every 5 seconds
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) {
        show(
            title: 'Periodic Notification',
            body: 'This is a periodic notification');
      },
    );
  }

  static void cancelPeriodicNotifications() {
    _timer?.cancel();
  }

  static void show({required String title, required String body}) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'basic_channel',
        title: title,
        body: body,
      ),
    );
  }
}
