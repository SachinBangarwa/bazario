import 'package:bazario/models/order_model.dart';
import 'package:bazario/models/review_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../utils/app_constant.dart';

class AddReviewScreen extends StatefulWidget {
  const AddReviewScreen({super.key, required this.oderModel});

  final OrderModel oderModel;

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final TextEditingController feedBackController = TextEditingController();
  double productRating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppConstant.appTextColor),
        centerTitle: true,
        backgroundColor: AppConstant.appSceColor,
        title: const Text(
          AppConstant.reviewText,
          style: TextStyle(color: AppConstant.appTextColor),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Add your rating and review',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  productRating = rating;
                });
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text('FeedBack'),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextFormField(
              controller: feedBackController,
              decoration:
                  const InputDecoration(labelText: 'Share your feedBack'),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          MaterialButton(
            color: Colors.yellow.withOpacity(0.8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onPressed: () async {
              EasyLoading.show(status: 'Please wait..');
              final user = FirebaseAuth.instance.currentUser;
              ReviewModel reviewModel = ReviewModel(
                customerName: widget.oderModel.customerName,
                customerPhone: widget.oderModel.customerPhone,
                customerDeviceToken: widget.oderModel.customerDeviceToken,
                customerId: widget.oderModel.customerId,
                feedback: feedBackController.text.trim(),
                rating: productRating.toString(),
                createdAt: DateTime.now(),
              );
              await FirebaseFirestore.instance
                  .collection('products')
                  .doc(widget.oderModel.productId)
                  .collection('reviews')
                  .doc(user!.uid)
                  .set(reviewModel.toMap());
              feedBackController.clear();
              EasyLoading.dismiss();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
