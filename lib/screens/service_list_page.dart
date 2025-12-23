import 'package:elogix_nimble/controller/service_list_controller.dart';
import 'package:elogix_nimble/screens/service_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/common_bottom_nav.dart';

class ServiceListPage extends StatelessWidget {
  final String serviceType; // collection | delivery

  const ServiceListPage({super.key, required this.serviceType});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ServiceListController(serviceType),
      tag: serviceType,
    );

    final searchCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          serviceType == 'collection' ? 'Collections' : 'Deliveries',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            /// 🔍 SEARCH BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: searchCtrl,
                onChanged: controller.search,
                decoration: InputDecoration(
                  hintText: 'Search by service or user',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchCtrl.clear();
                              controller.search('');
                            },
                          )
                          : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            /// 🔹 LIST
            Expanded(
              child:
                  controller.services.isEmpty
                      ? const Center(child: Text('No data found'))
                      : RefreshIndicator(
                        onRefresh: () async {
                          // ✅ CLEAR SEARCH ON REFRESH
                          searchCtrl.clear();
                          controller.search('');
                          await controller.loadServices();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: controller.services.length,
                          itemBuilder: (_, i) {
                            final item = controller.services[i];

                            return GestureDetector(
                              onTap: () {
                                Get.to(
                                  () =>
                                      ServiceDetailPage(serviceId: item['id']),
                                );
                              },
                              child: _serviceCard(item),
                            );
                          },
                        ),
                      ),
            ),
          ],
        );
      }),

      bottomNavigationBar: CommonBottomNav(
        currentIndex: serviceType == 'collection' ? 1 : 2,
      ),
    );
  }

  /// 🔹 SERVICE CARD UI
  Widget _serviceCard(Map<String, dynamic> item) {
    final stateColor = _stateColor(item['state']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// NAME + STATE
          Row(
            children: [
              Expanded(
                child: Text(
                  item['name'] ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: stateColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item['state'].toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: stateColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// DATE
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(_formatDate(item)),
            ],
          ),

          const SizedBox(height: 6),

          /// USER
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(item['user_id'] != false ? item['user_id'][1] : '-'),
            ],
          ),
        ],
      ),
    );
  }

  Color _stateColor(String state) {
    switch (state) {
      case 'schedule':
        return Colors.green;
      case 'draft':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  String _formatDate(Map<String, dynamic> item) {
    final raw = item['scheduled_date'] ?? item['date'];
    if (raw == false || raw == null) return '-';

    try {
      final d = DateTime.parse(raw);
      return '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.year}';
    } catch (_) {
      return '-';
    }
  }
}
