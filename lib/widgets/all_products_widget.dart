import 'package:bazario/models/product_model.dart';
import 'package:bazario/screens/user_panel/product_detail_screen.dart';
import 'package:bazario/utils/app_constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';

class AllProductsWidget extends StatelessWidget {
  const AllProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('products')
            .where('isSale', isEqualTo: true)
            .get(),
        builder: (context, snapShot) {
          if (snapShot.hasError) {
            return const Center(
              child: Text('Error'),
            );
          } else if (snapShot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: Get.height / 5,
              child: const Center(
                child: CupertinoActivityIndicator(),
              ),
            );
          } else if (snapShot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No product found!'),
            );
          } else if (snapShot.data != null) {
            return SizedBox(
              height: Get.height / 3.5,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, top: 15),
                child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
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
                        onTap: () {
                          Get.to(() =>  ProductDetailScreen(productModel:productModel));
                              },
                        child: FillImageCard(
                          borderRadius: 20,
                          width: Get.width / 2.4,
                          heightImage: Get.height / 6,
                          imageProvider: CachedNetworkImageProvider(
                              productModel.productImages[index]),
                          title: Center(
                              child: Text(
                                productModel.productName,
                                style: const TextStyle(fontSize: 12),
                              )),
                          footer: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Rs.${productModel.salePrice}',
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                ' ${productModel.fullPrice}',
                                style: const TextStyle(
                                    color: AppConstant.appSceColor,
                                    fontSize: 10,
                                    decoration: TextDecoration.lineThrough
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }
}
