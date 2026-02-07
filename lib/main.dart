import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:padoshi_kitchen/Modules/Auth/Controller/Authcontroller.dart';
import 'package:padoshi_kitchen/Utils/Sharedpre.dart';
import 'package:padoshi_kitchen/Utils/socket_service.dart';
import 'package:padoshi_kitchen/widgets/Splashscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// ✅ INIT STORAGE (VERY IMPORTANT)
  await GetStorage.init();
  Get.put(AuthController(), permanent: true);

  final token = TokenStorage.getAccessToken();
  if (token != null && token.isNotEmpty) {
    debugPrint("Existing token found: $token");
    SocketService.connect(token);
    SocketService.bindOrderNotifications();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SocketService.bindOrderNotifications();
    });
  }

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
