import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CoffeeSpotsApp());
}

class CoffeeSpotsApp extends StatelessWidget {
  const CoffeeSpotsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Spots',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFBF6F0), // warm cream background
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A2C2A),
        ).copyWith(
          primary: const Color(0xFF4A2C2A),     // deep espresso brown
          secondary: const Color(0xFFC8936C),   // warm caramel
          surface: const Color(0xFFFBF6F0),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A2C2A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFC8936C),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
