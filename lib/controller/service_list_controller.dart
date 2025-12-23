import 'package:elogix_nimble/service/service_list_service.dart';
import 'package:get/get.dart';

class ServiceListController extends GetxController {
  final String serviceType;

  ServiceListController(this.serviceType);

  final isLoading = true.obs;

  final allServices = <dynamic>[].obs; // 🔹 full list
  final services = <dynamic>[].obs; // 🔹 filtered list

  final searchQuery = ''.obs;

  final _service = ServiceListService();

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  Future<void> loadServices() async {
    try {
      isLoading.value = true;

      final result = await _service.fetchServices();

      final filtered =
          result.where((e) => e['service_type'] == serviceType).toList();

      allServices.assignAll(filtered);
      services.assignAll(filtered);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔍 SEARCH LOGIC
  void search(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      services.assignAll(allServices);
      return;
    }

    final q = query.toLowerCase();

    services.assignAll(
      allServices.where((item) {
        final name = item['name']?.toString().toLowerCase() ?? '';
        final user =
            item['user_id'] != false
                ? item['user_id'][1].toString().toLowerCase()
                : '';

        return name.contains(q) || user.contains(q);
      }).toList(),
    );
  }
}
