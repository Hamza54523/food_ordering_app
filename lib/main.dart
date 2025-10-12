import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const FoodOrderingApp());
}

class FoodOrderingApp extends StatelessWidget {
  const FoodOrderingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodExpress',
      theme: ThemeData(
        primaryColor: const Color(0xFFFF6B35),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFFF6B35),
          secondary: const Color(0xFFFFA726),
        ),
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}