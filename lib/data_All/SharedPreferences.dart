import 'package:shared_preferences/shared_preferences.dart';

class UserDetails {
  static String? userId;
  static String? userPhone;
  static String? userCountry;
  static String? userCountryCode;
  static String? userImage;
  static String? userTime;
  static String? lastMessage;
  static String? userName;
  static String? userFcmToken;
}

class LocalDataSaver {
  static const userIDKey = "User ID Key";
  static const userPhoneKey = "Phone Key";
  static const loginKey = "Login Key";
  static const countryKey = "Country Key";
  static const countryCodeKey = "Country Code Key";
  static const imageKey = "Image Key";
  static const timeKey = "Time Key";
  static const nameKey = "Name Key";
  static const lastMessagekey = "lastMessage Key";
  static const userFcmTokenKey = "userFcmToken Key";

  static Future<bool> setUserId(String userId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(userIDKey, userId);
  }

  static Future<String?> getUserId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userIDKey);
  }
  static Future<bool> setLastMessage(String lastMessage) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(lastMessagekey, lastMessage);
  }

  static Future<String?> getLastMessage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(lastMessagekey);
  }

  static Future<bool> setUserPhone(String userPhone) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(userPhoneKey, userPhone);
  }

  static Future<String?> getUserPhone() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userPhoneKey);
  }

  static Future<bool> setUserCountry(String userCountry) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(countryKey, userCountry);
  }

  static Future<String?> getUserCountry() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(countryKey);
  }

  static Future<bool> setUserCountryCode(String userCountryCode) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(countryCodeKey, userCountryCode);
  }

  static Future<String?> getUserCountryCode() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(countryCodeKey);
  }

  static Future<bool> setUserImage(String userImage) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(imageKey, userImage);
  }

  static Future<String?> getUserImage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(imageKey);
  }

  static Future<bool> setUserTime(String userTime) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(timeKey, userTime);
  }

  static Future<String?> getUserTime() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(timeKey);
  }

  static Future<bool> setUserName(String userName) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(nameKey, userName);
  }

  static Future<String?> getUserName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(nameKey);
  }
 static Future<bool> setUserFcmToken(String userFcmToken) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(userFcmTokenKey, userFcmToken);
  }

  static Future<String?> getUserFcmToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userFcmTokenKey);
  }

  static Future<bool> setUserLogin(bool isLogin) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setBool(loginKey, isLogin);
  }

  static Future<bool?> getUserLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(loginKey);
  }
}

Future getUserDetails() async {
  UserDetails.userId = await LocalDataSaver.getUserId();
  UserDetails.userPhone = await LocalDataSaver.getUserPhone();
  UserDetails.userName = await LocalDataSaver.getUserName();
  UserDetails.userCountry = await LocalDataSaver.getUserCountry();
  UserDetails.userCountryCode = await LocalDataSaver.getUserCountryCode();
  UserDetails.userImage = await LocalDataSaver.getUserImage();
  UserDetails.userTime = await LocalDataSaver.getUserTime();
  UserDetails.lastMessage = await LocalDataSaver.getLastMessage();
  UserDetails.userFcmToken = await LocalDataSaver.getUserFcmToken();
}

Future clearUserDetails() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.clear();
  await sharedPreferences.remove("User ID Key");
  LocalDataSaver.setUserLogin(false);
  await getUserDetails();
  print("UserDetails.userId::${UserDetails.userId}");
}
