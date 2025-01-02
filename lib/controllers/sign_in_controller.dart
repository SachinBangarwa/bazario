import 'package:bazario/utils/app_constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;

  var isPasswordVisible = false.obs;

  Future<UserCredential?> signInWithCloud(
      String email,
      String password,
      ) async {
    try {
      EasyLoading.show(status: 'Please Wait..');
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (userCredential.user != null) {
        EasyLoading.dismiss();
        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          colorText: AppConstant.appTextColor,
          backgroundColor: AppConstant.appSceColor);
    }
    return null;
  }
}
