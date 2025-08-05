import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:mango_app/forget_page.dart';
import 'package:mango_app/signup_page.dart';

class LoginPage  extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
signIn() async {
  setState(() {
    isLoading = true;
  });
  try{
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }on FirebaseAuthException catch (e) {
    Get.snackbar('error message', e.code,
    );
  }

  catch (e) {
    Get.snackbar('error message', e.toString(),
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.red,
      colorText: Colors.white,
      borderRadius: 10,
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.BOTTOM,
    );
    
  }
  setState(() {
    isLoading = false;
  });
}
  @override
  Widget build(BuildContext context) {
    return isLoading?Center(child: CircularProgressIndicator(),): Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(onPressed:(()=>
              signIn()), child: const Text('Login')),
              SizedBox(height: 20), // Add some space between buttons
              ElevatedButton(onPressed:(()=>
              Get.to(SignUpPage())), child: const Text('Sign Up')),
              SizedBox(height: 20),
              SizedBox(height: 20),
              ElevatedButton(onPressed:(()=>
              Get.to(ForgetPage())), child: const Text('Forget Password?')),
            
          ],
        ),
      ),
    );
  }
}