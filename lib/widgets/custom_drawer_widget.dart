
import 'package:bazario/utils/app_constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../screens/auth_ui/welcome_screen.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Drawer(width: Get.width/1.4,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20))),
        backgroundColor: AppConstant.appSceColor,
        child: Wrap(
          runSpacing: 20,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 40, left: 10),
              child: ListTile(
                titleAlignment: ListTileTitleAlignment.center,
                title: Text('Waris',
                    style: TextStyle(color: AppConstant.appTextColor)),
                subtitle: Text('Version 1.0.5 ',
                    style: TextStyle(color: AppConstant.appTextColor)),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppConstant.appMainColor,
                  child: Text('S',
                      style: TextStyle(color: AppConstant.appTextColor)),
                ),
              ),
            ),
            const Divider(
              indent: 10,
              endIndent: 10,
              thickness: 1.5,
              color: Colors.grey,
            ),
            buildListTileHandler(
                title: 'Home',
                leading: const Icon(
                  Icons.home,
                  color: AppConstant.appTextColor,
                ),
                callBack: () {}),
            buildListTileHandler(
                title: 'Products',
                leading: const Icon(
                  Icons.production_quantity_limits,
                  color: AppConstant.appTextColor,
                ),
                callBack: () {}),
            buildListTileHandler(
                title: 'Orders',
                leading: const Icon(
                  Icons.shopping_bag,
                  color: AppConstant.appTextColor,
                ),
                callBack: () {}),
            buildListTileHandler(
                title: 'Contact',
                leading: const Icon(
                  Icons.help,
                  color: AppConstant.appTextColor,
                ),
                callBack: () {}),
            buildListTileHandler(
                title: 'Logout',
                leading: const Icon(
                  Icons.logout,
                  color: AppConstant.appTextColor,
                ),
                callBack: () async {
                  GoogleSignIn googleSignIn = GoogleSignIn();
                  FirebaseAuth auth = FirebaseAuth.instance;
                  await auth.signOut();
                  await googleSignIn.signOut();
                  Get.offAll(() => WelcomeScreen());
                }),
          ],
        ),
      ),
    );
  }

  Padding buildListTileHandler(
      {required String title,
      required Icon leading,
      required VoidCallback callBack}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListTile(
          onTap: callBack,
          titleAlignment: ListTileTitleAlignment.center,
          title: Text(title,
              style: const TextStyle(color: AppConstant.appTextColor)),
          leading: leading,
          trailing: const Icon(
            Icons.arrow_forward,
            size: 20,
            color: AppConstant.appTextColor,
          )),
    );
  }
}
