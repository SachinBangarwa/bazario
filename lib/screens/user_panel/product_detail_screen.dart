import 'dart:async';

import 'package:bazario/models/cart_model.dart';
import 'package:bazario/models/product_model.dart';
import 'package:bazario/screens/user_panel/cart_screen.dart';
import 'package:bazario/utils/app_constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetailScreen extends StatelessWidget {
  ProductDetailScreen({super.key, required this.productModel});

  final ProductModel productModel;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppConstant.appTextColor),
        centerTitle: true,
        backgroundColor: AppConstant.appSceColor,
        title: const Text(
          AppConstant.productDetailText,
          style: TextStyle(color: AppConstant.appTextColor),
        ),
        actions: [
          IconButton(onPressed: ()=>Get.to(()=>const CartScreen()), icon: const Icon(Icons.shopping_cart))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            CarouselSlider(
              items: productModel.productImages
                  .map((images) => ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: images,
                          alignment: Alignment.topRight,
                          placeholder: (context, url) => const ColoredBox(
                            color: Colors.white,
                            child: Center(
                              child: CupertinoActivityIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          fit: BoxFit.cover,
                          width: Get.width - 10,
                        ),
                      ))
                  .toList(),
              options: CarouselOptions(
                  scrollDirection: Axis.horizontal,
                  autoPlay: true,
                  aspectRatio: 2.5,
                  viewportFraction: 1),
            ),
            SizedBox(
              height: Get.height / 60,
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 5,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(productModel.productName),
                        const Icon(Icons.favorite_outline),
                      ],
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.topLeft,
                      child: productModel.isSale == true &&
                              productModel.salePrice.isEmpty
                          ? Text('PKR : ${productModel.fullPrice}')
                          : Text('PKR : ${productModel.salePrice}')),
                  Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.topLeft,
                      child: Text('Category : ${productModel.categoryName}')),
                  Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.topLeft,
                      child: const Text('Product Detail -')),
                  Container(
                      padding:
                          const EdgeInsets.only(bottom: 20, left: 8, right: 8),
                      alignment: Alignment.topLeft,
                      child: Text(productModel.productDescription)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildAddToCartHandel('WhatsApp', () {}),
                      buildAddToCartHandel('Add To Cart', () async {
                        await checkProductExistence(user: user);
                      }),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkProductExistence(
      {User? user, int quantityIncrement = 1}) async {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('cart')
        .doc(user!.uid)
        .collection('cartOrders')
        .doc(productModel.productId);

    DocumentSnapshot snapshot = await documentReference.get();

    if (snapshot.exists) {
      int productQuantity = snapshot['productQuantity'];
      int updateQuantity = productQuantity + quantityIncrement;
      double productSubTotal = double.parse(productModel.isSale
              ? productModel.salePrice
              : productModel.fullPrice) *
          updateQuantity;

      await documentReference.update({
        'productQuantity': updateQuantity,
        'productSubTotal': productSubTotal,
      });
    } else {
      await FirebaseFirestore.instance.collection('cart').doc(user.uid).set({
        'uId': user.uid,
        'createdAt': DateTime.now(),
      });
      CartModel cartModel = CartModel(
          productId: productModel.productId,
          categoryId: productModel.categoryId,
          productName: productModel.productName,
          categoryName: productModel.categoryName,
          salePrice: productModel.salePrice,
          fullPrice: productModel.fullPrice,
          productImages: productModel.productImages,
          deliveryTime: productModel.deliveryTime,
          isSale: productModel.isSale,
          productDescription: productModel.productDescription,
          productQuantity: 1,
          productSubTotal: double.parse(productModel.fullPrice),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());
      await documentReference.set(cartModel.toMap());
    }
  }

  Widget buildAddToCartHandel(
    String name,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: AppConstant.appSceColor,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            )),
        onPressed: onPressed,
        child: Text(
          name,
          style: const TextStyle(
              color: AppConstant.appTextColor, fontWeight: FontWeight.w500),
        ));
  }
}
