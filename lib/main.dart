import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miniproject/app/modules/login/controllers/login_controller.dart';
import 'package:miniproject/app/utils/loading.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAlFa_ZrhL8sLpg4tBSA9pa0bR7hBX6iSU",
      appId: "1:435177929611:android:8ee6be756e3aa55ad54d8e",
      messagingSenderId: "435177929611",
      projectId: "mini-project-9592f",
      storageBucket: "gs://mini-project-9592f.appspot.com",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final authC = Get.put(LoginController(), permanent: true);

  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authC.streamAuthStatus,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          print(snapshot);
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Application",
            initialRoute:
                snapshot.data != null && snapshot.data!.emailVerified == true
                    ? Routes.SPLASH_SCREEN
                    : Routes.SPLASH_SCREEN,
            getPages: AppPages.routes,
          );
        }
        return const LoadingView();
      },
    );
  }
}
