// ignore_for_file: prefer_const_constructors

import 'package:country_calling_code_picker/picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whats_app/data_All/appButton.dart';
import 'package:whats_app/data_All/appDetails.dart';
import 'package:whats_app/data_All/app_color.dart';
import 'package:whats_app/data_All/font_sizes.dart';
import 'package:whats_app/provider/phone_provider.dart';
import 'package:whats_app/uiHelper/uiHelper.dart';

class Phone_No extends StatefulWidget {
  const Phone_No({Key? key}) : super(key: key);

  @override
  State<Phone_No> createState() => _Phone_NoState();
}

class _Phone_NoState extends State<Phone_No> {
  @override
  void initState() {
    super.initState();
    Provider.of<PhoneProvider>(context, listen: false).initCountry(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PhoneProvider>(builder: (context, provider, child) {
      return Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              actions: [
                Icon(
                  Icons.more_vert_outlined,
                ),
                SizedBox(
                  width: AppFontSize.font20,
                )
              ],
              centerTitle: true,
              title: Text(
                'Enter you phone number',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppFontSize.font18,
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            TextSpan(
                              text:
                                  '${AppDetails.appName} will need to verify your account. ',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: AppFontSize.font16,
                                color: AppColor.black,
                              ),
                            ),
                            TextSpan(
                              text: "What's my number?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppFontSize.font16,
                                color: AppColor.amber,
                              ),
                            )
                          ])),
                      SizedBox(
                        height: AppFontSize.font20,
                      ),
                      Container(
                        width: AppFontSize.font260,
                        child: Column(
                          children: [
                            TextField(
                                onTap: () {
                                  provider.showCountryPicker(context);
                                },
                                controller: provider.countryNameController,
                                readOnly: true,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  prefix: provider.countryFlag == null
                                      ? Image(
                                          image: NetworkImage(
                                              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI5x6k5q5YKfpLFGxrcRui0giJxnDfMByNNA&usqp=CAU"))
                                      : Image(
                                          height: AppFontSize.font16,
                                          image: AssetImage(
                                            provider.countryFlag.toString(),
                                            package: countryCodePackageName,
                                          )),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColor.amber,
                                          width: AppFontSize.font2)),
                                  border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColor.amber,
                                          width: AppFontSize.font2)),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColor.amber,
                                          width: AppFontSize.font2)),
                                  suffixIcon: Icon(
                                    Icons.expand_more,
                                    color: AppColor.amber,
                                  ),
                                )),
                            Row(
                              children: [
                                Container(
                                  width: AppFontSize.font80,
                                  child: TextField(
                                      controller: provider.codeController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColor.amber,
                                                width: AppFontSize.font2)),
                                        border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColor.amber,
                                                width: AppFontSize.font2)),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColor.amber,
                                                width: AppFontSize.font2)),
                                      )),
                                ),
                                SizedBox(
                                  width: AppFontSize.font10,
                                ),
                                Expanded(
                                  child: TextField(
                                      controller: provider.phoneController,
                                      keyboardType: TextInputType.number,
                                      cursorColor: AppColor.amber,
                                      decoration: InputDecoration(
                                        counterText: "",
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColor.amber,
                                                width: AppFontSize.font2)),
                                        border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColor.amber,
                                                width: AppFontSize.font2)),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColor.amber,
                                                width: AppFontSize.font2)),
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: AppFontSize.font20,
                      ),
                      Text(
                        'Carrier charges may apply',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: AppFontSize.font16,
                        ),
                      ),
                      SizedBox(
                        height: AppFontSize.font300,
                      ),
                      InkWell(
                        onTap: () {
                          if (provider.phoneController.text.trim().isEmpty) {
                            UIHelper.showAlertDialog(context, "Fill Number",
                                "Please fill your phone number");
                          } else if (provider.phoneController.text
                                  .trim()
                                  .length !=
                              10) {
                            UIHelper.showAlertDialog(context, "Incomplete Data",
                                "Phone Number is Incomplete Please Check And Enter Again ");
                          } else {
                            provider.sendOtp(context);
                          }
                        },
                        child: appButton(AppFontSize.font150, 'NEXT',
                            AppColor.amber, AppColor.white),
                      ),
                    ]),
              ),
            ),
          ),
        ],
      );
    });
  }
}
