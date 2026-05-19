import '../../services/auth_service.dart';
import '../auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../catalog/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // these controllers read what the user types
  final _storage = const FlutterSecureStorage();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4F46E5),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP SECTION (logo + welcome text) ──
            const SizedBox(height: 50),
            const Text('📚', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            Text(
              'BookStore',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Your world of books',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),

            // ── WHITE CARD (the form) ──
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back 👋',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Login to your account',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // EMAIL FIELD
                      Text('Email',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500, fontSize: 14)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: Color(0xFF4F46E5)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF4F46E5), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // PASSWORD FIELD
                      Text('Password',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500, fontSize: 14)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outlined,
                              color: Color(0xFF4F46E5)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            // toggles show/hide password
                            onPressed: () => setState(
                                    () => obscurePassword = !obscurePassword),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF4F46E5), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // FORGOT PASSWORD
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text('Forgot password?',
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF4F46E5))),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          // Update the onPressed method in login_screen.dart:
                          onPressed: isLoading
                              ? null
                              : () async {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();

                            if (email.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please fill in all fields')),
                              );
                              return;
                            }

                            setState(() => isLoading = true);

                            // Connect directly to localhost:8080/api/auth/login
                            final result = await AuthService.login(email, password);

                            setState(() => isLoading = false);

                            if (result['success']) {
                              // Save the returned JWT token securely on Windows
                              await _storage.write(key: 'jwt_token', value: result['token']);

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Login Successful 🎉'),
                                      backgroundColor: Colors.green
                                  ),
                                );

                                // Route to the Book Catalog main screen
                                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message'] ?? 'Invalid email or password'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                              color: Colors.white)
                              : Text('Login',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // REGISTER LINK
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ",
                                style: GoogleFonts.poppins(
                                    color: Colors.grey, fontSize: 14)),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                );
                              },
                              child: Text('Sign Up',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF4F46E5),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}