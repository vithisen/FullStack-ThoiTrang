import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../services/api_service.dart';
import '../../../widgets/safe_network_image.dart';

class MainPage1 extends StatefulWidget {
  const MainPage1({super.key});

  @override
  State<MainPage1> createState() => _MainPage1State();
}

class _MainPage1State extends State<MainPage1> {
  final String bannerUrl = "assets/picture/mainpage.png";
  final String product1Url = "assets/picture/main3_newcollection.png";
  final String product2Url = "assets/picture/shoes/shoes1.webp";
  final String product3Url = "assets/picture/accesories/accesories1.webp";

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _saleProducts = [];
  final Map<int, bool> _favStates = {};
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final results = await Future.wait([
        ApiService.products(sort: 'newest'),
        ApiService.products(saleOnly: true, sort: 'newest'),
      ]);
      final favoriteIds = await _loadFavoriteIds();
      if (!mounted) return;
      setState(() {
        _products = results[0]
            .whereType<Map<String, dynamic>>()
            .take(6)
            .toList();
        _saleProducts = results[1]
            .whereType<Map<String, dynamic>>()
            .take(8)
            .toList();
        _favStates
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
          // 1. Banner Ảnh Lớn
          Stack(
            children: [
              SafeNetworkImage(
                url: bannerUrl,
                height: 520,
                width: double.infinity,
              ),
              // Đổ bóng màu tối mờ ở nửa dưới banner để nổi bật chữ trắng
              Container(
                height: 520,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
              ),
              // Tiêu đề & Nút bấm trên Banner
              Positioned(
                bottom: 32,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fashion\nsale',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 160,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Check',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Nút Back mũi tên nhỏ ở góc trên trái (cho giống ảnh)
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

          // 2. Section New
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
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

          // 3. Danh sách sản phẩm cuộn ngang
          SizedBox(
            height: 288,
            child: _isLoadingProducts
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryRed,
                    ),
                  )
                : _products.isEmpty
                ? const Center(
                    child: Text(
                      'No new products yet',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  )
                : ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: _products.expand((product) sync* {
                      yield _buildProductItem(
                        product['thumbnail'] ?? product1Url,
                        product['brandName'] ?? 'Fashion',
                        product['productName'] ?? '',
                        product,
                      );
                      yield const SizedBox(width: 16);
                    }).toList(),
                  ),
          ),
          _buildSaleSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSaleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/catalog',
                    arguments: {'saleOnly': true, 'category': 'Sale'},
                  );
                },
                child: const Text(
                  'View all',
                  style: TextStyle(color: AppColors.textBlack, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 288,
          child: _isLoadingProducts
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryRed),
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
                      product['thumbnail'] ?? product1Url,
                      product['brandName'] ?? 'Fashion',
                      product['productName'] ?? '',
                      product,
                    );
                    yield const SizedBox(width: 16);
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildProductItem(
    String imgUrl,
    String category,
    String name,
    Map<String, dynamic>? apiProduct,
  ) {
    final apiId = apiProduct?['id'] as int?;
    final isFav = apiId == null ? false : (_favStates[apiId] ?? false);
    final price = _priceLabel(apiProduct?['salePrice']);
    final stars = ((apiProduct?['ratingAverage'] as num?) ?? 0).round();
    final reviews = ((apiProduct?['reviewCount'] as num?) ?? 0).toInt();

    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh sản phẩm kèm nhãn "NEW" và nút tim
          GestureDetector(
            onTap: apiProduct == null
                ? null
                : () {
                    Navigator.pushNamed(
                      context,
                      '/product_detail',
                      arguments: {
                        "apiId": apiProduct['id'],
                        "name": apiProduct['productName'] ?? '',
                        "brand": apiProduct['brandName'] ?? '',
                        "img": apiProduct['thumbnail'] ?? imgUrl,
                        "price": "${apiProduct['salePrice'] ?? ''}\$",
                        "description":
                            apiProduct['productDescription'] ??
                            apiProduct['shortDescription'] ??
                            '',
                        "images": apiProduct['images'] ?? [],
                      },
                    );
                  },
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
                // Nút Tim tròn nổi ở góc dưới phải giống Grid View
                Positioned(
                  bottom: -8,
                  right: -8,
                  child: GestureDetector(
                    onTap: () {
                      if (apiId == null) {
                        _showAddToFavoritesBottomSheet(context, name);
                        return;
                      }
                      _toggleFavorite(apiId, name, isFav);
                    },
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
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav
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

  Widget _buildSaleProductItem(
    String imgUrl,
    String brand,
    String name,
    Map<String, dynamic>? apiProduct,
  ) {
    final apiId = apiProduct?['id'] as int?;
    final isFav = apiId == null ? false : (_favStates[apiId] ?? false);
    final salePrice = _priceLabel(apiProduct?['salePrice']);
    final comparePrice = _priceLabel(apiProduct?['comparePrice']);
    final discount = _discountLabel(apiProduct);
    final stars = ((apiProduct?['ratingAverage'] as num?) ?? 0).round();
    final reviews = ((apiProduct?['reviewCount'] as num?) ?? 0).toInt();

    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: apiProduct == null
                ? null
                : () {
                    Navigator.pushNamed(
                      context,
                      '/product_detail',
                      arguments: {
                        "apiId": apiProduct['id'],
                        "name": apiProduct['productName'] ?? '',
                        "brand": apiProduct['brandName'] ?? '',
                        "img": apiProduct['thumbnail'] ?? imgUrl,
                        "price": salePrice,
                        "description":
                            apiProduct['productDescription'] ??
                            apiProduct['shortDescription'] ??
                            '',
                        "images": apiProduct['images'] ?? [],
                      },
                    );
                  },
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
                Positioned(
                  bottom: -8,
                  right: -8,
                  child: GestureDetector(
                    onTap: () {
                      if (apiId == null) {
                        _showAddToFavoritesBottomSheet(context, name);
                        return;
                      }
                      _toggleFavorite(apiId, name, isFav);
                    },
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
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav
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
                style: const TextStyle(color: AppColors.textGrey, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            brand,
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
          Row(
            children: [
              if (comparePrice.isNotEmpty) ...[
                Text(
                  comparePrice,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  salePrice,
                  style: const TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _priceLabel(dynamic value) {
    if (value == null) return '';
    if (value is num) return '${value.toStringAsFixed(0)}\$';
    return '$value';
  }

  String _discountLabel(Map<String, dynamic>? product) {
    final sale = product?['salePrice'];
    final compare = product?['comparePrice'];
    if (sale is num && compare is num && compare > sale) {
      final percent = ((compare - sale) / compare * 100).round();
      return '-$percent%';
    }
    return '-20%';
  }

  Future<void> _toggleFavorite(
    int productId,
    String productName,
    bool isFav,
  ) async {
    if (!ApiService.hasSession) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save favorites.')),
      );
      return;
    }
    try {
      if (isFav) {
        await ApiService.removeFavorite(productId);
      } else {
        await ApiService.addFavorite(productId);
      }
      if (!mounted) return;
      setState(() {
        _favStates[productId] = !isFav;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFav
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

  // Bảng chọn kích cỡ để thêm vào Yêu thích (ADD TO FAVORITES)
  void _showAddToFavoritesBottomSheet(
    BuildContext context,
    String productName,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String selectedSize = '';
        final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(top: 12, bottom: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.textGrey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select size',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: sizes.map((size) {
                        final isSelected = size == selectedSize;
                        final itemWidth =
                            (MediaQuery.of(context).size.width - 32 - 32) / 3;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedSize = size;
                            });
                          },
                          child: Container(
                            width: itemWidth,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryRed
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? null
                                  : Border.all(color: AppColors.borderGrey),
                            ),
                            child: Text(
                              size,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.textBlack,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1, color: AppColors.borderGrey),
                  // Size info
                  InkWell(
                    onTap: () {},
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Size info',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textBlack,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.textGrey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.borderGrey),
                  const SizedBox(height: 24),
                  // ADD TO FAVORITES button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedSize.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a size first!'),
                              ),
                            );
                            return;
                          }
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added $productName ($selectedSize) to Favorites!',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 4,
                          shadowColor: AppColors.primaryRed.withOpacity(0.4),
                        ),
                        child: const Text(
                          'ADD TO FAVORITES',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
