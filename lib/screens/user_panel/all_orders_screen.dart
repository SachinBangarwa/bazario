import 'package:bazario/controllers/cart_price_controller.dart';
import 'package:bazario/models/order_model.dart';
import 'package:bazario/screens/user_panel/add_review_screen.dart';
import 'package:bazario/utils/app_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  final CartPriceController cartPriceController =
      Get.put(CartPriceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppConstant.appTextColor),
        centerTitle: true,
        backgroundColor: AppConstant.appSceColor,
        title: const Text(
          AppConstant.allOrderText,
          style: TextStyle(color: AppConstant.appTextColor),
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .doc(user!.uid)
              .collection('conformOrders')
              .snapshots(),
          builder: (context, snapShot) {
            if (snapShot.hasError) {
              return const Center(
                child: Text('Error'),
              );
            } else if (snapShot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            } else if (snapShot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No product found!'),
              );
            } else if (snapShot.data != null) {
              return SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapShot.data!.docs.length,
                        itemBuilder: (context, index) {
                          QueryDocumentSnapshot data =
                              snapShot.data!.docs[index];
                          OrderModel orderModel = OrderModel(
                            productId: data['productId'],
                            categoryId: data['categoryId'],
                            productName: data['productName'],
                            categoryName: data['categoryName'],
                            salePrice: data['salePrice'],
                            fullPrice: data['fullPrice'],
                            productImages: data['productImages'],
                            deliveryTime: data['deliveryTime'],
                            isSale: data['isSale'],
                            productDescription: data['productDescription'],
                            createdAt: data['createdAt'],
                            updatedAt: data['updatedAt'],
                            productQuantity: data['productQuantity'],
                            productTotalPrice: data['productTotalPrice'],
                            customerId: data['customerId'],
                            customerDeviceToken: data['customerDeviceToken'],
                            customerAddress: data['customerAddress'],
                            customerName: data['customerName'],
                            customerPhone: data['customerPhone'],
                            status: false,
                          );
                          cartPriceController.fetchProductPrice();
                          return Card(
                            elevation: 5,
                            color: AppConstant.appTextColor,
                            child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppConstant.appTextColor,
                                  backgroundImage: NetworkImage(
                                    orderModel.productImages[0],
                                  ),
                                ),
                                title: Text(orderModel.productName),
                                subtitle: Row(
                                  children: [
                                    Text(orderModel.productTotalPrice
                                        .toString()),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    orderModel.status
                                        ? const Text(
                                            'Pending..',
                                            style:
                                                TextStyle(color: Colors.green),
                                          )
                                        : const Text('Delivered',
                                            style: TextStyle(color: Colors.red))
                                  ],
                                ),
                                trailing: orderModel.isSale
                                    ? MaterialButton(
                                        padding: const EdgeInsets.all(4),
                                        color: Colors.blue.withOpacity(0.4),
                                        minWidth: 8.0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        onPressed: () {
                                          Get.to(() => AddReviewScreen(
                                              oderModel: orderModel));
                                        },
                                        child: const Text(
                                          'Review',
                                          style: TextStyle(color: Colors.black),
                                        ))
                                    : const SizedBox()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
          }),
    );
  }
}
