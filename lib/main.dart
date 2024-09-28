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
import 'admin-dashboard.dart';
import 'cart_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package
import 'onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Buying App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthChecker(), // Check if user is already logged in
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/edit-profile': (context) => EditProfilePage(),
        '/search_content_page': (context) => SearchContentPage(),
        '/admin-dashboard': (context) => AdminDashboard(),
        '/cart_page': (context) => CartPage(),
      },
    );
  }
}

// New Widget to Check if the User is Logged In and if it's their first time
class AuthChecker extends StatefulWidget {
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

  // Function to check if it's the user's first time
  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstTime = prefs.getBool('isFirstTime');

    if (isFirstTime == null || isFirstTime == true) {
      // First time, set to false after showing the onboarding
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
      return OnboardingScreen(); // Show the onboarding screen if it's the first time
    }

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return LoginPage(); // If no user is logged in, show login page
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
                  'assets/caranimation.json', // Path to your Lottie animation file
                  width: 200,
                  height: 200,
                  fit: BoxFit.fill,
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return LoginPage(); // In case of error, return to login
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData == null) {
            return LoginPage();
          }

          String role = userData['role'] ?? 'user';

          if (role == 'admin') {
            return AdminDashboard();
          } else {
            return HomePage();
          }
        },
      );
    }
  }
}
