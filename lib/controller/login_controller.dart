// controllers/login_controller.dart
import 'package:elogix_nimble/core/storage/session_storage.dart';
import 'package:elogix_nimble/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final _service = AuthService();

  @override
  void onInit() {
    super.onInit();
    _checkAutoLogin(); // ✅ now correctly placed
  }

  Future<void> _checkAutoLogin() async {
    final token = await SessionStorage.getToken();

    if (token != null && token.isNotEmpty) {
      Get.offAllNamed('/dashboard'); // 🚀 auto-login
    }
  }

  void togglePassword() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login(String user, String pass) async {
    try {
      isLoading.value = true;

      final data = await _service.login(
        database: 'run.nimble.elogix-ti.me.001',
        username: user,
        password: pass,
      );

      await SessionStorage.saveToken(data['token']);
      await SessionStorage.saveUserId(data['user_id']);
      await SessionStorage.saveProfile(
        name: data['name'],
        email: data['email'],
        company: data['company_name'],
        timezone: data['time_zone'],
      );

      Get.offAllNamed('/dashboard');
    } catch (e) {
      Get.snackbar(
        'Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
    } finally {
      // 🔥 IMPORTANT
      isLoading.value = false;
    }
  }
}
