import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // 👈 Import from the screens folder

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Dare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        fontFamily: 'Arial', // optional: set a default font if needed
      ),
      home: const HomeScreen(), // 👈 Load your HomeScreen
    );
  }
}
