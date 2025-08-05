import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/state_manager.dart';
import 'package:mango_app/wrapper.dart';

class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key});

  @override
  _VerifyPageState createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  @override
  void initState() {
    sendVerifyLink();
    super.initState();
    // You can add logic here to check if the user is verified
    // and navigate accordingly.
  }
  void sendVerifyLink() async {
    // Logic to send verification email
    final user = FirebaseAuth.instance.currentUser!;

    await user.sendEmailVerification().then((value) {
      // Optionally, you can show a message to the user
      
      Get.snackbar(
        'Verification Email Sent',
        'Please check your email to verify your account.',
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        borderRadius: 10,
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.BOTTOM,
      );
    }).catchError((error) {
      // Handle error if sending verification fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send verification email: $error')),
      );
    });
  }

  reload () async {
    await FirebaseAuth.instance.currentUser!.reload().then((value) => Get.offAll(Wrapper()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please verify your email address. Check your inbox for a verification link.'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          reload(); 
        },
        child: const Icon(Icons.refresh),
      )
    );
  }
}