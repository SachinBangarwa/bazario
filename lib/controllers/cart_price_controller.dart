import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CartPriceController extends GetxController {
  final fireStore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  RxDouble totalPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProductPrice();
  }

  Future fetchProductPrice() async {
    final storeData = await fireStore
        .collection('cart')
        .doc(user!.uid)
        .collection('cartOrders')
        .get();

    double sum = 0.0;
    for (final doc in storeData.docs) {
      final data = doc.data();
      if (data.containsKey('productSubTotal')) {
        sum += (data['productSubTotal'] as num).toDouble();
      }
    }
    totalPrice.value = sum;
  }
}
