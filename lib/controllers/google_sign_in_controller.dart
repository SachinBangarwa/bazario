
import 'package:bazario/controllers/get_device_token_controller.dart';
import 'package:bazario/models/user_model.dart';
import 'package:bazario/screens/user_panel/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInController extends GetxController {
  GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future googleSignInWithCloud() async {
    final GetDeviceTokenController getDeviceTokenController=Get.put(GetDeviceTokenController());
    try {
      GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        EasyLoading.show(status: "Please wait..");
        GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        AuthCredential authCredential = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken);

        UserCredential userCredential =
            await firebaseAuth.signInWithCredential(authCredential);
        User? user = userCredential.user;
        if (user != null) {
          UserModel userModel = UserModel(
              uId: user.uid,
              userName: user.displayName.toString(),
              email: user.email.toString(),
              phone: user.phoneNumber.toString(),
              userImg: user.photoURL.toString(),
              userDeviceToken: getDeviceTokenController.deviceToken.toString(),
              country: '',
              userAddress: '',
              street: '',
              city: '',
              isAdmin: false,
              isActive: true,
              createdOn: DateTime.now());

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(userModel.toJson())
              .then((_) {
            EasyLoading.dismiss();
            Get.offAll(() => const MainScreen());
          });
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      print(e);
    }
  }
}
