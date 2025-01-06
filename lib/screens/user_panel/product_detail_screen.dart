import 'package:bazario/controllers/calculate_product_rating_controller.dart';
import 'package:bazario/models/cart_model.dart';
import 'package:bazario/models/product_model.dart';
import 'package:bazario/models/review_model.dart';
import 'package:bazario/screens/user_panel/cart_screen.dart';
import 'package:bazario/utils/app_constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productModel});

  final ProductModel productModel;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();

  static Future<void> sendMessageOnWhatsApp(ProductModel productModel) async {
    const number = '+918619012281';
    final message =
        'Hi!\nCheck out this amazing product available on the Bazario app:\n'
        '🛍️ Product Name: ${productModel.productName}\n'
        '💲 Price: ₹${productModel.fullPrice}\n'
        '📸 Image: ${productModel.productImages[0]}\n\n'
        'Order now on the Bazario app and get it delivered to your doorstep!\n'
        'Let me know if you have any questions or need help. 😊';

    final Uri url =
        Uri.parse('https://wa.me/$number?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  late final CalculateProductRatingController calculateProductRatingController =
      Get.put(CalculateProductRatingController(
          productId: widget.productModel.productId));

  @override
  void initState() {
    super.initState();
    calculateProductRatingController.calculateRating();
  }

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
          IconButton(
              onPressed: () => Get.to(() => const CartScreen()),
              icon: const Icon(Icons.shopping_cart))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CarouselSlider(
                items: widget.productModel.productImages
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
                          Text(widget.productModel.productName),
                          const Icon(Icons.favorite_outline),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10, left: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => RatingBarIndicator(
                                rating: calculateProductRatingController
                                    .averageRating.value,
                                direction: Axis.horizontal,
                                itemSize: 25.0,
                                itemCount: 5,
                                itemPadding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                              )),
                          Obx(() => Text(
                                calculateProductRatingController
                                    .averageRating.value
                                    .toStringAsFixed(1),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              )),
                        ],
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.topLeft,
                        child: widget.productModel.isSale == true &&
                                widget.productModel.salePrice.isEmpty
                            ? Text('PKR : ${widget.productModel.fullPrice}')
                            : Text('PKR : ${widget.productModel.salePrice}')),
                    Container(
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.topLeft,
                        child: Text(
                            'Category : ${widget.productModel.categoryName}')),
                    Container(
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.topLeft,
                        child: const Text('Product Detail -')),
                    Container(
                        padding: const EdgeInsets.only(
                            bottom: 20, left: 8, right: 8),
                        alignment: Alignment.topLeft,
                        child: Text(widget.productModel.productDescription)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        buildAddToCartHandel('WhatsApp', () {
                          ProductDetailScreen.sendMessageOnWhatsApp(
                              widget.productModel);
                        }),
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
              FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('products')
                      .doc(widget.productModel.productId)
                      .collection('reviews')
                      .get(),
                  builder: (context, snapShot) {
                    if (snapShot.hasError) {
                      return const Center(
                        child: Text('Error'),
                      );
                    } else if (snapShot.connectionState ==
                        ConnectionState.waiting) {
                      return SizedBox(
                        height: Get.height / 5,
                        child: const Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      );
                    } else if (snapShot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No review found!'),
                      );
                    } else if (snapShot.data != null) {
                      return ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: snapShot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final data = snapShot.data!.docs[index];
                            ReviewModel reviewModel = ReviewModel(
                                customerName: data['customerName'],
                                customerPhone: data['customerPhone'],
                                customerDeviceToken:
                                    data['customerDeviceToken'],
                                customerId: data['customerId'],
                                feedback: data['feedback'],
                                rating: data['rating'],
                                createdAt: ['createdAt']);
                            return Card(
                              elevation: 5,
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(reviewModel.customerName[0]),
                                ),
                                title: Text(reviewModel.customerName),
                                subtitle: Text(reviewModel.feedback),
                                trailing: Text(
                                  'Rt:${reviewModel.rating}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            );
                          });
                    } else {
                      return const SizedBox();
                    }
                  }),
            ],
          ),
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
        .doc(widget.productModel.productId);

    DocumentSnapshot snapshot = await documentReference.get();

    if (snapshot.exists) {
      int productQuantity = snapshot['productQuantity'];
      int updateQuantity = productQuantity + quantityIncrement;
      double productSubTotal = double.parse(widget.productModel.isSale
              ? widget.productModel.salePrice
              : widget.productModel.fullPrice) *
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
          productId: widget.productModel.productId,
          categoryId: widget.productModel.categoryId,
          productName: widget.productModel.productName,
          categoryName: widget.productModel.categoryName,
          salePrice: widget.productModel.salePrice,
          fullPrice: widget.productModel.fullPrice,
          productImages: widget.productModel.productImages,
          deliveryTime: widget.productModel.deliveryTime,
          isSale: widget.productModel.isSale,
          productDescription: widget.productModel.productDescription,
          productQuantity: 1,
          productSubTotal: double.parse(widget.productModel.fullPrice),
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
