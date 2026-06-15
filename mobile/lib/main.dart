import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'services/api_service.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/sign_up_screen.dart';
import 'views/auth/forgot_password_screen.dart';
import 'views/home/home_screen.dart';
import 'views/shop/sub_categories_screen.dart';
import 'views/shop/catalog_screen.dart';
import 'views/product/product_detail_screen.dart';
import 'views/product/rating_reviews_screen.dart';
import 'views/checkout/shipping_addresses_screen.dart';
import 'views/checkout/add_shipping_address_screen.dart';
import 'views/checkout/success_screen.dart';
import 'views/checkout/payment_methods_screen.dart';
import 'views/profile/my_orders_screen.dart';
import 'views/profile/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.initializeSession();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fashion Shop E-Commerce',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false, // Tắt nhãn DEBUG ở góc màn hình
      initialRoute: '/login', // Mặc định mở màn hình Đăng nhập
      routes: {
        '/login': (context) => const LoginScreen(),
        '/sign_up': (context) => const SignUpScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/sub_categories': (context) => const SubCategoriesScreen(),
        '/catalog': (context) => const CatalogScreen(),
        '/product_detail': (context) => const ProductDetailScreen(),
        '/rating_reviews': (context) => const RatingReviewsScreen(),
        '/shipping_addresses': (context) => const ShippingAddressesScreen(),
        '/add_shipping_address': (context) => const AddShippingAddressScreen(),
        '/order_success': (context) => const SuccessScreen(),
        '/payment_methods': (context) => const PaymentMethodsScreen(),
        '/my_orders': (context) => const MyOrdersScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
