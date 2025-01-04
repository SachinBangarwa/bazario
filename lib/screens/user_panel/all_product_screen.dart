import 'package:bazario/models/product_model.dart';
import 'package:bazario/screens/user_panel/product_detail_screen.dart';
import 'package:bazario/utils/app_constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';

class AllProductScreen extends StatelessWidget {
  const AllProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppConstant.appTextColor),
        centerTitle: true,
        backgroundColor: AppConstant.appSceColor,
        title: const Text(
          AppConstant.allProductText,
          style: TextStyle(color: AppConstant.appTextColor),
        ),
      ),
     body:  FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('products')
              .get(),
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
                child: GridView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                        childAspectRatio: 1,
                        crossAxisCount: 2),
                    itemCount: snapShot.data!.docs.length,
                    itemBuilder: (context, index) {
                      QueryDocumentSnapshot data = snapShot.data!.docs[index];
                      ProductModel productModel = ProductModel(
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
                          updatedAt: data['updatedAt']);
                      return GestureDetector(
                        onTap: () {
                          Get.to(() =>  ProductDetailScreen(productModel:productModel));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              FillImageCard(color: Colors.teal.withOpacity(0.2),
                                borderRadius: 20,
                                width: Get.width / 2.4,
                                heightImage: Get.height / 10,
                                imageProvider: CachedNetworkImageProvider(
                                    productModel.productImages[0],),
                                title:  Text(
                                      productModel.productName,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                footer: Row(
                                  children: [
                                    Text(
                                      'Rs.${productModel.salePrice}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                    Text(
                                      productModel.fullPrice,
                                      style: const TextStyle(
                                          color: AppConstant.appSceColor,
                                          fontSize: 10,decoration: TextDecoration.lineThrough
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              );
            } else {
              return const SizedBox();
            }
          }),
    );
  }
}

