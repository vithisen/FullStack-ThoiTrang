import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../widgets/safe_network_image.dart';
import 'filters_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  bool _isListView =
      true; // true: dạng Dọc (Catalog 1), false: dạng Lưới (Catalog 2)
  bool _isLoading = false;
  String? _errorMessage;
  bool _didLoad = false;
  int? _categoryId;
  int? _brandId;
  double? _minPrice;
  double? _maxPrice;
  String? _selectedSize;
  String? _selectedColor;
  String? _query;
  String? _assetPathQuery;
  String _audience = 'Women';
  bool? _saleOnly;
  String _sort = 'newest';
  String _displayTitle = "Women's tops";

  // Danh sách các tag phụ trên đầu
  final List<String> _tags = [
    "T-shirts",
    "Crop tops",
    "Sleeveless",
    "Blouses",
    "Shirts",
    "Cardigans",
  ];

  List<Map<String, dynamic>> _products = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    final args =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
        {'category': 'Clothes', 'subcategory': 'Tops'};
    final assetOnly = args['assetOnly'] as bool? ?? false;
    _categoryId = assetOnly ? null : args['categoryId'] as int?;
    _brandId = args['brandId'] as int?;
    _audience =
        (args['audience'] as String?) ??
        (args['category'] as String?) ??
        'Women';
    final routeQuery = args['q'] as String?;
    if (_isAssetPathQuery(routeQuery)) {
      _assetPathQuery = routeQuery;
      _query = null;
    } else {
      _query = routeQuery;
      _assetPathQuery = null;
    }
    _saleOnly = args['saleOnly'] as bool?;
    _sort = args['sort'] as String? ?? _sort;
    final String category = args['category'] ?? "Clothes";
    final String subcategory = args['subcategory'] ?? "Tops";
    _displayTitle = _titleFor(category, subcategory);
    _loadProducts();
  }

  String _titleFor(String category, String subcategory) {
    final prefix = _audience == 'Kids' ? "Kids'" : "$_audience's";
    if (subcategory == 'All Items') {
      return category == _audience ? "$prefix all items" : category;
    }
    if (category == "New" || category == "Shoes" || category == "Accessories") {
      return category;
    }
    return "$prefix ${subcategory.toLowerCase()}";
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final products = await ApiService.products(
        categoryId: _categoryId,
        brandId: _brandId,
        q: _query,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        size: _selectedSize,
        color: _selectedColor,
        saleOnly: _saleOnly,
        sort: _sort,
      );
      final favoriteIds = await _loadFavoriteIds();
      final apiProducts = products.whereType<Map<String, dynamic>>();
      final visibleProducts = _assetPathQuery == null
          ? apiProducts
          : apiProducts.where(
              (product) => _matchesAssetPath(product, _assetPathQuery!),
            );
      if (!mounted) return;
      setState(() {
        _products = visibleProducts.map(_mapApiProduct).toList();
        for (final product in _products) {
          product['isFavorite'] = favoriteIds.contains(product['apiId']);
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _products = [];
        _errorMessage = 'Cannot load products: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isAssetPathQuery(String? query) {
    if (query == null) return false;
    return query.contains('/') || query.contains('&');
  }

  bool _matchesAssetPath(Map<String, dynamic> product, String query) {
    final normalizedQuery = query.toLowerCase();
    bool matches(Object? value) {
      return value?.toString().toLowerCase().contains(normalizedQuery) ?? false;
    }

    if (matches(product['thumbnail'])) return true;
    final images = product['images'];
    if (images is Iterable) {
      return images.any(matches);
    }
    return false;
  }

  Map<String, dynamic> _mapApiProduct(Map<String, dynamic> product) {
    final salePrice = product['salePrice'];
    final comparePrice = product['comparePrice'];
    final priceText =
        '${salePrice is num ? salePrice.toStringAsFixed(0) : salePrice}\$';
    final originalPriceText = comparePrice == null
        ? ''
        : '${comparePrice is num ? comparePrice.toStringAsFixed(0) : comparePrice}\$';
    return {
      "apiId": product['id'],
      "name": product['productName'] ?? '',
      "brand": product['brandName'] ?? '',
      "img": product['thumbnail'] ?? 'assets/picture/main page/main2.webp',
      "stars": ((product['ratingAverage'] as num?) ?? 0).round(),
      "reviews": product['reviewCount'] ?? 0,
      "price": priceText,
      "originalPrice": originalPriceText,
      "discount": originalPriceText.isEmpty ? "" : "-20%",
      "isFavorite": false,
      "description":
          product['productDescription'] ?? product['shortDescription'] ?? '',
      "images": product['images'] ?? [],
    };
  }

  Future<Set<dynamic>> _loadFavoriteIds() async {
    if (!ApiService.hasSession) return {};
    try {
      final favorites = await ApiService.favorites();
      return favorites
          .whereType<Map<String, dynamic>>()
          .map((item) => item['id'])
          .toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> _toggleFavorite(Map<String, dynamic> product) async {
    final productId = product['apiId'] as int?;
    if (!ApiService.hasSession) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save favorites.')),
      );
      return;
    }
    final next = !(product['isFavorite'] as bool);
    if (productId != null) {
      if (next) {
        await ApiService.addFavorite(productId);
      } else {
        await ApiService.removeFavorite(productId);
      }
    }
    if (!mounted) return;
    setState(() {
      product['isFavorite'] = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textBlack,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textBlack),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tiêu đề lớn
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              _displayTitle,
              style: const TextStyle(
                color: AppColors.textBlack,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 2. Danh sách các Tag lọc phụ cuộn ngang nền đen chữ trắng
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tags.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.textBlack,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Center(
                    child: Text(
                      _tags[index],
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // 3. Thanh công cụ lọc & Sắp xếp & Chuyển đổi view (Dọc/Lưới)
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nút Filters
                InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FiltersScreen(),
                      ),
                    );
                    if (result is Map<String, dynamic>) {
                      setState(() {
                        _brandId = result['brandId'] as int?;
                        _minPrice = result['minPrice'] as double?;
                        _maxPrice = result['maxPrice'] as double?;
                        _selectedSize = result['size'] as String?;
                        _selectedColor = result['color'] as String?;
                        _sort = result['sort'] as String? ?? 'newest';
                        if (result['brandName'] != null) {
                          _displayTitle = result['brandName'] as String;
                        }
                      });
                      _loadProducts();
                    }
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: AppColors.textBlack,
                        size: 18,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Filters',
                        style: TextStyle(
                          color: AppColors.textBlack,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Nút Price: lowest to high
                const Row(
                  children: [
                    Icon(Icons.swap_vert, color: AppColors.textBlack, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Price: lowest to high',
                      style: TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                // Nút đổi View Dọc/Lưới
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _isListView
                        ? Icons.view_module
                        : Icons.view_list, // Đổi icon tương ứng
                    color: AppColors.textBlack,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isListView = !_isListView;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
            ),

          // 4. Nội dung sản phẩm
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryRed,
                    ),
                  )
                : _products.isEmpty
                ? _buildEmptyState()
                : _isListView
                ? _buildProductListView()
                : _buildProductGridView(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: AppColors.textGrey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No products found',
              style: TextStyle(
                color: AppColors.textBlack,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try another category or clear your filters.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _brandId = null;
                    _minPrice = null;
                    _maxPrice = null;
                    _selectedSize = null;
                    _selectedColor = null;
                    _saleOnly = null;
                    _sort = 'newest';
                  });
                  _loadProducts();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Text(
                  'CLEAR FILTERS',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A. Giao diện dạng Dọc (Catalog 1)
  Widget _buildProductListView() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final product = _products[index];
        final bool isFav = product['isFavorite'] as bool;
        return InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            '/product_detail',
            arguments: product,
          ),
          child: Container(
            height: 124,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Ảnh sản phẩm bên trái
                SafeNetworkImage(
                  url: product['img'],
                  width: 112,
                  height: 124,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                // Chi tiết sản phẩm bên phải
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 42, 10),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              product['name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textBlack,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              product['brand'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 3),
                            // Đánh giá sao
                            Row(
                              children: [
                                ...List.generate(
                                  5,
                                  (i) => Icon(
                                    Icons.star,
                                    color: i < (product['stars'] as int)
                                        ? Colors.amber
                                        : AppColors.textGrey.withOpacity(0.3),
                                    size: 13,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "(${product['reviews']})",
                                  style: const TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Giá tiền
                            Row(
                              children: [
                                if (product['originalPrice'].isNotEmpty)
                                  Text(
                                    product['originalPrice'],
                                    style: const TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 14,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                if (product['originalPrice'].isNotEmpty)
                                  const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    product['price'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: product['originalPrice'].isNotEmpty
                                          ? AppColors.primaryRed
                                          : AppColors.textBlack,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Nút Tim yêu thích ở góc dưới phải
                        Positioned(
                          bottom: -10,
                          right: -10,
                          child: IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav
                                  ? AppColors.primaryRed
                                  : AppColors.textGrey,
                              size: 22,
                            ),
                            onPressed: () async {
                              await _toggleFavorite(product);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // B. Giao diện dạng Lưới 2 cột (Catalog 2)
  Widget _buildProductGridView() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.55, // Chiều rộng / chiều cao của mỗi ô
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final product = _products[index];
        final bool isFav = product['isFavorite'] as bool;
        final bool hasDiscount = (product['discount'] as String).isNotEmpty;

        return InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            '/product_detail',
            arguments: product,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh sản phẩm, tag giảm giá & nút Tim
              Stack(
                children: [
                  SafeNetworkImage(
                    url: product['img'],
                    height: 184,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // Tag giảm giá đỏ
                  if (hasDiscount)
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
                          product['discount'],
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Nút Tim tròn nổi ở dưới góc phải ảnh
                  Positioned(
                    bottom: 0,
                    right: 0,
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
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav
                                ? AppColors.primaryRed
                                : AppColors.textGrey,
                            size: 20,
                          ),
                          onPressed: () async {
                            await _toggleFavorite(product);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Đánh giá sao
              Row(
                children: [
                  ...List.generate(
                    5,
                    (i) => Icon(
                      Icons.star,
                      color: i < (product['stars'] as int)
                          ? Colors.amber
                          : AppColors.textGrey.withOpacity(0.3),
                      size: 13,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    "(${product['reviews']})",
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Brand
              Text(
                product['brand'],
                style: const TextStyle(color: AppColors.textGrey, fontSize: 11),
              ),
              const SizedBox(height: 2),
              // Name
              Text(
                product['name'],
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
                  if (product['originalPrice'].isNotEmpty)
                    Text(
                      product['originalPrice'],
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  if (product['originalPrice'].isNotEmpty)
                    const SizedBox(width: 4),
                  Text(
                    product['price'],
                    style: TextStyle(
                      color: product['originalPrice'].isNotEmpty
                          ? AppColors.primaryRed
                          : AppColors.textBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
