import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:whats_app/data_All/SharedPreferences.dart';
import 'package:whats_app/provider/phone_provider.dart';
import 'package:whats_app/provider/profile_provider.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Title :${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Paylod: ${message.data}");
}

class FirebaseApps {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    print("Token: $fcmToken");
    print("Token: ${UserDetails.userId}");
    LocalDataSaver.setUserFcmToken(fcmToken.toString());
    if (UserDetails.userId != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(UserDetails.userId)
          .update({"userFcmToken": UserDetails.userFcmToken});
    }
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}
