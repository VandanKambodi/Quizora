import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/teacher_dashboard.dart';
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
      theme: ThemeData(scaffoldBackgroundColor: qWhite, primaryColor: qBlue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/teacher_dashboard': (context) => const TeacherDashboard(),
        '/student_dashboard':
            (context) => const DashboardPlaceholder(title: "Student Dashboard"),
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
      appBar: AppBar(title: Text(title), backgroundColor: qBlue),
      body: Center(child: Text("Welcome to the $title")),
    );
  }
}
