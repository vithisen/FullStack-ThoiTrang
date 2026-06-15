import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'sub_pages/main_page1.dart';
import 'sub_pages/main_page2.dart';
import 'sub_pages/main_page3.dart';
import '../shop/categories_screen.dart';
import '../favorites/favorites_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _cartRefreshVersion = 0;
  int _favoritesRefreshVersion = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeSubPages(), // Tab đầu tiên: Trang chủ chính (chứa PageView lướt ngang)
          const CategoriesScreen(), // Màn hình Phân loại ở tab Shop
          CartScreen(
            key: ValueKey(_cartRefreshVersion),
          ), // Refresh khi bấm tab Bag
          FavoritesScreen(
            key: ValueKey(_favoritesRefreshVersion),
          ), // Refresh khi bấm tab Favorites
          const ProfileScreen(), // Màn hình Hồ sơ cá nhân thực tế
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              if (index == 2) {
                _cartRefreshVersion++;
              }
              if (index == 3) {
                _favoritesRefreshVersion++;
              }
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primaryRed,
          unselectedItemColor: AppColors.textGrey,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home, color: AppColors.primaryRed),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(
                Icons.shopping_cart,
                color: AppColors.primaryRed,
              ),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag, color: AppColors.primaryRed),
              label: 'Bag',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite, color: AppColors.primaryRed),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, color: AppColors.primaryRed),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Widget quản lý PageView của tab Home (cho phép vuốt ngang qua MainPage1, MainPage2, MainPage3)
class HomeSubPages extends StatefulWidget {
  const HomeSubPages({super.key});

  @override
  State<HomeSubPages> createState() => _HomeSubPagesState();
}

class _HomeSubPagesState extends State<HomeSubPages> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const BouncingScrollPhysics(), // Hiệu ứng vuốt nảy mượt mà
      children: const [
        MainPage1(), // Giao diện 1: Fashion Sale
        MainPage2(), // Giao diện 2: Street Clothes
        MainPage3(), // Giao diện 3: New Collection
      ],
    );
  }
}
