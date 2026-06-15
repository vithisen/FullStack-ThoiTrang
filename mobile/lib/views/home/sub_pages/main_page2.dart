import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../services/api_service.dart';
import '../../../widgets/safe_network_image.dart';

class MainPage2 extends StatefulWidget {
  const MainPage2({super.key});

  @override
  State<MainPage2> createState() => _MainPage2State();
}

class _MainPage2State extends State<MainPage2> {
  static const String _bannerUrl = "assets/picture/New/new1.webp";
  static const String _fallbackSale1 = "assets/picture/catalog1/pullover.webp";
  static const String _fallbackNew1 = "assets/picture/catalog1/t_shirt.webp";

  List<Map<String, dynamic>> _saleProducts = [];
  List<Map<String, dynamic>> _newProducts = [];
  final Map<int, bool> _favoriteStates = {};
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadHomeRows();
  }

  Future<void> _loadHomeRows() async {
    try {
      final results = await Future.wait([
        ApiService.products(saleOnly: true, sort: 'newest'),
        ApiService.products(sort: 'newest'),
      ]);
      if (!mounted) return;
      final favoriteIds = await _loadFavoriteIds();
      setState(() {
        _saleProducts = results[0]
            .whereType<Map<String, dynamic>>()
            .take(8)
            .toList();
        _newProducts = results[1]
            .whereType<Map<String, dynamic>>()
            .take(8)
            .toList();
        _favoriteStates
          ..clear()
          ..addEntries(favoriteIds.map((id) => MapEntry(id, true)));
        _isLoadingProducts = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  Future<Set<int>> _loadFavoriteIds() async {
    if (!ApiService.hasSession) return {};
    try {
      final favorites = await ApiService.favorites();
      return favorites
          .whereType<Map<String, dynamic>>()
          .map((item) => item['id'])
          .whereType<int>()
          .toSet();
    } catch (_) {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Banner Street Clothes
          Stack(
            children: [
              const SafeNetworkImage(
                url: _bannerUrl,
                height: 200,
                width: double.infinity,
              ),
              Container(height: 200, color: Colors.black.withOpacity(0.35)),
              const Positioned(
                bottom: 24,
                left: 16,
                child: Text(
                  'Street clothes',
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

          // 2. Section Sale
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sale',
                      style: TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Super summer sale',
                      style: TextStyle(
                        color: AppColors.textGrey.withOpacity(0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'View all',
                    style: TextStyle(color: AppColors.textBlack, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // 3. Danh sách sản phẩm Sale cuộn ngang
          SizedBox(
            height: 288,
            child: _isLoadingProducts
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryRed,
                    ),
                  )
                : _saleProducts.isEmpty
                ? const Center(
                    child: Text(
                      'No sale products yet',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  )
                : ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: _saleProducts.expand((product) sync* {
                      yield _buildSaleProductItem(
                        imgUrl: product['thumbnail'] ?? _fallbackSale1,
                        discount: _discountLabel(product),
                        vendor: product['brandName'] ?? 'Fashion',
                        name: product['productName'] ?? '',
                        originalPrice: _priceLabel(product['comparePrice']),
                        discountPrice: _priceLabel(product['salePrice']),
                        stars: ((product['ratingAverage'] as num?) ?? 0)
                            .round()
                            .toDouble(),
                        reviews: ((product['reviewCount'] as num?) ?? 0)
                            .toInt(),
                        apiProduct: product,
                      );
                      yield const SizedBox(width: 16);
                    }).toList(),
                  ),
          ),

          // 4. Section New
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New',
                      style: TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You\'ve never seen it before!',
                      style: TextStyle(
                        color: AppColors.textGrey.withOpacity(0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'View all',
                    style: TextStyle(color: AppColors.textBlack, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // 5. Danh sách sản phẩm New cuộn ngang
          SizedBox(
            height: 288,
            child: _isLoadingProducts
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryRed,
                    ),
                  )
                : _newProducts.isEmpty
                ? const Center(
                    child: Text(
                      'No new products yet',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  )
                : ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: _newProducts.expand((product) sync* {
                      yield _buildNewProductItem(
                        product['thumbnail'] ?? _fallbackNew1,
                        product['brandName'] ?? 'New Collection',
                        product['productName'] ?? '',
                        apiProduct: product,
                      );
                      yield const SizedBox(width: 16);
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSaleProductItem({
    required String imgUrl,
    required String discount,
    required String vendor,
    required String name,
    required String originalPrice,
    required String discountPrice,
    required double stars,
    required int reviews,
    Map<String, dynamic>? apiProduct,
  }) {
    final productId = apiProduct?['id'] as int?;
    final isFavorite = productId == null
        ? false
        : (_favoriteStates[productId] ?? false);
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh, nhãn giảm giá & nút tim
          GestureDetector(
            onTap: apiProduct == null ? null : () => _openProduct(apiProduct),
            child: Stack(
              children: [
                SafeNetworkImage(
                  url: imgUrl,
                  height: 184,
                  width: 150,
                  borderRadius: BorderRadius.circular(8),
                ),
                // Tag giảm giá đỏ
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      discount,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Nút Heart yêu thích ở dưới góc phải ảnh
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: productId == null
                        ? null
                        : () => _toggleFavorite(productId, name, isFavorite),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? AppColors.primaryRed
                              : AppColors.textGrey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Đánh giá sao
          Row(
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  Icons.star,
                  color: index < stars.toInt()
                      ? Colors.amber
                      : AppColors.textGrey.withOpacity(0.3),
                  size: 13,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                '($reviews)',
                style: const TextStyle(color: AppColors.textGrey, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Vendor name
          Text(
            vendor,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 11),
          ),
          const SizedBox(height: 2),
          // Product Name
          Text(
            name,
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Giá bán
          Row(
            children: [
              Text(
                originalPrice,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                discountPrice,
                style: const TextStyle(
                  color: AppColors.primaryRed,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewProductItem(
    String imgUrl,
    String category,
    String name, {
    Map<String, dynamic>? apiProduct,
  }) {
    final productId = apiProduct?['id'] as int?;
    final isFavorite = productId == null
        ? false
        : (_favoriteStates[productId] ?? false);
    final price = _priceLabel(apiProduct?['salePrice']);
    final stars = ((apiProduct?['ratingAverage'] as num?) ?? 0).round();
    final reviews = ((apiProduct?['reviewCount'] as num?) ?? 0).toInt();

    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: apiProduct == null ? null : () => _openProduct(apiProduct),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SafeNetworkImage(
                  url: imgUrl,
                  height: 184,
                  width: 150,
                  borderRadius: BorderRadius.circular(8),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.textBlack,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -8,
                  right: -8,
                  child: GestureDetector(
                    onTap: productId == null
                        ? null
                        : () => _toggleFavorite(productId, name, isFavorite),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? AppColors.primaryRed
                            : AppColors.textGrey,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (apiProduct != null) ...[
            Row(
              children: [
                ...List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    color: i < stars
                        ? Colors.amber
                        : AppColors.textGrey.withOpacity(0.3),
                    size: 13,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  '($reviews)',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Text(
            category,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            name,
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (price.isNotEmpty)
            Text(
              price,
              style: const TextStyle(
                color: AppColors.textBlack,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  String _priceLabel(dynamic value) {
    if (value == null) return '';
    if (value is num) return '${value.toStringAsFixed(0)}\$';
    return '$value\$';
  }

  String _discountLabel(Map<String, dynamic> product) {
    final sale = product['salePrice'];
    final compare = product['comparePrice'];
    if (sale is num && compare is num && compare > sale) {
      final percent = ((compare - sale) / compare * 100).round();
      return '-$percent%';
    }
    return 'SALE';
  }

  void _openProduct(Map<String, dynamic> product) {
    Navigator.pushNamed(
      context,
      '/product_detail',
      arguments: {
        "apiId": product['id'],
        "name": product['productName'] ?? '',
        "brand": product['brandName'] ?? '',
        "img": product['thumbnail'] ?? '',
        "price": _priceLabel(product['salePrice']),
        "description":
            product['productDescription'] ?? product['shortDescription'] ?? '',
        "images": product['images'] ?? [],
      },
    );
  }

  Future<void> _toggleFavorite(
    int productId,
    String productName,
    bool isFavorite,
  ) async {
    if (!ApiService.hasSession) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save favorites.')),
      );
      return;
    }
    try {
      if (isFavorite) {
        await ApiService.removeFavorite(productId);
      } else {
        await ApiService.addFavorite(productId);
      }
      if (!mounted) return;
      setState(() {
        _favoriteStates[productId] = !isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? 'Removed $productName from favorites.'
                : 'Added $productName to favorites!',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Favorite failed: $error')));
    }
  }
}
