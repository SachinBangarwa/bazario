import 'package:bazario/models/order_model.dart';
import 'package:bazario/screens/user_panel/main_screen.dart';
import 'package:bazario/services/generate_order_id_service.dart';
import 'package:bazario/services/send_notification_service.dart';
import 'package:bazario/utils/app_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

void placeOrder(
    {required BuildContext context,
    required String customerToken,
    required String customerName,
    required String customerPhone,
    required String customerAddress}) async {
  final user = FirebaseAuth.instance.currentUser;
  final storeData = FirebaseFirestore.instance;
  try {
    EasyLoading.show(status: 'Please Wait..');
    if (user != null) {
      QuerySnapshot querySnapshot = await storeData
          .collection('cart')
          .doc(user.uid)
          .collection('cartOrders')
          .get();

      List<QueryDocumentSnapshot> queryDocList = querySnapshot.docs;
      for (final doc in queryDocList) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>;

        String id = generateOrderId();

        OrderModel cartModel = OrderModel(
          productId: data['productId'],
          categoryId: data['categoryId'],
          productName: data['productName'],
          categoryName: data['categoryName'],
          salePrice: data['salePrice'],
          fullPrice: data['fullPrice'],
          productImages: data['productImg'],
          deliveryTime: data['deliveryTime'],
          isSale: data['isSale'],
          productDescription: data['productDec'],
          createdAt: DateTime.now(),
          updatedAt: data['updatedAt'],
          productQuantity: data['productQuantity'],
          productTotalPrice: data['productSubTotal'],
          customerPhone: customerPhone,
          customerName: customerName,
          customerAddress: customerAddress,
          status: false,
          customerDeviceToken: customerToken,
          customerId: user.uid,
        );

        for (int i = 0; i < queryDocList.length; i++) {
          storeData.collection('orders').doc(user.uid).set({
            'customerName': customerName,
            'uId': user.uid,
            'customerPhone': customerPhone,
            'customerAddress': customerAddress,
            'createdAt': DateTime.now(),
            'customerDeviceToken': customerToken,
            'orderStatus': false
          });

          await storeData
              .collection('orders')
              .doc(user.uid)
              .collection('conformOrders')
              .doc(id)
              .set(cartModel.toMap());

          await storeData
              .collection('cart')
              .doc(user.uid)
              .collection('cartOrders')
              .doc(cartModel.productId.toString())
              .delete();
        }
        storeData
            .collection('notifications')
            .doc(user.uid)
            .collection('notifications')
            .doc()
            .set({
          'title': 'Order SuccessFully placed ${cartModel.productName}',
          'body': cartModel.productDescription,
          'isSeen': false,
          'createdAt': DateTime.now(),
          'image': cartModel.productImages,
          'fullPrice': cartModel.fullPrice,
          'salePrice': cartModel.salePrice,
          'isSale': cartModel.isSale,
          'productId': cartModel.productId,
        });
        await SendNotificationService().sendNotification(
          title: 'Order SuccessFully placed',
          token: 'fVy0w8OdR_aXWUBOU9z6QF:APA91bFw7L98D8D0QtbJgWLewyWN0_'
              'CnxdNXuyclFrr-9Gg6L-XzEe-Uuhc0nYAbCg_VWQ5eCIFwu4bT'
              '-a1_KYEvK5Rwbsb4OHZTNlesPn5YvqLmb9qduYc',
          body: 'This is a test notification',
          data: {'screen': 'notification'},
        );
      }
      Get.snackbar('Orders Conformed', 'Thank you for your order! ',
          backgroundColor: AppConstant.appMainColor,
          colorText: AppConstant.appTextColor,
          duration: const Duration(seconds: 5));
    }
    EasyLoading.dismiss();
    Get.offAll(() => const MainScreen());
  } catch (e) {
    EasyLoading.dismiss();
  }
}
