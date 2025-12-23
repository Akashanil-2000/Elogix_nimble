// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'routes.dart';

void main() {
  runApp(const NimbleApp());
}

class NimbleApp extends StatelessWidget {
  const NimbleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Nimble App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      getPages: AppRoutes.routes,
    );
  }
}
