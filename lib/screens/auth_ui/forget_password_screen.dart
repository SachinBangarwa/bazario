import 'package:bazario/utils/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../controllers/forget_password_controller.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final ForgetPasswordController forgetPasswordController =
      Get.put(ForgetPasswordController());
  final userEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, isKeyBoardVisible) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppConstant.appSceColor,
          title: const Text(
            'Forget Password',
            style: TextStyle(color: AppConstant.appTextColor, fontSize: 25),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              isKeyBoardVisible
                  ? const Text(
                      'Welcome to my app',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    )
                  : Lottie.asset('assets/images/splash-icon.json'),
              SizedBox(
                height: Get.width / 8,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: userEmailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: AppConstant.appSceColor,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email),
                        contentPadding: const EdgeInsets.only(left: 8, top: 2),
                        hintText: 'Email',
                        hintStyle: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ),
              SizedBox(
                height: Get.width / 8,
              ),
              buildSignInWithCloud('Forget', () async {
                final userEmail = userEmailController.text.trim();
                if (userEmail.isEmpty) {
                  Get.snackbar('Error', 'Please enter  detail',
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: AppConstant.appTextColor,
                      backgroundColor: AppConstant.appSceColor);
                } else {
                  forgetPasswordController
                      .forgetPasswordCloud(userEmailController.text);
                }
              })
            ],
          ),
        ),
      );
    });
  }

  Widget buildSignInWithCloud(
    String name,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: AppConstant.appSceColor,
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 8)),
        onPressed: onPressed,
        child: Text(
          name,
          style: const TextStyle(
              color: AppConstant.appTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ));
  }
}
