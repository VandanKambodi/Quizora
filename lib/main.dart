import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/teacher/dashboard.dart';
import 'screens/student_dashboard.dart';
import 'screens/student_main_wrapper.dart';
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const QuizoraApp());
}

class QuizoraApp extends StatelessWidget {
  const QuizoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quizora',
      theme: ThemeData(
        scaffoldBackgroundColor: qBg,
        primaryColor: qPrimary,
        appBarTheme: const AppBarTheme(
          backgroundColor: qPrimary,
          foregroundColor: qWhite,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/teacher_dashboard': (context) => const TeacherDashboard(),
        // '/student_dashboard': (context) => const StudentDashboard(),
        '/student_dashboard': (context) => const StudentMainWrapper(),
      },
    );
  }
}

class DashboardPlaceholder extends StatelessWidget {
  final String title;
  const DashboardPlaceholder({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("Welcome to $title", style: qSubTitleStyle)),
    );
  }
}
