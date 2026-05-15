import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/login_screen.dart';
import 'screens/catalog/home_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookStore',
      debugShowCheckedModeBanner: false, // removes the red DEBUG banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), // your indigo/purple brand color
        ),
        textTheme: GoogleFonts.poppinsTextTheme(), // clean modern font
        useMaterial3: true,
      ),
      home: const SplashScreen(), // app opens on the login screen
    );
  }
}