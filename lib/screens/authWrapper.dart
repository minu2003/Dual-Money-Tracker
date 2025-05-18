import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Authentication/sign_in.dart';
import 'home_wrapper.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // User is signed in
          return const HomeWrapper();
        } else {
          // Not signed in
          return const login();
        }
      },
    );
  }
}
