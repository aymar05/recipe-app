import 'package:recipe_app/config/theme.dart';
import 'package:recipe_app/firebase_options.dart';
import 'package:recipe_app/screens/account/root_screen.dart';
import 'package:recipe_app/screens/auth_wrapper.dart';
import 'package:recipe_app/screens/login_screen.dart';
import 'package:recipe_app/screens/profile_page.dart';
import 'package:recipe_app/screens/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(
          name: "/root",
          page: () => const RootScreen(),
        ),
        GetPage(
          name: "/login",
          page: () => const ProfilePage(),
        ),
        GetPage(
          name: "/register",
          page: () => const RegisterScreen(),
        ),
      ],
      theme: themeData,
      home: const AuthWrapper(),
    );
  }
}
