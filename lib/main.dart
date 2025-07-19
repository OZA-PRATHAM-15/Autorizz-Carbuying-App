import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'edit_profile_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'search_content_page.dart';
import 'admin_dashboard.dart';
import 'cart_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Buying App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthChecker(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/edit-profile': (context) => const EditProfilePage(),
        '/search_content_page': (context) => const SearchContentPage(),
        '/admin-dashboard': (context) => const AdminDashboard(),
        '/cart_page': (context) => const CartPage(),
      },
    );
  }
}

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  _AuthCheckerState createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstTime = prefs.getBool('isFirstTime');

    if (isFirstTime == null || isFirstTime == true) {
      setState(() {
        _isFirstTime = true;
      });
    } else {
      setState(() {
        _isFirstTime = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstTime) {
      return const OnboardingScreen();
    }

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginPage();
    } else {
      return FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Lottie.asset(
                  'assets/caranimation.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.fill,
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return const LoginPage();
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData == null) {
            return const LoginPage();
          }

          String role = userData['role'] ?? 'user';

          if (role == 'admin') {
            return const AdminDashboard();
          } else {
            return const HomePage();
          }
        },
      );
    }
  }
}
