import 'dart:math';

String generateOrderId() {
  DateTime now = DateTime.now();

  int randomNumb = Random().nextInt(86868);

  return '${now.millisecondsSinceEpoch}_$randomNumb';
}
