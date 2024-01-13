import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whats_app/data_All/SharedPreferences.dart';

class ProfileProvider extends ChangeNotifier {

  Future<void> currentUserData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore
        .collection('users')
        .where('userId', isEqualTo: UserDetails.userId.toString())
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        final users = value.docs.first;

        print("users::${users.data()}");
        final userData = users.data() as Map<String, dynamic>;
        LocalDataSaver.setUserImage(userData["userImage"]);
        LocalDataSaver.setUserPhone(userData["userPhone"]);
        LocalDataSaver.setUserId(userData["userId"]);
        LocalDataSaver.setUserName(userData["userName"]);
        LocalDataSaver.setUserCountry(userData["userCountry"]);
        LocalDataSaver.setUserCountryCode(userData["userCountryCode"]);
        await getUserDetails();

        notifyListeners();
      }
    });
  }
}
