// lib/controllers/dashboard_controller.dart
import 'package:elogix_nimble/service/dashboard_service.dart';
import 'package:get/get.dart';

import '../core/storage/session_storage.dart';

class DashboardController extends GetxController {
  final isLoading = true.obs;

  // 🔹 KPI
  final kpiList = <dynamic>[].obs;

  // 🔹 Metrics
  final metricsList = <dynamic>[].obs;

  // 🔹 Footer
  final footer = Rxn<Map<String, dynamic>>();

  final _service = DashboardService();

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;

      final data = await _service.fetchDashboard();

      // 🔹 SAFE ACCESS
      kpiList.assignAll((data['kpi']?['kpi_list'] as List?) ?? []);

      metricsList.assignAll((data['metrics']?['metrics_list'] as List?) ?? []);

      footer.value = data['footer']; // already fine
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await SessionStorage.clear();
    Get.offAllNamed('/');
  }
}
