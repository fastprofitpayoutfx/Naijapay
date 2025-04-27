import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/custom_button.dart';
import '../config/theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 3;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Easy Money Transfers',
      'description': 'Transfer money to friends, family, and businesses across Nigeria quickly and securely.',
      'image': 'https://images.unsplash.com/photo-1534161197248-bae0085acec9',
    },
    {
      'title': 'Pay Bills Effortlessly',
      'description': 'Pay for electricity, water, TV subscriptions, and more with just a few taps.',
      'image': 'https://images.unsplash.com/photo-1533234944761-2f5337579079',
    },
    {
      'title': 'Buy Airtime & Data',
      'description': 'Top up your phone and buy data bundles for yourself and loved ones instantly.',
      'image': 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c',
    },
  ];

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _numPages; i++) {
      indicators.add(
        Container(
          width: 10.0,
          height: 10.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == i
                ? AppTheme.accentColor
                : Colors.white.withOpacity(0.4),
          ),
        ),
      );
    }
    return indicators;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _numPages,
                itemBuilder: (context, index) {
                  return _buildPage(index);
                },
              ),
            ),
            // Bottom navigation and buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildPageIndicator(),
                  ),
                  const SizedBox(height: 32.0),
                  // Buttons
                  CustomButton(
                    text: 'Create Account',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    color: Colors.white,
                    textColor: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16.0),
                  CustomButton(
                    text: 'Login',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    color: Colors.transparent,
                    textColor: Colors.white,
                    borderColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Image.network(
              _pages[index]['image']!,
              height: 240.0,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 40.0),
          // Title
          Text(
            _pages[index]['title']!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          // Description
          Text(
            _pages[index]['description']!,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18.0,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
