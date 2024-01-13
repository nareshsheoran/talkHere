// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whats_app/data_All/SharedPreferences.dart';
import 'package:whats_app/data_All/appButton.dart';
import 'package:whats_app/data_All/app_color.dart';
import 'package:whats_app/data_All/font_sizes.dart';
import 'package:whats_app/main.dart';
import 'package:whats_app/notification_service.dart';
import 'package:whats_app/provider/home_provider.dart';
import 'package:whats_app/provider/phone_provider.dart';
import 'package:whats_app/provider/profile_provider.dart';
import 'package:whats_app/uiHelper/uiHelper.dart';
import 'package:whats_app/ui_design/chat_room.dart';
import 'package:whats_app/ui_design/phone_number.dart';
import 'package:whats_app/ui_design/searchRoom.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    Provider.of<ProfileProvider>(context, listen: false).currentUserData();
    LocalNotificationService.getInstance()!.getInitialMessage();
    LocalNotificationService.getInstance()!.onMessage();
    LocalNotificationService.getInstance()!.onMessageOpenedApp();
    LocalNotificationService.getInstance()!.getDeviceTokenToSendNotification();
    LocalNotificationService.getInstance()!.initialize(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, provider, child) {
      return Scaffold(
          appBar: AppBar(
            iconTheme:
                IconThemeData(color: AppColor.white, size: AppFontSize.font24),
            backgroundColor: AppColor.amber,
            centerTitle: true,
            title: Text(
              'Text Me...',
              style: TextStyle(
                  color: AppColor.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppFontSize.font24,
                fontStyle: FontStyle.italic
              ),
            ),
          ),
          drawer: Drawer(
            child: Column(children: [
              SizedBox(
                height: AppFontSize.font30,
              ),
              CircleAvatar(
                  radius: AppFontSize.font85,
                  backgroundColor: AppColor.amber,
                  child: InkWell(
                    onTap: () {
                      showImageViewer(
                          context,
                          Image.network(UserDetails.userImage!)
                              .image,
                          swipeDismissible: true,
                          doubleTapZoomable: true);
                    },
                    child: CircleAvatar(
                        radius: AppFontSize.font80,
                        backgroundImage: NetworkImage(UserDetails.userImage!)),
                  )),
              SizedBox(
                height: AppFontSize.font30,
              ),
              Text(
                UserDetails.userName!,
                style: TextStyle(
                    color: AppColor.black,
                    fontWeight: FontWeight.bold,
                    fontSize: AppFontSize.font20),
              ),
              SizedBox(
                height: AppFontSize.font10,
              ),
              Text(
                "${(UserDetails.userCountryCode)} ${(UserDetails.userPhone)}",
                style: TextStyle(
                    color: AppColor.black,
                    fontWeight: FontWeight.bold,
                    fontSize: AppFontSize.font20),
              ),
              SizedBox(
                height: AppFontSize.font10,
              ),
              Text(
                UserDetails.userCountry!,
                style: TextStyle(
                    color: AppColor.black,
                    fontWeight: FontWeight.bold,
                    fontSize: AppFontSize.font20),
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Do you Want to LogOut?"),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("No")),
                          TextButton(
                              onPressed: () async {
                                provider.auth.signOut();
                                LocalDataSaver.setUserLogin(false);
                                await clearUserDetails();
                                await getUserDetails();

                                UIHelper.snackMessage(
                                    context, "User Logout successfully");
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Phone_No()));
                              },
                              child: Text("Yes")),
                        ],
                      );
                    },
                  );
                },
                child: appButton(AppFontSize.font150, 'LOGOUT',
                    AppColor.amber, AppColor.white),
              ),
              SizedBox(
                height: AppFontSize.font40,
              )
            ]),
          ),
          body: provider.allUser(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.amber,
        child: Icon(Icons.search,color: AppColor.white),
        onPressed: () {
          analytics.logEvent(
            name: 'home_search',
            parameters: {'event': "HomePage"},
          );

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Search(),
              ));
        },
      ),);
    });
  }
}
