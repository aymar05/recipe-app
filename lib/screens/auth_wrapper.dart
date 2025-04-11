import 'package:recipe_app/screens/account/root_screen.dart';
import 'package:recipe_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = snapshot.data;
        if (user != null) {
          return const RootScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
