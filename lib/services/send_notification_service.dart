import 'dart:convert';
import 'package:bazario/services/get_server_key_service.dart';
import 'package:http/http.dart' as http;

class SendNotificationService {
  Future<void> sendNotification({
    required String title,
    required String token,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    String serverKey = await GetServerKeyService().getServerKeyToken();
    String url = 'https://fcm.googleapis.com/v1/projects/easyshopping-a050e/messages:send';

    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $serverKey',
    };

    Map<String, dynamic> message = {
      "message": {
        "token": token,
        "notification": {
          "body": body,
          "title": title,
        },
        "data": data.map((key, value) => MapEntry(key, value.toString())),
      }
    };

    final response = await http.post(Uri.parse(url), headers: header, body: jsonEncode(message));

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Notification failed: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
}
