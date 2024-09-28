import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _titles = [
    'Welcome to Autorizz',
    'Find Your Dream Car',
    'Fast and Easy Checkout',
  ];

  final List<String> _descriptions = [
    'Discover the best cars with us. Your journey to owning your dream car starts here.',
    'Browse, compare, and select from a variety of cars to find the perfect match for you.',
    'Experience a fast and seamless checkout process for your car purchases.',
  ];

  final List<String> _lottieAnimations = [
    'assets/caranimation1.json',
    'assets/caranimation2.json',
    'assets/caranimation.json',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Black background
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemCount: _titles.length,
        itemBuilder: (context, index) {
          return _buildPageContent(
            title: _titles[index],
            description: _descriptions[index],
            lottieAnimation: _lottieAnimations[index],
            isLastPage: index == _titles.length - 1,
          );
        },
      ),
    );
  }

  Widget _buildPageContent({
    required String title,
    required String description,
    required String lottieAnimation,
    required bool isLastPage,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        Lottie.asset(
          lottieAnimation,
          width: 300,
          height: 300,
        ),
        SizedBox(height: 40),
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[300],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 60),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: isLastPage ? _buildStartButton() : _buildNextPageButton(),
        ),
      ],
    );
  }

  // Button to move to the next page
  Widget _buildNextPageButton() {
    return ElevatedButton(
      onPressed: () {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(
            255, 255, 255, 255), // Green color for next button
        padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        'Next',
        style: TextStyle(fontSize: 18, color: Colors.black),
      ),
    );
  }

  // Button to finish the onboarding process
  Widget _buildStartButton() {
    return ElevatedButton(
      onPressed: _completeOnboarding,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(
            255, 255, 255, 255), // Golden color for start button
        padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        'Get Started',
        style: TextStyle(fontSize: 18, color: Colors.black),
      ),
    );
  }

  // Complete the onboarding process and navigate to the login screen
  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    Navigator.pushReplacementNamed(context, '/login');
  }
}
