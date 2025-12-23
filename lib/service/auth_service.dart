// services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const _url = 'https://nimble.elogix-ti.me/api/v1/session/authenticate';

  Future<Map<String, dynamic>> login({
    required String database,
    required String username,
    required String password,
  }) async {
    try {
      final resp = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "database": database,
          "username": username,
          "password": password,
        }),
      );

      final decoded = jsonDecode(resp.body);

      if (resp.statusCode != 200 || decoded['status'] != 'success') {
        // 👇 clean backend message
        throw decoded['message'] ?? 'Invalid email or password';
      }

      return decoded['data'];
    } catch (e) {
      // 👇 network / parsing error
      throw 'Unable to connect. Please check your internet.';
    }
  }
}
