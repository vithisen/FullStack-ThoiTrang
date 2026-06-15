import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryRed = Color(0xFFDB3022); // Màu đỏ cam nút bấm
  static const Color background = Color(0xFFF9F9F9); // Màu nền của app
  static const Color white = Color(0xFFFFFFFF);
  static const Color textBlack = Color(0xFF222222); // Màu chữ chính
  static const Color textGrey = Color(0xFF9B9B9B); // Màu chữ phụ
  static const Color successGreen = Color(0xFF2AA952); // Tích xanh
  static const Color errorRed = Color(0xFFF01F0E); // Màu đỏ báo lỗi
  static const Color borderGrey = Color(0xFFD0D0D0);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryRed,
        primary: AppColors.primaryRed,
        background: AppColors.background,
      ),
      fontFamily: 'Metropolis', // Dễ dàng thay thế bằng font khác của hệ thống
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: AppColors.textBlack,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textBlack),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textGrey),
      ),
    );
  }
}
