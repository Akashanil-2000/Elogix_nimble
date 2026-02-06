import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/storage/session_storage.dart';

class DeliveryService {
  Future<void> confirmDelivery({
    required int serviceId,
    required Map<String, dynamic> payload,
  }) async {
    final token = await SessionStorage.getToken();

    final response = await http.post(
      Uri.parse(
        'https://nimble.elogix-ti.me/api/v1/service/$serviceId/deliver',
      ),
      headers: {
        'Content-Type': 'application/json',
        'X-Nimble-Authorization': token ?? '',
      },
      body: jsonEncode(payload),
    );
    print('STATUS CODE: ${response.statusCode}');
    print('RAW RESPONSE: ${response.body}');

    final decoded = jsonDecode(response.body);

    if (decoded['status'] != 'success') {
      throw decoded['message'] ?? 'Delivery failed';
    }
  }

  Future<void> markFailed({
    required int serviceId,
    required String reason,
  }) async {
    final token = await SessionStorage.getToken();

    final url = 'https://nimble.elogix-ti.me/api/v1/service/$serviceId/fail';

    final body = {"failed_reason": reason};

    print('FAILED API URL: $url');
    print('FAILED PAYLOAD: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Nimble-Authorization': token ?? '',
      },
      body: jsonEncode(body),
    );

    print('FAILED STATUS CODE: ${response.statusCode}');
    print('FAILED RAW RESPONSE: ${response.body}');

    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200 || decoded['status'] != 'success') {
      throw decoded['message'] ?? 'Failed to mark service';
    }

    print('FAILED API SUCCESS');
  }
}
