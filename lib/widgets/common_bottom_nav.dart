import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonBottomNav extends StatelessWidget {
  final int currentIndex;

  const CommonBottomNav({super.key, required this.currentIndex});

  void _onTap(int index) {
    if (index == currentIndex) return; // ⛔ prevent reload

    switch (index) {
      case 0:
        Get.offAllNamed('/dashboard');
        break;
      case 1:
        Get.offAllNamed('/collections');
        break;
      case 2:
        Get.offAllNamed('/deliveries');
        break;
      case 3:
        Get.offAllNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: _onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFFFFAE00),
            unselectedItemColor: Colors.grey,
            selectedFontSize: 12,
            unselectedFontSize: 11,
            showUnselectedLabels: true,
            elevation: 0,
            items: [
              _navItem(
                icon: Icons.dashboard,
                label: 'Home',
                active: currentIndex == 0,
              ),
              _navItem(
                icon: Icons.inventory_2,
                label: 'Collections',
                active: currentIndex == 1,
              ),
              _navItem(
                icon: Icons.local_shipping,
                label: 'Deliveries',
                active: currentIndex == 2,
              ),
              _navItem(
                icon: Icons.person,
                label: 'Profile',
                active: currentIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Custom nav item with active indicator
  BottomNavigationBarItem _navItem({
    required IconData icon,
    required String label,
    required bool active,
  }) {
    final color = active ? const Color(0xFFFFAE00) : Colors.grey;

    return BottomNavigationBarItem(
      label: label,
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}
