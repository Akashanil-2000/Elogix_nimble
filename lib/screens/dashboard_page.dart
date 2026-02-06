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
              Get.dialog(
                AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  titlePadding: const EdgeInsets.only(top: 24),
                  title: Column(
                    children: const [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFFFFEAEA),
                        child: Icon(Icons.logout, color: Colors.red, size: 28),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  content: const Text(
                    'Are you sure you want to logout from the app?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  actions: [
                    Row(
                      children: [
                        /// CANCEL
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Get.back(),
                            child: const Text('Cancel'),
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// LOGOUT
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Get.back();
                              controller.logout();
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
              if (controller.footer.value != null)
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
