import 'package:elogix_nimble/service/service_list_service.dart';
import 'package:get/get.dart';

class ServiceListController extends GetxController {
  final String serviceType;

  ServiceListController(this.serviceType);

  final isLoading = true.obs;

  // 🔹 FULL LIST (after type filter)
  final allServices = <Map<String, dynamic>>[].obs;

  // 🔹 DISPLAY LIST
  final services = <Map<String, dynamic>>[].obs;

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

      final all = await _service.fetchServices();

      print('TOTAL FROM API: ${all.length}');
      print('SERVICE TYPE PAGE: $serviceType');

      // 🔹 FILTER BY TYPE
      final filtered =
          all
              .where((e) {
                if (e == null) return false;

                final type = (e['service_type'] ?? '').toString().toLowerCase();

                print('ITEM TYPE: $type');

                return type == serviceType.toLowerCase();
              })
              .cast<Map<String, dynamic>>()
              .toList();

      print('AFTER FILTER: ${filtered.length}');

      // 🔹 SAVE FULL LIST
      allServices.assignAll(filtered);

      // 🔹 INITIAL DISPLAY
      services.assignAll(filtered);
    } catch (e) {
      print('LOAD ERROR: $e');
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔍 SEARCH LOGIC
  void search(String query) {
    searchQuery.value = query;

    print('SEARCH QUERY: $query');

    if (query.isEmpty) {
      print('RESET LIST');
      services.assignAll(allServices);
      return;
    }

    final q = query.toLowerCase();

    final result =
        allServices.where((item) {
          final name = (item['name'] ?? '').toString().toLowerCase();

          final user =
              item['user_id'] != false && item['user_id'] != null
                  ? item['user_id'][1].toString().toLowerCase()
                  : '';

          return name.contains(q) || user.contains(q);
        }).toList();

    print('SEARCH RESULT COUNT: ${result.length}');

    services.assignAll(result);
  }
}
