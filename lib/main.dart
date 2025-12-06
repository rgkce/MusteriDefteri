import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musteridefterim/constants/app_theme.dart';
import 'package:musteridefterim/firebase_options.dart';
import 'package:musteridefterim/pages/helpers/forgot_password_page.dart';
import 'package:musteridefterim/pages/auth/login_page.dart';
import 'package:musteridefterim/pages/auth/signup_page.dart';
import 'package:musteridefterim/pages/home/appointment_schedule_page.dart';
import 'package:musteridefterim/pages/helpers/change_password_page.dart';
import 'package:musteridefterim/pages/home/customer_detail_page.dart';
import 'package:musteridefterim/pages/home/home_page.dart';
import 'package:musteridefterim/pages/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MüşteriDefteri',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // ✅ Splash ilk açılan ekran olacak
      home: const SplashWrapper(),

      routes: {
        "/login": (context) => const LoginPage(),
        "/signup": (context) => const SignUpPage(),
        "/forgot": (context) => const ForgotPasswordPage(),
        "/home": (context) => const HomePage(),
        "/change-password": (context) => const ChangePasswordPage(),
        "/customer-detail":
            (context) => CustomerDetailPage(
              customer:
                  ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>,
            ),
        "/appointment": (context) => const AppointmentSchedulePage(),
      },
    );
  }
}

/// ✅ Splash ekranını gösterip sonra Auth kontrolüne geçen yapı
class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  void initState() {
    super.initState();

    // Splash 2 saniye görünsün
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

/// ✅ Kullanıcı giriş yapmış mı kontrol eden widget
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}
