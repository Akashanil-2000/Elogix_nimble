import 'package:elogix_nimble/controller/profile_controller.dart';
import 'package:elogix_nimble/core/storage/session_storage.dart';
import 'package:elogix_nimble/widgets/common_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CommonBottomNav(currentIndex: 3),

      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _profileHeader(),

            const SizedBox(height: 24),

            _infoCard(
              icon: Icons.person,
              label: 'Name',
              value: controller.name.value,
            ),

            _infoCard(
              icon: Icons.email,
              label: 'Email',
              value: controller.email.value,
            ),

            _infoCard(
              icon: Icons.business,
              label: 'Company',
              value: controller.company.value,
            ),

            _infoCard(
              icon: Icons.public,
              label: 'Timezone',
              value: controller.timezone.value,
            ),

            const SizedBox(height: 32),

            _logoutButton(),
          ],
        );
      }),
    );
  }

  // ───────────── PROFILE HEADER ─────────────

  Widget _profileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 45,
          backgroundColor: Colors.orange,
          child: Icon(Icons.person, size: 48, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          controller.name.value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          controller.email.value,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // ───────────── INFO CARD ─────────────

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── LOGOUT BUTTON ─────────────

  Widget _logoutButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: () async {
        await SessionStorage.clear();
        Get.offAllNamed('/');
      },
      child: const Text(
        'LOGOUT',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
