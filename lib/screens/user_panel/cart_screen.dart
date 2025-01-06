import 'package:bazario/controllers/cart_price_controller.dart';
import 'package:bazario/models/cart_model.dart';
import 'package:bazario/screens/user_panel/checkout_screen.dart';
import 'package:bazario/utils/app_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:get/get.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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
          AppConstant.cartText,
          style: TextStyle(color: AppConstant.appTextColor),
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('cart')
              .doc(user!.uid)
              .collection('cartOrders')
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
                          CartModel cartModel = CartModel(
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
                              createdAt: data['createdAt'],
                              updatedAt: data['updatedAt'],
                              productQuantity: data['productQuantity'],
                              productSubTotal: data['productSubTotal']);
                          cartPriceController.fetchProductPrice();
                          return SwipeActionCell(
                              key: ObjectKey(cartModel.productId),
                              trailingActions: [
                                SwipeAction(
                                    onTap: (handler) async {
                                      await FirebaseFirestore.instance
                                          .collection('cart')
                                          .doc(user!.uid)
                                          .collection('cartOrders')
                                          .doc(cartModel.productId)
                                          .delete();
                                    },
                                    title: 'Delete',
                                    closeOnTap: true,
                                    performsFirstActionWithFullSwipe: true,
                                    forceAlignmentToBoundary: true),
                                SwipeAction(
                                    onTap: (handler) {
                                      EasyLoading.show(
                                          status: 'Uni tree B2-W',
                                          dismissOnTap: true);
                                    },
                                    color: Colors.green,
                                    title: 'Tester',
                                    closeOnTap: true,
                                    performsFirstActionWithFullSwipe: true,
                                    forceAlignmentToBoundary: true),
                              ],
                              child: Card(
                                elevation: 5,
                                color: AppConstant.appTextColor,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppConstant.appTextColor,
                                    backgroundImage: NetworkImage(
                                      cartModel.productImages[index],
                                    ),
                                  ),
                                  title: Text(cartModel.productName),
                                  subtitle: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          cartModel.productSubTotal.toString()),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              await _onTabDecrementQuantity(
                                                  cartModel);
                                            },
                                            child: const CircleAvatar(
                                              radius: 12,
                                              backgroundColor:
                                                  AppConstant.appMainColor,
                                              child: Text('-'),
                                            ),
                                          ),
                                          SizedBox(
                                            width: Get.width / 20,
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              await _onTabIncrementQuantity(
                                                  cartModel);
                                            },
                                            child: const CircleAvatar(
                                              backgroundColor:
                                                  AppConstant.appMainColor,
                                              radius: 12,
                                              child: Text('+'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ));
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 2),
        child: Container(
          color: Colors.redAccent.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                    " Total  ${cartPriceController.totalPrice.toStringAsFixed(1)} : PKR",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              buildCheckOutCartHandel('CheckOut', () {
                Get.to(() => const CheckOutScreen());
              })
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onTabDecrementQuantity(CartModel cartModel) async {
    if (cartModel.productQuantity > 1) {
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(user!.uid)
          .collection('cartOrders')
          .doc(cartModel.productId)
          .update({
        'productQuantity': cartModel.productQuantity - 1,
        'productSubTotal': (double.parse(cartModel.fullPrice) *
                (cartModel.productQuantity - 1))
            .toDouble()
      });
    }
  }

  Future<void> _onTabIncrementQuantity(CartModel cartModel) async {
    if (cartModel.productQuantity > 0) {
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(user!.uid)
          .collection('cartOrders')
          .doc(cartModel.productId)
          .update({
        'productQuantity': cartModel.productQuantity + 1,
        'productSubTotal': (double.parse(cartModel.fullPrice) +
                double.parse(cartModel.fullPrice) * (cartModel.productQuantity))
            .toDouble()
      });
    }
  }

  Widget buildCheckOutCartHandel(
    String name,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(11),
                    bottomLeft: Radius.circular(11))),
            backgroundColor: AppConstant.appSceColor,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10)),
        onPressed: onPressed,
        child: Text(
          name,
          style: const TextStyle(
              color: AppConstant.appTextColor,
              fontWeight: FontWeight.w500,
              fontSize: 18),
        ));
  }
}
