import 'package:bazario/models/category_model.dart';
import 'package:bazario/screens/user_panel/single_category_products_screeen.dart';
import 'package:bazario/utils/app_constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';

class AllCategoryScreen extends StatefulWidget {
  const AllCategoryScreen({super.key});

  @override
  State<AllCategoryScreen> createState() => _AllCategoryScreenState();
}

class _AllCategoryScreenState extends State<AllCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppConstant.appTextColor),
        centerTitle: true,
        backgroundColor: AppConstant.appSceColor,
        title: const Text(
          AppConstant.categoryMainText,
          style: TextStyle(color: AppConstant.appTextColor),
        ),
      ),
      body: FutureBuilder(
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
              return Padding(
                padding: const EdgeInsets.only(left: 15, top: 15),
                child: GridView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: 1,
                            crossAxisSpacing: 1,
                            childAspectRatio: 1.2,
                            crossAxisCount: 2),
                    itemCount: snapShot.data!.docs.length,
                    itemBuilder: (context, index) {
                      QueryDocumentSnapshot data = snapShot.data!.docs[index];
                      CategoriesModel categoriesModel = CategoriesModel(
                          categoryId: data['categoryId'],
                          categoryImg: data['categoryImg'],
                          categoryName: data['categoryName'],
                          createdAt: data['createdAt'],
                          updatedAt: data['updateAt']);
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => SingleCategoryProductScreen(
                              categoryId: categoriesModel.categoryId));
                        },
                        child: Row(
                          children: [
                            FillImageCard(
                              borderRadius: 20,
                              width: Get.width / 2.4,
                              heightImage: Get.height / 10,
                              imageProvider: CachedNetworkImageProvider(
                                  categoriesModel.categoryImg),
                              title: Center(
                                  child: Text(
                                categoriesModel.categoryName,
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
