// ignore_for_file: prefer_const_constructors, prefer_conditional_assignment, avoid_print, depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whats_app/data_All/SharedPreferences.dart';
import 'package:whats_app/data_All/appDetails.dart';

class LocalNotificationService {
  static LocalNotificationService? _instance;

  LocalNotificationService._internal();

  static LocalNotificationService? getInstance() {
    if (_instance == null) {
      _instance = LocalNotificationService._internal();
    }
    return _instance;
  }


  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static String deviceTokenToSendNotification = '';

  void getInitialMessage() {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print("New Notification");
        print("new Notification:${message.data["id"]}");
        // message.data["id"]=="Request"?Navigator.pushNamed(context, AppRoutes.HomePage):null;
      }
    });
  }

  void onMessage() {
    FirebaseMessaging.onMessage.listen((message) {
      print("FirebaseMessaging.onMessage.listen");
      if (message.notification != null) {
        print("onMessage.listen::${message.notification!.title}");
        print("onMessage.listen::${message.notification!.body}");
        print("onMessage.listen:::${message.data}");
        LocalNotificationService.createAndDisplayNotification(message);
      }
    });
  }

  void onMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("FirebaseMessaging.onMessageOpenedApp.listen");
      if (message.notification != null) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
        print("msg data:::${message.data}");
      }
    });
  }

  getDeviceTokenToSendNotification() async {
    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    final token = await fcm.getToken();
    deviceTokenToSendNotification = token.toString();
    LocalDataSaver.setUserFcmToken(token.toString());
    await getUserDetails();
    FirebaseFirestore.instance
        .collection("users")
        .doc(UserDetails.userId)
        .update({'userFcmToken': UserDetails.userFcmToken});
  }

  void initialize(context) {
    InitializationSettings initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher"));

    _notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? id) async {
      if (id!.isNotEmpty) {
        print("Customer service::::: $id");

        // Navigator.pushNamed(context, AppRoutes.HomePage);
      }
    });
  }

  static void createAndDisplayNotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          AppDetails.appChannelId,
          AppDetails.appChannelName,
          importance: Importance.high,
          priority: Priority.high,
          fullScreenIntent: true,
          channelShowBadge: true,
          // playSound: false,
          // sound: RawResourceAndroidNotificationSound("notification"),
        ),
      );
      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data['id'],
      );
    } on Exception catch (e) {
      print("createAndDisplayNotification error: $e");
    }
  }

  Future postNotification(msgTitle, msgBody, fcmToken, status) async {
    var requestBody = {
      "registration_ids": [fcmToken],
      "notification": {
        "title": msgTitle,
        "body": msgBody,
        "android_channel_id": AppDetails.appChannelId,
        "image": "Images.logoImg",
        "sound": true
      },
      "data": {
        "id": status,
        // 'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        // 'status': 'done'
      },
      // "to": fcmToken
    };

    var response =
        await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": 'key=${AppDetails.appServerKey}',
            },
            body: jsonEncode(requestBody));

    if (response.statusCode == 200) {
      print("==========>${response.body}");
    } else {
      throw Exception('Failed to create push notification.');
    }
  }
}

class AppLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("AppLifecycleState::${state}");
    if (state == AppLifecycleState.paused) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(UserDetails.userId)
          .update({'userOnline': "Away"});
    }
    else if (state == AppLifecycleState.resumed) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(UserDetails.userId)
          .update({'userOnline': "Active"});
    } else if (state == AppLifecycleState.inactive) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(UserDetails.userId)
          .update({'userOnline': "Offline"});
    }
  }
}
