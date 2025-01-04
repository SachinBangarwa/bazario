import 'package:bazario/models/product_model.dart';
import 'package:bazario/screens/user_panel/product_detail_screen.dart';
import 'package:bazario/utils/app_constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';

class FlashSaleWidget extends StatelessWidget {
  const FlashSaleWidget({super.key});

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
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
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
                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.to(() =>
                              ProductDetailScreen(productModel: productModel)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: FillImageCard(
                              borderRadius: 16,
                              width: Get.width / 3.2,
                              heightImage: Get.height / 6.2,
                              imageProvider: CachedNetworkImageProvider(
                                  productModel.productImages[index]),
                              title: Text(
                                overflow: TextOverflow.ellipsis,
                                productModel.productName,
                                style: const TextStyle(fontSize: 10),
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
                                    ' ${productModel.fullPrice}',
                                    style: const TextStyle(
                                        color: AppConstant.appSceColor,
                                        fontSize: 10,
                                        decoration: TextDecoration.lineThrough),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: FillImageCard(
                            borderRadius: 16,
                            width: Get.width / 3.2,
                            heightImage: Get.height / 6.2,
                            imageProvider: CachedNetworkImageProvider(
                                productModel.productImages[0]),
                            title: Text(
                              overflow: TextOverflow.ellipsis,
                              productModel.categoryName,
                              style: const TextStyle(fontSize: 10),
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
                                  ' ${productModel.fullPrice}',
                                  style: const TextStyle(
                                      color: AppConstant.appSceColor,
                                      fontSize: 10,
                                      decoration: TextDecoration.lineThrough),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: FillImageCard(
                            borderRadius: 16,
                            width: Get.width / 3.2,
                            heightImage: Get.height / 6.2,
                            imageProvider: CachedNetworkImageProvider(
                                productModel.productImages[1]),
                            title: Text(
                              overflow: TextOverflow.ellipsis,
                              productModel.productName,
                              style: const TextStyle(fontSize: 10),
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
                                  ' ${productModel.fullPrice}',
                                  style: const TextStyle(
                                      color: AppConstant.appSceColor,
                                      fontSize: 10,
                                      decoration: TextDecoration.lineThrough),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: FillImageCard(
                            borderRadius: 16,
                            width: Get.width / 3.2,
                            heightImage: Get.height / 6.2,
                            imageProvider: CachedNetworkImageProvider(
                                productModel.productImages[0]),
                            title: Text(
                              overflow: TextOverflow.ellipsis,
                              productModel.categoryName,
                              style: const TextStyle(fontSize: 10),
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
                                  ' ${productModel.fullPrice}',
                                  style: const TextStyle(
                                      color: AppConstant.appSceColor,
                                      fontSize: 10,
                                      decoration: TextDecoration.lineThrough),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            );
          } else {
            return const SizedBox();
          }
        });
  }
}
