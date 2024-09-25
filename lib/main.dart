import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Solicitar permissões
  await requestPermissions();

  runApp(const MyApp());
}

Future<void> requestPermissions() async {
  final cameraStatus = await Permission.camera.request();
  final storageStatus = await Permission.storage.request();

  if (cameraStatus.isGranted && storageStatus.isGranted) {
    // Permissões concedidas
  } else {
    // Permissões negadas, lidar com o caso
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vap Passageiro',
      initialRoute: AppPages.initialRoute,
      getPages: AppPages.routes,
    );
  }
}
