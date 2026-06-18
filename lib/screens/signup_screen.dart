import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../widgets/reusable_widgets.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _signup() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // Navigation is handled by auth wrapper in main.dart
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: kRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: kAccentGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 24),
              Text(
                'Create Account',
                style: GoogleFonts.inter(
                  color: kTextPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up to get started',
                style: GoogleFonts.inter(color: kTextSecondary, fontSize: 14),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                style: GoogleFonts.inter(color: kTextPrimary),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: GoogleFonts.inter(color: kTextSecondary),
                  filled: true,
                  fillColor: kCardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.email_outlined, color: kTextSecondary),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: GoogleFonts.inter(color: kTextPrimary),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: GoogleFonts.inter(color: kTextSecondary),
                  filled: true,
                  fillColor: kCardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.lock_outline, color: kTextSecondary),
                ),
              ),
              const SizedBox(height: 32),
              GradientButton(
                label: 'Sign Up',
                isLoading: _isLoading,
                onPressed: _signup,
                width: double.infinity,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: Text(
                  'Already have an account? Log in',
                  style: GoogleFonts.inter(color: kAccentLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
