import 'package:bazario/controllers/get_device_token_controller.dart';
import 'package:bazario/models/user_model.dart';
import 'package:bazario/utils/app_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  var isPasswordVisible = false.obs;

  Future<UserCredential?> signUpWithCloud(
      String email,
      String userName,
      String password,
      String city,
      String phone,
      ) async {
    try {
      final GetDeviceTokenController getDeviceTokenController=Get.put(GetDeviceTokenController());
      EasyLoading.show(status: 'Please Wait..');
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (userCredential.user != null) {
        await userCredential.user!.sendEmailVerification();
        EasyLoading.show(status: 'Email send Verify..');
        UserModel userModel = UserModel(
            uId: userCredential.user!.uid,
            userName: userName,
            email: email,
            phone: phone,
            userImg: '',
            userDeviceToken: getDeviceTokenController.deviceToken.toString(),
            country: '',
            userAddress: '',
            street: '',
            city: city,
            isAdmin: false,
            isActive: true,
            createdOn: DateTime.now());
        await fireStore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toJson());
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
