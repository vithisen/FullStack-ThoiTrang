import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Illustration (Shopping Bags & Confetti)
              const ShoppingBagsIllustration(),

              const SizedBox(height: 48),

              // Success Text
              const Text(
                'Success!',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Your order will be delivered soon.\nThank you for choosing our app!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textBlack,
                  height: 1.4,
                ),
              ),

              const Spacer(flex: 2),

              // Continue Shopping Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to the home/shop screen and clear all history
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'CONTINUE SHOPPING',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class ShoppingBagsIllustration extends StatelessWidget {
  const ShoppingBagsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti elements (colorful dots and small ribbons)
          ..._buildConfetti(),

          // Yellow Bag (behind)
          Positioned(
            top: 55,
            left: 45,
            child: Transform.rotate(
              angle: -0.15,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Handle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textBlack, width: 2),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                  ),
                  // Bag Body
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    width: 68,
                    height: 78,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107), // Yellow
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Red Bag (in front)
          Positioned(
            top: 75,
            left: 90,
            child: Transform.rotate(
              angle: 0.1,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Handle
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textBlack, width: 2),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                  ),
                  // Bag Body
                  Container(
                    margin: const EdgeInsets.only(top: 18),
                    width: 82,
                    height: 98,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed, // Red
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(4, 6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConfetti() {
    final List<Map<String, dynamic>> confettiData = [
      {
        "top": 25.0,
        "left": 40.0,
        "color": AppColors.primaryRed,
        "size": 6.0,
        "isCircle": true,
        "rotation": 0.0,
      },
      {
        "top": 45.0,
        "left": 15.0,
        "color": Colors.orange,
        "size": 8.0,
        "isCircle": false,
        "rotation": 0.4,
      },
      {
        "top": 35.0,
        "left": 170.0,
        "color": Colors.blue,
        "size": 7.0,
        "isCircle": false,
        "rotation": -0.5,
      },
      {
        "top": 90.0,
        "left": 20.0,
        "color": Colors.blue,
        "size": 6.0,
        "isCircle": true,
        "rotation": 0.0,
      },
      {
        "top": 120.0,
        "left": 180.0,
        "color": Colors.amber,
        "size": 8.0,
        "isCircle": false,
        "rotation": 0.7,
      },
      {
        "top": 165.0,
        "left": 45.0,
        "color": AppColors.primaryRed,
        "size": 7.0,
        "isCircle": false,
        "rotation": -0.3,
      },
      {
        "top": 140.0,
        "left": 15.0,
        "color": Colors.green,
        "size": 5.0,
        "isCircle": true,
        "rotation": 0.0,
      },
      {
        "top": 65.0,
        "left": 140.0,
        "color": Colors.deepPurple,
        "size": 6.0,
        "isCircle": false,
        "rotation": 0.2,
      },
    ];

    return confettiData.map((data) {
      return Positioned(
        top: data['top'],
        left: data['left'],
        child: Transform.rotate(
          angle: data['rotation'],
          child: Container(
            width: data['size'],
            height: data['isCircle'] ? data['size'] : data['size'] * 2,
            decoration: BoxDecoration(
              color: data['color'],
              shape: data['isCircle'] ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: data['isCircle'] ? null : BorderRadius.circular(1),
            ),
          ),
        ),
      );
    }).toList();
  }
}
