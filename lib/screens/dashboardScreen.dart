// dashboard_screen.dart
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/assets/background_4.webp', // Path to your background image
            fit: BoxFit.cover,
          ),
          // Welcome Message
        ],
      ),
    );
  }
}
