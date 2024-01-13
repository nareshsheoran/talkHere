// ignore_for_file: sort_child_properties_last, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whats_app/data_All/SharedPreferences.dart';
import 'package:whats_app/data_All/appButton.dart';
import 'package:whats_app/data_All/app_color.dart';
import 'package:whats_app/data_All/font_sizes.dart';
import 'package:whats_app/provider/profile_provider.dart';
import 'package:whats_app/uiHelper/uiHelper.dart';
import 'package:whats_app/ui_design/home.dart';
import 'package:whats_app/provider/phone_provider.dart';

class ProfileSignUp extends StatefulWidget {
  const ProfileSignUp({Key? key}) : super(key: key);

  @override
  State<ProfileSignUp> createState() => _ProfileSignUpState();
}

class _ProfileSignUpState extends State<ProfileSignUp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PhoneProvider>(builder: (context, value, child) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppFontSize.font24,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(children: [
              Center(
                child:
                Stack(children: [
                  CircleAvatar(
                    radius: AppFontSize.font75,
                    backgroundColor: AppColor.amber,
                    child: value.userProfileImage == null
                        ? CircleAvatar(
                            radius: AppFontSize.font70,
                            child: Icon(
                              Icons.person,
                              size: AppFontSize.font100,
                            ),
                          )
                        : CircleAvatar(
                            radius: AppFontSize.font70,
                            backgroundImage:
                                NetworkImage(value.userProfileImage!),
                          ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 20,
                    child: InkWell(
                      onTap: () {
                        value.showPhotoOptions(context);
                      },
                      child: CircleAvatar(
                        backgroundColor: AppColor.black,
                        child: Icon(Icons.camera_alt, color: AppColor.white),
                        radius: AppFontSize.font20,
                      ),
                    ),
                  )
                ]),
              ),
              SizedBox(height: AppFontSize.font30),
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: AppColor.amber,
                  size: AppFontSize.font30,
                ),
                title: Text(
                  'Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppFontSize.font16,
                  ),
                ),
                subtitle: TextField(
                    controller: value.nameController,
                    keyboardType: TextInputType.name,
                    cursorColor: AppColor.amber,
                    decoration: InputDecoration(
                      counterText: "",
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColor.amber, width: AppFontSize.font2)),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColor.amber, width: AppFontSize.font2)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColor.amber, width: AppFontSize.font2)),
                    )),
              ),
              SizedBox(
                height: AppFontSize.font260,
              ),
              InkWell(
                onTap: () {
                  if (value.userProfileImage == null) {
                    UIHelper.showAlertDialog(context, "Incomplete Data",
                        "Please Upload your Profile Photo");
                  } else if (value.nameController.text.trim().isEmpty) {
                    UIHelper.showAlertDialog(
                        context, "Incomplete Data", "Please enter your Name");
                  } else {
                    UIHelper.showLoadingDialog(context, "Creating Profile...");

                    value.addUser(context).whenComplete(() async {
                      LocalDataSaver.setUserLogin(true);
                      Provider.of<ProfileProvider>(context, listen: false)
                          .currentUserData()
                          .whenComplete(() async {
                        await getUserDetails();
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
                            (route) => false);
                      });
                    });
                  }
                },

                child:
                value.nameController.text.trim().isEmpty?SizedBox():
                appButton(AppFontSize.font150, 'SUBMIT', AppColor.amber,
                    AppColor.white),
              ),
            ]),
          ),
        ),
      );
    });
  }
}
