import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:padoshi_kitchen/Modules/Auth/Controller/Authcontroller.dart';
import 'package:padoshi_kitchen/widgets/Splashscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// ✅ INIT STORAGE (VERY IMPORTANT)
  await GetStorage.init();
    Get.put(AuthController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Padoshi Kitchen',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),

      /// ✅ APP ENTRY POINT
      home: const SplashScreen(),
    );
  }
}
