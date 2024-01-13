import 'dart:async';
import 'dart:io';

import 'package:country_calling_code_picker/functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:whats_app/data_All/font_sizes.dart';
import 'package:whats_app/provider/profile_provider.dart';
import 'package:whats_app/uiHelper/uiHelper.dart';
import 'package:whats_app/ui_design/home.dart';
import '../ui_design/profile_sign_up.dart';
import '../ui_design/verify.dart';
import '../data_All/SharedPreferences.dart';

class PhoneProvider extends ChangeNotifier {
  TextEditingController nameController = TextEditingController();
  TextEditingController countryNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  OtpFieldController otpController = OtpFieldController();
  String? countryFlag;
  String? verificationIds;
  String? otpCode;
  String? phoneNumber;
  String? profileName;
  bool isLoading = false;
  String? userProfileImage;
  File? imageFile;
  File? sendFile;
  final FirebaseAuth auth = FirebaseAuth.instance;

  void showCountryPicker(context) async {
    final country = await showCountryPickerSheet(context);
    if (country != null) {
      countryNameController =
          TextEditingController(text: country.name.toString());
      codeController =
          TextEditingController(text: country.callingCode.toString());
      countryFlag = country.flag.toString();
      notifyListeners();
    }
    notifyListeners();
  }

  void initCountry(context) async {
    final country = await getCountryByCountryCode(context, "IN");
    countryFlag = country?.flag.toString();
    countryNameController =
        TextEditingController(text: country?.name.toString());
    codeController =
        TextEditingController(text: country?.callingCode.toString());
    notifyListeners();
  }

  Future? sendOtp(context) async {
    UIHelper.showLoadingDialog(context, 'Sending OTP...');
    notifyListeners();
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber:
            '${codeController.text.trim()}${phoneController.text.trim()}',
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == "too-many-requests") {
            UIHelper.snackMessage(
                context, "Too many requests to log into this account.");
          } else {
            UIHelper.snackMessage(context, "Something went wrong");
          }
          print("verificationFailed error:::$e");
          Navigator.pop(context);
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          verificationIds = verificationId;
          Navigator.pop(context);
          notifyListeners();
          UIHelper.snackMessage(context, "OTP send successfully...");
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Verify()));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      UIHelper.snackMessage(context, "Something went wrong");
      Navigator.pop(context);
      notifyListeners();
    }
  }

  int secondsRemaining = 60;
  Timer? timer;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (secondsRemaining < 1) {
          timer.cancel();
        } else {
          secondsRemaining = secondsRemaining - 1;
        }
        notifyListeners();
      },
    );
  }

  otpVerify(context) async {
    UIHelper.showLoadingDialog(context, 'OTP Verifying...');
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationIds!, smsCode: otpCode!);
      await auth.signInWithCredential(credential);
      LocalDataSaver.setUserId(auth.currentUser!.uid);
      await getUserDetails();
      timer?.cancel();
      Navigator.pop(context);
      notifyListeners();
      FirebaseFirestore.instance
          .collection("users")
          .where('userId', isEqualTo: UserDetails.userId.toString())
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          LocalDataSaver.setUserLogin(true);
          notifyListeners();
          Provider.of<ProfileProvider>(context, listen: false)
              .currentUserData()
              .whenComplete(() {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Home(),
                ));
          });
        } else {
          addUser(context).whenComplete(() {
            notifyListeners();
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileSignUp(),
                ));
          });
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-verification-code") {
        UIHelper.snackMessage(context, "Please enter correct OTP");
      } else if (e.code == "session-expired") {
        UIHelper.snackMessage(context, "OTP session expired");
      } else {
        UIHelper.snackMessage(context, "Something went wrong");
      }
      Navigator.pop(context);
      print("otpVerify error:::${e}");
    }
  }

  Future addUser(context) async {
    getUserDetails();
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(UserDetails.userId)
          .set({
        "userId": UserDetails.userId,
        "userPhone": phoneController.text.trim(),
        "userCountry": countryNameController.text.trim(),
        "userCountryCode": codeController.text.trim(),
        "userImage": userProfileImage ?? "",
        "userTime": DateTime.now().toString(),
        "userName": nameController.text.trim() ?? "",
        "userFcmToken": UserDetails.userFcmToken ?? "",
        "isPhoto":
            userProfileImage == null && nameController.text.trim().isEmpty
                ? false
                : true,
      }, SetOptions(merge: true));
      userProfileImage == null
          ? UIHelper.snackMessage(context, "Login successfully...")
          : UIHelper.snackMessage(context, "Profile completed...");

      print('User added successfully.');
    } catch (e) {
      print('Error adding user: $e');
      UIHelper.snackMessage(context, "Something went wrong");
    }
  }


  getUserImageFirebase() async {
    final firebaseStorage = FirebaseStorage.instance;

    var snapshot = await firebaseStorage
        .ref()
        .child('images/${UserDetails.userId}')
        .putFile(imageFile!);
    userProfileImage = await snapshot.ref.getDownloadURL();
    LocalDataSaver.setUserImage(userProfileImage.toString());
    getUserDetails();
  }

  void showPhotoOptions(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Upload Profile Pictire"),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              onTap: () {
                getImage(context, ImageSource.gallery);
                Navigator.pop(context);
              },
              leading: Icon(Icons.photo, size: AppFontSize.font40),
              title: Text("Select from Gallery"),
            ),
            ListTile(
              onTap: () {
                getImage(context, ImageSource.camera);
                Navigator.pop(context);
              },
              leading: Icon(
                Icons.camera_alt,
                size: AppFontSize.font40,
              ),
              title: Text("Take a photo"),
            )
          ]),
        );
      },
    );
  }

  getImage(context, source) async {
    final firebaseStorage = FirebaseStorage.instance;
    final picker = ImagePicker();
    XFile? pickedFile;
    pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      // cropImages(pickedFile);
      var snapshot = await firebaseStorage
          .ref()
          .child('images/${UserDetails.userId}')
          .putFile(File(pickedFile.path));
      userProfileImage = await snapshot.ref.getDownloadURL();
      LocalDataSaver.setUserImage(userProfileImage.toString());
      LocalDataSaver.setUserId(UserDetails.userId!);
      addUser(context);
      await getUserDetails();
      notifyListeners();
      Navigator.of(context).pop();
    }
  }

  void cropImages(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper()
        .cropImage(sourcePath: file.path, compressQuality: 20);
    if (croppedImage != null) {
      imageFile = File(croppedImage.path);
      notifyListeners();
    }
  }
}
