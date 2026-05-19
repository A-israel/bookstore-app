import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4F46E5),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP SECTION ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Create Account',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const Text('📚', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 16),

            // ── WHITE CARD ──
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
                        'Join BookStore 🎉',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        'Create your account to get started',
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),

                      // FULL NAME
                      _buildLabel('Full Name'),
                      _buildTextField(
                        controller: nameController,
                        hint: 'Enter your full name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 14),

                      // EMAIL
                      _buildLabel('Email'),
                      _buildTextField(
                        controller: emailController,
                        hint: 'Enter your email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),

                      // PASSWORD
                      _buildLabel('Password'),
                      _buildTextField(
                        controller: passwordController,
                        hint: 'Create a password',
                        icon: Icons.lock_outlined,
                        isPassword: true,
                        obscure: obscurePassword,
                        onToggle: () => setState(
                                () => obscurePassword = !obscurePassword),
                      ),
                      const SizedBox(height: 14),

                      // CONFIRM PASSWORD
                      _buildLabel('Confirm Password'),
                      _buildTextField(
                        controller: confirmPasswordController,
                        hint: 'Repeat your password',
                        icon: Icons.lock_outlined,
                        isPassword: true,
                        obscure: obscureConfirm,
                        onToggle: () =>
                            setState(() => obscureConfirm = !obscureConfirm),
                      ),
                      const SizedBox(height: 24),

                      // REGISTER BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          // Update the onPressed method in register_screen.dart:
                          onPressed: isLoading
                              ? null
                              : () async {
                            final name = nameController.text.trim();
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();
                            final confirmPassword = confirmPasswordController.text.trim();

                            if (name.isEmpty || email.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('All fields are required')),
                              );
                              return;
                            }

                            if (password != confirmPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
                              );
                              return;
                            }

                            setState(() => isLoading = true);

                            final result = await AuthService.register(
                              fullname: name,
                              email: email,
                              password: password,
                            );

                            setState(() => isLoading = false);

                            if (result['success']) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Account Created! Please Login.'), backgroundColor: Colors.green),
                              );
                              // Pop back to login screen
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message'] ?? 'Registration failed'),
                                  backgroundColor: Colors.red,
                                ),
                              );
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
                              : Text(
                            'Create Account',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // LOGIN LINK
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account? ',
                                style: GoogleFonts.poppins(
                                    color: Colors.grey, fontSize: 14)),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'Login',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF4F46E5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
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

  // ── REUSABLE LABEL WIDGET ──
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500, fontSize: 14)),
    );
  }

  // ── REUSABLE TEXT FIELD WIDGET ──
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscure : false,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF4F46E5)),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFF4F46E5), width: 2),
        ),
      ),
    );
  }
}