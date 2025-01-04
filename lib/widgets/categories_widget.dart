import 'package:bazario/models/category_model.dart';
import 'package:bazario/screens/user_panel/single_category_products_screeen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';

class CategoriesWidget extends StatelessWidget {
  const CategoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseFirestore.instance.collection('categories').get(),
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
              child: Text('No category found!'),
            );
          } else if (snapShot.data != null) {
            return SizedBox(
              height: Get.height / 6,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: snapShot.data!.docs.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot data = snapShot.data!.docs[index];
                    CategoriesModel categoriesModel = CategoriesModel(
                        categoryId: data['categoryId'],
                        categoryImg: data['categoryImg'],
                        categoryName: data['categoryName'],
                        createdAt: data['createdAt'],
                        updatedAt: data['updateAt']);
                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.to(() => SingleCategoryProductScreen(
                              categoryId: categoriesModel.categoryId)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: FillImageCard(
                              borderRadius: 16,
                              width: Get.width / 4,
                              heightImage: Get.height / 12,
                              imageProvider: CachedNetworkImageProvider(
                                  categoriesModel.categoryImg),
                              title: Center(
                                  child: Text(
                                categoriesModel.categoryName,
                                style: const TextStyle(fontSize: 12),
                              )),
                            ),
                          ),
                        )
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
