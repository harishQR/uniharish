import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:unifiedwebservices/screens/home.dart';
import 'bindings/intilalbindings.dart';
// git last update 17/11/25 - 2:30 AM
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: Intialbindings(),
      debugShowCheckedModeBanner: false,
      home:  Home(),
    );
  }
}


