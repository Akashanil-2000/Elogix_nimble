// lib/screens/dashboard_page.dart
import 'package:elogix_nimble/controller/dashboard_controller.dart';
import 'package:elogix_nimble/widgets/FooterSection.dart';
import 'package:elogix_nimble/widgets/KpiSection.dart';
import 'package:elogix_nimble/widgets/MetricsSection.dart';
import 'package:elogix_nimble/widgets/common_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // 🌤 soft background
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.defaultDialog(
                title: 'Logout',
                middleText: 'Are you sure you want to logout?',
                textCancel: 'Cancel',
                textConfirm: 'Logout',
                confirmTextColor: Colors.white,
                onConfirm: () {
                  Get.back();
                  controller.logout();
                },
              );
            },
          ),
        ],
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadDashboard,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const SizedBox(height: 16),

              /// 🔹 KPI SECTION
              _sectionWrapper(child: KpiSection(kpis: controller.kpiList)),

              /// 🔹 METRICS SECTION
              _sectionWrapper(
                child: MetricsSection(metrics: controller.metricsList),
              ),

              /// 🔹 FOOTER SECTION
              _sectionWrapper(
                child: FooterSection(footer: controller.footer.value!),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: const CommonBottomNav(currentIndex: 0),
    );
  }

  /// 🔹 COMMON SECTION WRAPPER (EQUAL SPACING & FEEL)
  Widget _sectionWrapper({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: child,
    );
  }
}
