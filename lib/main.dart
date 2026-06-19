import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'providers/blog_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BlogAgentApp());
}

class BlogAgentApp extends StatelessWidget {
  const BlogAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BlogProvider()),
      ],
      child: MaterialApp(
        title: 'AI Blog Writer Agent',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: StreamBuilder<User?>(
          stream: AuthService().authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFFFFFFFF),
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF111827)),
                ),
              );
            }
            if (snapshot.hasData) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF111827),
        secondary: Color(0xFF374151),
        surface: Color(0xFFFAFAFA),
        error: Color(0xFFEF4444),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF111827)),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFF111827),
        unselectedLabelColor: Color(0xFF6B7280),
        indicatorColor: Color(0xFF111827),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF111827),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF111827),
        contentTextStyle:
            GoogleFonts.inter(color: Colors.white, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
