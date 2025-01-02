class UserModel {
  String uId;
  String userName;
  String email;
  String phone;
  String userImg;
  String userDeviceToken;
  String country;
  String userAddress;
  String street;
  String city;
  bool isAdmin;
  bool isActive;
  dynamic createdOn;

  UserModel({
    required this.uId,
    required this.userName,
    required this.email,
    required this.phone,
    required this.userImg,
    required this.userDeviceToken,
    required this.country,
    required this.userAddress,
    required this.street,
    required this.city,
    required this.isAdmin,
    required this.isActive,
   required this.createdOn,
  });

  // Convert from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uId: json['uId'] as String,
      userName: json['userName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      userImg: json['userImg'] as String,
      userDeviceToken: json['userDeviceToken'] as String,
      country: json['country'] as String,
      userAddress: json['userAddress'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      isAdmin: json['isAdmin'] as bool,
      isActive: json['isActive'] as bool,
      createdOn: json['createdOn'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uId': uId,
      'userName': userName,
      'email': email,
      'phone': phone,
      'userImg': userImg,
      'userDeviceToken': userDeviceToken,
      'country': country,
      'userAddress': userAddress,
      'street': street,
      'city': city,
      'isAdmin': isAdmin,
      'isActive': isActive,
      'createdOn': createdOn,
    };
  }
}
