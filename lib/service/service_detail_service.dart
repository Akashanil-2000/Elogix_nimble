import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/storage/session_storage.dart';

class ServiceDetailService {
  Future<Map<String, dynamic>> fetchServiceDetail(int id) async {
    final token = await SessionStorage.getToken();

    final request = http.Request(
      'GET',
      Uri.parse('https://nimble.elogix-ti.me/api/v1/service'),
    );

    request.headers.addAll({
      'Content-Type': 'application/json',
      'X-Nimble-Authorization': token ?? '',
    });

    request.body = jsonEncode({"id": id});

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final decoded = jsonDecode(body);

    if (decoded['status'] != 'success') {
      throw decoded['message'] ?? 'Failed to load service details';
    }

    // API returns list → take first item
    return decoded['data'][0] as Map<String, dynamic>;
  }
}
