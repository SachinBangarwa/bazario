import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class BannersController extends GetxController {
  final fireStore = FirebaseFirestore.instance;
  RxList<String> bannerUrls = RxList<String>([]);

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchBannersUrl();
  }

  Future fetchBannersUrl() async {
    try {
      QuerySnapshot querySnap = await fireStore.collection('banners').get();
      if (querySnap.docs.isNotEmpty) {
        bannerUrls.value =
            querySnap.docs.map((doc) => doc['imageUrl'] as String).toList();
      }
    } catch(e){}
  }
}
