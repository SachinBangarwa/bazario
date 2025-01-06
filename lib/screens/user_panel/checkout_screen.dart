import 'package:bazario/controllers/cart_price_controller.dart';
import 'package:bazario/controllers/get_customer_device_token.dart';
import 'package:bazario/models/cart_model.dart';
import 'package:bazario/services/place_order_service.dart';
import 'package:bazario/utils/app_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  final CartPriceController cartPriceController =
      Get.put(CartPriceController());
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  String? name;
  String? phone;
  String? address;
  String? customerToken;

  final Razorpay _razorpay = Razorpay();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _razorpay.clear();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppConstant.appTextColor),
        centerTitle: true,
        backgroundColor: AppConstant.appSceColor,
        title: const Text(
          AppConstant.checkOutText,
          style: TextStyle(color: AppConstant.appTextColor),
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('cart')
              .doc(user!.uid)
              .collection('cartOrders')
              .snapshots(),
          builder: (context, snapShot) {
            if (snapShot.hasError) {
              return const Center(
                child: Text('Error'),
              );
            } else if (snapShot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            } else if (snapShot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No product found!'),
              );
            } else if (snapShot.data != null) {
              return SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapShot.data!.docs.length,
                        itemBuilder: (context, index) {
                          QueryDocumentSnapshot data =
                              snapShot.data!.docs[index];
                          CartModel cartModel = CartModel(
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
                              updatedAt: data['updatedAt'],
                              productQuantity: data['productQuantity'],
                              productSubTotal: data['productSubTotal']);
                          cartPriceController.fetchProductPrice();
                          return SwipeActionCell(
                              key: ObjectKey(cartModel.productId),
                              trailingActions: [
                                SwipeAction(
                                    onTap: (handler) async {
                                      await FirebaseFirestore.instance
                                          .collection('cart')
                                          .doc(user!.uid)
                                          .collection('cartOrders')
                                          .doc(cartModel.productId)
                                          .delete();
                                    },
                                    title: 'Delete',
                                    closeOnTap: true,
                                    performsFirstActionWithFullSwipe: true,
                                    forceAlignmentToBoundary: true),
                                SwipeAction(
                                    onTap: (handler) {
                                      EasyLoading.show(
                                          status: 'Uni tree B2-W',
                                          dismissOnTap: true);
                                    },
                                    color: Colors.green,
                                    title: 'Tester',
                                    closeOnTap: true,
                                    performsFirstActionWithFullSwipe: true,
                                    forceAlignmentToBoundary: true),
                              ],
                              child: Card(
                                elevation: 5,
                                color: AppConstant.appTextColor,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppConstant.appTextColor,
                                    backgroundImage: NetworkImage(
                                      cartModel.productImages[index],
                                    ),
                                  ),
                                  title: Text(cartModel.productName),
                                  subtitle: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(cartModel.fullPrice.toString()),
                                    ],
                                  ),
                                ),
                              ));
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
          }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 2),
        child: Container(
          color: Colors.redAccent.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                    " Total  ${cartPriceController.totalPrice.toStringAsFixed(1)} : PKR",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              buildCheckOutCartHandel('Conform Order', () {
                _showCustomBottomSheet();
              })
            ],
          ),
        ),
      ),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    placeOrder(
        context: context,
        customerAddress: address!,
        customerName: name!,
        customerPhone: phone!,
        customerToken: customerToken!);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.code} | ${response.message}');
    Get.snackbar('Payment Failed', response.message ?? 'An error occurred',
        backgroundColor: AppConstant.appMainColor,colorText: Colors.white);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
  }

  void _showCustomBottomSheet() {
    Get.bottomSheet(
        elevation: 6,
        isDismissible: true,
        enableDrag: true,
        Container(
          height: Get.height / 2.5,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  _textFormFieldAddress(
                      'Name', TextInputType.name, nameController),
                  _textFormFieldAddress(
                      'Phone', TextInputType.number, phoneController),
                  _textFormFieldAddress(
                      'Address', TextInputType.text, addressController),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstant.appSceColor),
                      onPressed: () async {
                        name = nameController.text.trim();
                        phone = phoneController.text.trim();
                        address = addressController.text.trim();
                        if (name!.isNotEmpty &&
                            phone!.isNotEmpty &&
                            address!.isNotEmpty) {
                          customerToken = await getCustomerDeviceToken();
                          if (mounted) {
                            var options = {
                              'key': 'rzp_test_YghC01so2pwPnx',
                              'amount': 100,
                              'currency': 'INR',
                              'name': 'Acme Corp.',
                              'description': 'Fine T-Shirt',
                              'prefill': {
                                'contact': '8888888888',
                                'email': 'test@razorpay.com'
                              }
                            };
                            _razorpay.open(options);
                          }
                        } else {
                          Get.snackbar('Error', 'Required Field All',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppConstant.appSceColor);
                        }
                      },
                      child: const Text(
                        'Place Order',
                        style: TextStyle(color: AppConstant.appTextColor),
                      ))
                ],
              ),
            ),
          ),
        ));
  }

  Widget _textFormFieldAddress(String label, type, controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: SizedBox(
        height: 55,
        child: TextFormField(
          controller: controller,
          keyboardType: type,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
              labelText: label,
              hintStyle: const TextStyle(fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: const OutlineInputBorder()),
        ),
      ),
    );
  }

  Widget buildCheckOutCartHandel(
    String name,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(11),
                    bottomLeft: Radius.circular(11))),
            backgroundColor: AppConstant.appSceColor,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
        onPressed: onPressed,
        child: Text(
          name,
          style: const TextStyle(
              color: AppConstant.appTextColor,
              fontWeight: FontWeight.w500,
              fontSize: 18),
        ));
  }
}
