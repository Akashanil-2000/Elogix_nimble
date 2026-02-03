import 'package:elogix_nimble/core/storage/session_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ProfileController extends GetxController {
  final isLoading = true.obs;

  final name = ''.obs;
  final email = ''.obs;
  final company = ''.obs;
  final timezone = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    name.value = await SessionStorage.getName() ?? '';
    email.value = await SessionStorage.getEmail() ?? '';
    company.value = await SessionStorage.getCompany() ?? '';
    timezone.value = await SessionStorage.getTimezone() ?? '';

    isLoading.value = false;
  }
}
