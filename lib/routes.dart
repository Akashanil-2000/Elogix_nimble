// lib/routes.dart
import 'package:elogix_nimble/screens/dashboard_page.dart';
import 'package:elogix_nimble/screens/login_page.dart';
import 'package:elogix_nimble/screens/profile_page.dart';
import 'package:elogix_nimble/screens/service_list_page.dart';
import 'package:get/get.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: '/', page: () => LoginPage()),
    GetPage(name: '/dashboard', page: () => DashboardPage()),
    GetPage(
      name: '/collections',
      page: () => const ServiceListPage(serviceType: 'collection'),
    ),
    GetPage(
      name: '/deliveries',
      page: () => const ServiceListPage(serviceType: 'delivery'),
    ),
    GetPage(name: '/profile', page: () => ProfilePage()),
  ];
}
