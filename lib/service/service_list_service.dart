import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/storage/session_storage.dart';

class ServiceListService {
  Future<List<dynamic>> fetchServices() async {
    final token = await SessionStorage.getToken();

    final request = http.Request(
      'POST',
      Uri.parse('https://nimble.elogix-ti.me/api/v1/service/list'),
    );

    request.headers.addAll({
      'Content-Type': 'application/json',
      'X-Nimble-Authorization': token ?? '',
    });

    request.body = jsonEncode({"filter": "active"});

    final response = await request.send();
    final body = await response.stream.bytesToString();
    print('RAW RESPONSE: $body'); // 👈 ADD THIS
    final decoded = jsonDecode(body);

    if (decoded['status'] != 'success') {
      throw decoded['message'] ?? 'Failed to load services';
    }

    return decoded['data'] as List<dynamic>;
  }
}
