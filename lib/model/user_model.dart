class UserModel {
  String? userId;
  String? userPhone;
  String? userCountry;
  String? userCountryCode;
  String? userImage;
  String? userTime;
  String? userName;
  String? userFcmToken;
  bool? isPhoto;


  UserModel({
    this.userId,
    this.userPhone,
    this.userCountry,
    this.userCountryCode,
    this.userImage,
    this.userName,
    this.userTime,
    this.userFcmToken,
    this.isPhoto,
  });

  UserModel.fromMap(Map<String, dynamic> map) {
    userId = map["userId"];
    userPhone = map["userPhone"];
    userCountry = map["userCountry"];
    userCountryCode = map["userCountryCode"];
    userImage = map["userImage"];
    userName = map["userName"];
    userTime = map["userTime"];
    userFcmToken = map["userFcmToken"];
    isPhoto = map["isPhoto"];
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "userPhone": userPhone,
      "userCountry": userCountry,
      "userCountryCode": userCountryCode,
      "userImage": userImage,
      "userName": userName,
      "userTime": userTime,
      "userFcmToken": userFcmToken,
      "isPhoto": isPhoto,
    };
  }
}
