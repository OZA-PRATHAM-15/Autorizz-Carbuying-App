import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

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
      backgroundColor: const Color(0xFF000000),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
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
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_titles.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                width: _currentPage == index ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      _currentPage == index ? Colors.white : Colors.grey[600],
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
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
        const SizedBox(height: 20),
        Lottie.asset(
          lottieAnimation,
          width: 300,
          height: 300,
        ),
        const SizedBox(height: 40),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
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
        const SizedBox(height: 60),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isLastPage ? _buildStartButton() : _buildNextPageButton(),
        ),
      ],
    );
  }

  Widget _buildNextPageButton() {
    return ElevatedButton(
      onPressed: () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        'Next',
        style: TextStyle(fontSize: 18, color: Colors.black),
      ),
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton(
      onPressed: _completeOnboarding,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        'Get Started',
        style: TextStyle(fontSize: 18, color: Colors.black),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    Navigator.pushReplacementNamed(context, '/login');
  }
}
