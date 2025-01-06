import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class CalculateProductRatingController extends GetxController {
  final String productId;

  CalculateProductRatingController({required this.productId});

  final fireStore = FirebaseFirestore.instance;

  RxDouble averageRating = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    calculateRating();
  }

  void calculateRating() {
    fireStore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .snapshots()
        .listen((snapShot) {
      if (snapShot.docs.isNotEmpty) {
        double totalRating = 0;
        int numberOfReviews = 0;
        for (var doc in snapShot.docs) {
          final ratingAsString = doc['rating'] as String;
          final rating = double.tryParse(ratingAsString);
          if (rating != null) {
            totalRating += rating;
            numberOfReviews++;
          }
        }
        if (numberOfReviews != 0) {
          print( 'rating average $averageRating');
          averageRating.value = totalRating / numberOfReviews;
        } else {
          print( 'rating average $averageRating');
          averageRating.value = 0.0;
        }
      } else {
        print( 'rating88 average $averageRating');
        averageRating.value = 0.0;
      }
    });
  }
}
