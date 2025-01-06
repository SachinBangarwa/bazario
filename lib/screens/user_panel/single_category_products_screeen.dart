import 'package:bazario/models/product_model.dart';
import 'package:bazario/screens/user_panel/product_detail_screen.dart';
import 'package:bazario/utils/app_constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';

class SingleCategoryProductScreen extends StatefulWidget {
  const SingleCategoryProductScreen({
    super.key,
    required this.categoryId,
  });

  final String categoryId;

  @override
  State<SingleCategoryProductScreen> createState() => _AllCategoryScreenState();
}

class _AllCategoryScreenState extends State<SingleCategoryProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppConstant.appTextColor),
        centerTitle: true,
        backgroundColor: AppConstant.appSceColor,
        title: const Text(
          AppConstant.productMainText,
          style: TextStyle(color: AppConstant.appTextColor),
        ),
      ),
      body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('products')
              .where('categoryId', isEqualTo: widget.categoryId)
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
                child: Text('No category found!'),
              );
            } else if (snapShot.data != null) {
              return Padding(
                padding: const EdgeInsets.only(left: 15, top: 15),
                child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: 3,
                            crossAxisSpacing: 3,
                            childAspectRatio: 0.8,
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
                        onTap: () => Get.to(() =>
                            ProductDetailScreen(productModel: productModel)),
                        child: Row(
                          children: [
                            FillImageCard(
                              borderRadius: 20,
                              width: Get.width / 3,
                              heightImage: Get.height / 6,
                              imageProvider: CachedNetworkImageProvider(
                                  productModel.productImages[0]),
                              title: Center(
                                  child: Text(
                                overflow: TextOverflow.ellipsis,
                                productModel.productName,
                                style: const TextStyle(fontSize: 12),
                              )),
                            )
                          ],
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
