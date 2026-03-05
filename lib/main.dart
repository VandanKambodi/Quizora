import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/student_main_wrapper.dart';
import 'screens/teacher/teacher_main_wrapper.dart';
import 'constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/notification_service.dart';

Future<void> requestNotificationPermission() async {
  PermissionStatus status = await Permission.notification.request();
  if (status.isGranted) {
    print("Notification permission granted");
  } else {
    print("Notification permission denied");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();
  await requestNotificationPermission();

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
        '/teacher_dashboard': (context) => const TeacherMainWrapper(),
        '/student_dashboard': (context) => const StudentMainWrapper(),
      },
    );
  }
}
