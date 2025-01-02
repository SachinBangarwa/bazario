import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class GetUserDataController extends GetxController {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot<Object?>>> getUserData(String uId) async {
    QuerySnapshot querySnapshot = await fireStore
        .collection('users')
       .where('uId', isEqualTo: uId)
        .get();
    return querySnapshot.docs;
  }
}
