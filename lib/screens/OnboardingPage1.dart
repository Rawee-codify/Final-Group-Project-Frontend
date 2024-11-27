import 'package:flutter/material.dart';

class OnboardingPage1 extends StatelessWidget {
  final VoidCallback onPressed;

  OnboardingPage1({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a gradient background for a modern touch
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40), // Adds space at the top
                // Improved Image Widget with responsive height
                Image.asset(
                  'assets/assets/onboarding1.png',
                  height: MediaQuery.of(context).size.height * 0.6,
                ),
                const SizedBox(
                    height: 80), // Reduced space between image and button
                // Improved button with rounded corners and shadow
                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 15), // Improved padding
                    backgroundColor: Color.fromRGBO(10, 49, 12, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Rounded corners
                    ),
                    elevation: 5, // Add shadow for modern effect
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                    height: 90), // Space between button and footer text
                // Footer text with subtle font styling
                const Text(
                  "Powered By JACP Solutions Lanka (pvt) LTD",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xEE898686),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
