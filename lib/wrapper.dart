import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mango_app/home_page.dart';
import 'package:mango_app/login_page.dart';
import 'package:mango_app/verify_page.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (context, snapshot) {
        if(snapshot.hasData)
        {
          if(snapshot.data!.emailVerified)
          {
          return const HomePage();
          }
          else
          {
            return const VerifyPage();
          }
        }
        else
        {
          return const LoginPage();
        }
      }),
    );
  }
}