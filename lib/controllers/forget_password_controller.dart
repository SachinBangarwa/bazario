import 'package:bazario/screens/auth_ui/sign_in_screen.dart';
import 'package:bazario/utils/app_constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class ForgetPasswordController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> forgetPasswordCloud(
      String email,
      ) async {
    try {
      EasyLoading.show(status: 'Please Wait..');
       await auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Request Sent SuccessFully','Password  reefer link sent to :$email',
          snackPosition: SnackPosition.BOTTOM,
          colorText: AppConstant.appTextColor,
          backgroundColor: AppConstant.appSceColor);
      Get.offAll(()=>const SignInScreen());
      EasyLoading.dismiss();
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          colorText: AppConstant.appTextColor,
          backgroundColor: AppConstant.appSceColor);
    }
  }
}
