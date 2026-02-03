import 'package:elogix_nimble/controller/service_detail_controller.dart';
import 'package:elogix_nimble/screens/delivery_confirmation_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceDetailPage extends StatelessWidget {
  final int serviceId;

  const ServiceDetailPage({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ServiceDetailController(serviceId),
      tag: serviceId.toString(),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Service Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.detail.value;
        if (data == null) {
          return const Center(child: Text('No details found'));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _headerCard(data),

            const SizedBox(height: 16),

            _section(
              title: 'Schedule',
              children: [
                _infoRow('Date', _formatDate(data['date'])),
                _infoRow('Scheduled Date', _formatDate(data['scheduled_date'])),
              ],
            ),

            const SizedBox(height: 16),

            _section(
              title: 'From',
              children: [
                _infoRow('Contact', data['from_contact_name']),
                _infoRow('Company', data['from_company_name']),
                _infoRow('Address', data['from_address']),
                _infoRow('City', data['from_city']),
                _infoRow(
                  'Country',
                  data['from_country_id'] != false
                      ? data['from_country_id'][1]
                      : '-',
                ),
                _infoRow('Phone', data['from_phone']),
                _infoRow('Email', data['from_email']),
              ],
            ),

            const SizedBox(height: 16),

            _section(
              title: 'To',
              children: [
                _infoRow('Contact', data['to_contact_name']),
                _infoRow('Company', data['to_company_name']),
                _infoRow('Address', data['to_address']),
                _infoRow('City', data['to_city']),
                _infoRow('Phone', data['to_phone']),
                _infoRow('Email', data['to_email']),
              ],
            ),
          ],
        );
      }),

      /// 🔹 ACTION BUTTONS
      bottomNavigationBar: _actionButtons(context),
    );
  }

  // ───────────────── HEADER CARD ─────────────────

  Widget _headerCard(Map<String, dynamic> data) {
    final stateColor = _stateColor(data['state']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  data['name'] ?? '-',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: stateColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data['state'].toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: stateColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(
                data['service_type'] == 'delivery'
                    ? Icons.local_shipping
                    : Icons.inventory_2,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                data['service_type'].toString().toUpperCase(),
                style: const TextStyle(color: Colors.grey),
              ),
              const Spacer(),
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                data['user_id'] != false ? data['user_id'][1] : '-',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────── SECTION CARD ─────────────────

  Widget _section({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // ───────────────── INFO ROW ─────────────────

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── ACTION BUTTONS ─────────────────

  Widget _actionButtons(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            /// ❌ FAILED
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _showFailureDialog(),
                child: const Text(
                  'FAILED',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// ✅ DELIVERED
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Get.snackbar(
                    'Success',
                    'Service marked as delivered successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                  );
                  Get.to(() => DeliveryConfirmationPage(serviceId: serviceId));
                },
                child: const Text(
                  'DELIVERED',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── FAILURE DIALOG ─────────────────

  void _showFailureDialog() {
    final RxString selectedReason = ''.obs;

    final List<String> failureReasons = [
      'Bad Address',
      'Wrong Address',
      'Wrong Number',
      'Need Contact Name',
      'Need Department Detail',
      'Need Contact Number',
      'Area/Location Changed',
      'Change Of Address',
      'Customer Requested for Call Back',
      'COD Amount not ready',
    ];

    Get.dialog(
      AlertDialog(
        title: const Text(
          'Mark as Failed',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Obx(
          () => DropdownButtonFormField<String>(
            isExpanded: true, // ✅ VERY IMPORTANT
            value: selectedReason.value.isEmpty ? null : selectedReason.value,
            items:
                failureReasons.map((reason) {
                  return DropdownMenuItem<String>(
                    value: reason,
                    child: Text(
                      reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              selectedReason.value = value ?? '';
            },
            decoration: const InputDecoration(
              labelText: 'Select failure reason',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ),

        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (selectedReason.value.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please select a failure reason',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              Get.back();

              // 🚀 API call will go here
              // controller.markFailed(serviceId, selectedReason.value);

              Get.snackbar(
                'Failed',
                'Service marked as failed',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
                icon: const Icon(Icons.error, color: Colors.white),
              );
            },
            child: const Text(
              'Submit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── HELPERS ─────────────────

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

  String _formatDate(dynamic raw) {
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
