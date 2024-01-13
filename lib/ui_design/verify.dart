import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';
import 'package:whats_app/data_All/appButton.dart';
import 'package:whats_app/provider/phone_provider.dart';
import 'package:whats_app/ui_design/phone_number.dart';

import '../data_All/app_color.dart';
import '../data_All/font_sizes.dart';

class Verify extends StatefulWidget {
  const Verify({Key? key}) : super(key: key);

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  @override
  void initState() {
    Provider.of<PhoneProvider>(context, listen: false).startTimer();
    super.initState();
  }

  @override
  void dispose() {
    Provider.of<PhoneProvider>(context, listen: false).timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PhoneProvider>(
      builder: (context, value, child) {
        return Scaffold(
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
              'Verifying you number',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppFontSize.font18,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(children: [
                SizedBox(
                  height: AppFontSize.font10,
                ),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      TextSpan(
                        text:
                            'Waiting to automatically detect an SMS sent to ${value.codeController.text.trim()} ${value.phoneController.text.trim()}. ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: AppFontSize.font16,
                          color: AppColor.black,
                        ),
                      ),
                      TextSpan(
                        recognizer: TapAndPanGestureRecognizer()
                          ..onTapUp = (details) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Phone_No(),
                                ),
                                (route) => false);
                          },
                        text: "Wrong number?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppFontSize.font16,
                          color: AppColor.amber,
                        ),
                        // recognizer:
                      )
                    ])),
                SizedBox(
                  height: AppFontSize.font20,
                ),
                OTPTextField(
                  // controller: value.otpController,
                  onChanged: (values) {
                    value.otpCode = values;
                    setState(() {});
                  },
                  length: 6,
                  width: MediaQuery.of(context).size.width,
                  fieldWidth: 50,
                  style: TextStyle(fontSize: 17),
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldStyle: FieldStyle.box,
                  onCompleted: (pin) {
                    value.otpCode = pin.toString();
                    setState(() {});
                  },
                ),
                SizedBox(
                  height: AppFontSize.font10,
                ),
                Text(
                  'Enter 6-digit code',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: AppFontSize.font16,
                  ),
                ),
                SizedBox(
                  height: AppFontSize.font20,
                ),
                InkWell(
                  onTap: () {
                    if (value.secondsRemaining == 0) {
                      value.sendOtp(context)!.whenComplete((){
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Verify()), (route) => false);
                      });
                    }
                  },
                  child: Text(
                    "Didn't receive code? Resend",
                    style: TextStyle(
                        fontWeight: value.secondsRemaining == 0
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: AppFontSize.font16,
                        color: value.secondsRemaining == 0
                            ? AppColor.black
                            : Colors.grey),
                  ),
                ),
                Text(
                  "You may request a new code in 00:${value.secondsRemaining}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppFontSize.font16,
                  ),
                ),
                SizedBox(height: AppFontSize.font300,),
                value.otpCode?.length == 6
                    ? InkWell(
                        onTap: () {
                          value.otpVerify(context);
                        },
                        child: appButton(AppFontSize.font150, 'VERIFY',
                            AppColor.amber, AppColor.white))
                    : SizedBox(),
              ]),
            ),
          ),
        );
      },
    );
  }
}
