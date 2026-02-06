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
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            /// 🔹 LIST
            Expanded(
              child:
                  controller.services.isEmpty
                      ? _emptyState()
                      : RefreshIndicator(
                        onRefresh: () async {
                          searchCtrl.clear();
                          controller.search('');
                          await controller.loadServices();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
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

  /// 🔹 EMPTY STATE
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('No services found', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// 🔹 SERVICE CARD UI
  Widget _serviceCard(Map<String, dynamic> item) {
    final stateColor = _stateColor(item['state']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                    fontSize: 15,
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
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: stateColor.withOpacity(0.3)),
                ),
                child: Text(
                  item['state'].toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: stateColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Divider(height: 12, thickness: 0.5),

          /// DATE
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                _formatDate(item),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// USER
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                item['user_id'] != false ? item['user_id'][1] : '-',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _stateColor(String state) {
    switch (state.toLowerCase()) {
      case 'schedule':
        return Colors.green;
      case 'picked_up':
      case 'in_transit':
      case 'out_for_delivery':
        return Colors.orange;
      case 'delivered':
      case 'collected':
        return Colors.blue;
      case 'failed':
        return Colors.red;
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
