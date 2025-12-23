import 'package:elogix_nimble/service/service_detail_service.dart';
import 'package:get/get.dart';

class ServiceDetailController extends GetxController {
  final int serviceId;

  ServiceDetailController(this.serviceId);

  final isLoading = true.obs;
  final detail = Rxn<Map<String, dynamic>>();

  final _service = ServiceDetailService();

  @override
  void onInit() {
    super.onInit();
    loadDetail();
  }

  Future<void> loadDetail() async {
    try {
      isLoading.value = true;
      detail.value = await _service.fetchServiceDetail(serviceId);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
