import 'package:firebase_messaging/firebase_messaging.dart';

Future<String> getCustomerDeviceToken() async {
  try {
    String? deviceToken = await FirebaseMessaging.instance.getToken();

    if (deviceToken != null) {
      return deviceToken;
    } else {
     throw Exception('Error : Device Token ');
    }
  }catch(e){
    throw  Exception(e);
  }
}
