import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/login_screen.dart';
import 'screens/catalog/home_screen.dart';
import '../../models/book_model.dart';
import '../../services/api_service.dart';
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(), // clean modern fontr
        useMaterial3: true,
      ),
      home: const SplashScreen(), // app opens on the login screen
    );
  }
}