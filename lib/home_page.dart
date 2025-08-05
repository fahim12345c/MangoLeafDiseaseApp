import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mango_app/mango_screen.dart';
// import other disease screens when ready
import 'package:mango_app/tomato_screen.dart';
import 'package:mango_app/potato_screen.dart';
import 'package:mango_app/rice_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;

  Widget _buildDiseaseButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.green,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Detection'),
        backgroundColor: Colors.green.shade700,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildDiseaseButton(
            title: 'Mango Leaf Disease Detection',
            icon: Icons.local_florist,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MangoScreen(),
                ),
              );
            },
            color: Colors.orange,
          ),
          _buildDiseaseButton(
            title: 'Tomato Leaf Disease Detection',
            icon: Icons.local_pizza,
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => TomatoScreen()));
            },
            color: Colors.red,
          ),
          _buildDiseaseButton(
            title: 'Potato Leaf Disease Detection',
            icon: Icons.spa,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PotatoScreen()));
            },
            color: Colors.brown,
          ),
          _buildDiseaseButton(
            title: 'Rice Leaf Disease Detection',
            icon: Icons.grass,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => RiceScreen()));
            },
            color: Colors.teal,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          // After sign out, redirect to login or splash screen
          // ignore: use_build_context_synchronously
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        backgroundColor: Colors.redAccent,
        tooltip: 'Sign Out',
        child: const Icon(Icons.logout),
      ),
    );
  }
}
