import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../services/api_service.dart';
import '../../../widgets/safe_network_image.dart';

class MainPage3 extends StatefulWidget {
  const MainPage3({super.key});

  @override
  State<MainPage3> createState() => _MainPage3State();
}

class _MainPage3State extends State<MainPage3> {
  static const String _fallbackBanner =
      "assets/picture/men/clothes/clothes1.webp";
  static const String _fallbackBlackProduct =
      "assets/picture/categories/clothes.webp";
  static const String _fallbackHoodieProduct =
      "assets/picture/main page/mainpage.webp";

  String _bannerUrl = _fallbackBanner;
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final results = await Future.wait([
        ApiService.slideshows(),
        ApiService.products(sort: 'newest'),
      ]);
      if (!mounted) return;
      final slides = results[0].whereType<Map<String, dynamic>>().toList();
      setState(() {
        if (slides.isNotEmpty && '${slides.first['image']}'.trim().isNotEmpty) {
          _bannerUrl = '${slides.first['image']}';
        }
        _products = results[1]
            .whereType<Map<String, dynamic>>()
            .take(4)
            .toList();
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final blackProductUrl = _productImage(0, _fallbackBlackProduct);
    final hoodieProductUrl = _productImage(1, _fallbackHoodieProduct);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Banner New Collection
          Stack(
            children: [
              SafeNetworkImage(
                url: _bannerUrl,
                height: 360,
                width: double.infinity,
              ),
              Container(height: 360, color: Colors.black.withOpacity(0.35)),
              const Positioned(
                bottom: 32,
                left: 16,
                right: 16,
                child: Text(
                  'New collection',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Nút back
              Positioned(
                top: 16,
                left: 8,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.white,
                    ),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          // 2. Lưới ghép ảnh độc đáo
          SizedBox(
            height: 380,
            child: Row(
              children: [
                // Cột trái (Gồm 2 ô vuông chồng lên nhau)
                Expanded(
                  child: Column(
                    children: [
                      // Ô trên: Summer Sale nền trắng chữ đỏ
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/catalog',
                            arguments: {'saleOnly': true},
                          ),
                          child: Container(
                            width: double.infinity,
                            color: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 24,
                            ),
                            child: const Center(
                              child: Text(
                                'Summer\nsale',
                                style: TextStyle(
                                  color: AppColors.primaryRed,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Ô dưới: Ảnh sản phẩm và chữ Black
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _openProductAt(0),
                          child: Stack(
                            children: [
                              SafeNetworkImage(
                                url: blackProductUrl,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              Container(color: Colors.black.withOpacity(0.25)),
                              const Positioned(
                                bottom: 16,
                                left: 16,
                                child: Text(
                                  'Black',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Cột phải (Nguyên cột dọc Men's hoodies)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openProductAt(1),
                    child: Stack(
                      children: [
                        SafeNetworkImage(
                          url: hoodieProductUrl,
                          height: double.infinity,
                          width: double.infinity,
                        ),
                        Container(color: Colors.black.withOpacity(0.25)),
                        const Positioned(
                          bottom: 32,
                          left: 16,
                          right: 16,
                          child: Text(
                            'Men\'s\nhoodies',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _productImage(int index, String fallback) {
    if (_products.length <= index) return fallback;
    final thumbnail = _products[index]['thumbnail'];
    return thumbnail == null || '$thumbnail'.trim().isEmpty
        ? fallback
        : '$thumbnail';
  }

  void _openProductAt(int index) {
    if (_products.length <= index) return;
    final product = _products[index];
    Navigator.pushNamed(
      context,
      '/product_detail',
      arguments: {
        "apiId": product['id'],
        "name": product['productName'] ?? '',
        "brand": product['brandName'] ?? '',
        "img": product['thumbnail'] ?? '',
        "price": "${product['salePrice'] ?? ''}\$",
        "description":
            product['productDescription'] ?? product['shortDescription'] ?? '',
        "images": product['images'] ?? [],
      },
    );
  }
}
