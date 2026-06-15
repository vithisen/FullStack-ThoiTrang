import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../widgets/safe_network_image.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;
  String _selectedSize = 'Size';
  String _selectedColor = 'Black';
  bool _didLoad = false;
  Map<String, dynamic>? _product;
  List<String> _availableSizes = ['XS', 'S', 'M', 'L', 'XL'];
  List<String> _availableColors = ['Black', 'Red', 'White'];

  List<Map<String, dynamic>> _relatedProducts = [
    {
      "name": "Evening Dress",
      "brand": "Dorothy Perkins",
      "img": "assets/picture/main page/main3_newcollection.webp",
      "stars": 5,
      "reviews": 10,
      "price": "12\$",
      "originalPrice": "15\$",
      "discount": "-20%",
      "isFavorite": false,
    },
    {
      "name": "T-Shirt Sailing",
      "brand": "Mango Boy",
      "img": "assets/picture/shoes/shoes1.webp",
      "stars": 0,
      "reviews": 0,
      "price": "10\$",
      "originalPrice": "",
      "discount": "NEW",
      "isFavorite": false,
    },
    {
      "name": "T-Shirt Sport",
      "brand": "Mango Boy",
      "img": "assets/picture/accesories/accesories1.webp",
      "stars": 4,
      "reviews": 5,
      "price": "12\$",
      "originalPrice": "",
      "discount": "",
      "isFavorite": true,
    },
  ];

  final List<String> _productImages = [
    "assets/picture/Sale/sale1.webp", // Front
    "assets/picture/New/new1.webp", // Side
    "assets/picture/catalog1/pullover.webp", // Back
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final productId = args?['apiId'] as int?;
    if (productId != null) {
      _loadProductData(productId);
    }
  }

  Future<void> _loadProductData(int productId) async {
    try {
      final detail = await ApiService.productDetail(productId);
      final related = await ApiService.relatedProducts(productId);
      final favoriteIds = await _loadFavoriteIds();
      if (!mounted) return;
      setState(() {
        _product = detail;
        _isFavorite = favoriteIds.contains(productId);
        _relatedProducts = related.whereType<Map<String, dynamic>>().map((
          product,
        ) {
          final item = _mapApiProduct(product);
          item['isFavorite'] = favoriteIds.contains(product['id']);
          return item;
        }).toList();
        _applyAttributes(detail['attributes'] as List<dynamic>? ?? []);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot load product detail: $error')),
      );
    }
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

  void _applyAttributes(List<dynamic> attributes) {
    for (final attribute in attributes.whereType<Map<String, dynamic>>()) {
      final name = '${attribute['attributeName']}'.toLowerCase();
      final values = (attribute['values'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => '${item['attributeValue']}')
          .where((value) => value.trim().isNotEmpty)
          .toList();
      if (name == 'size' && values.isNotEmpty) {
        _availableSizes = values;
        if (_selectedSize == 'Size') _selectedSize = values.first;
      }
      if (name == 'color' && values.isNotEmpty) {
        _availableColors = values;
        if (!_availableColors.contains(_selectedColor)) {
          _selectedColor = values.first;
        }
      }
    }
  }

  Map<String, dynamic> _mapApiProduct(Map<String, dynamic> product) {
    final salePrice = product['salePrice'];
    final comparePrice = product['comparePrice'];
    return {
      "apiId": product['id'],
      "name": product['productName'] ?? '',
      "brand": product['brandName'] ?? '',
      "img": product['thumbnail'] ?? '',
      "stars": ((product['ratingAverage'] as num?) ?? 0).round(),
      "reviews": product['reviewCount'] ?? 0,
      "price":
          "${salePrice is num ? salePrice.toStringAsFixed(0) : salePrice}\$",
      "originalPrice": comparePrice == null
          ? ''
          : "${comparePrice is num ? comparePrice.toStringAsFixed(0) : comparePrice}\$",
      "discount": comparePrice == null ? '' : '-20%',
      "isFavorite": false,
      "description":
          product['productDescription'] ?? product['shortDescription'] ?? '',
      "images": product['images'] ?? [],
    };
  }

  @override
  Widget build(BuildContext context) {
    // Nhận dữ liệu truyền qua arguments từ CatalogScreen
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final product = _product;
    final String productName =
        product?['productName'] ?? args?['name'] ?? 'Short dress';
    final String productBrand =
        product?['brandName'] ?? args?['brand'] ?? 'H&M';
    final salePrice = product?['salePrice'];
    final String productPrice = product == null
        ? (args?['price'] ?? '\$19.99')
        : '${salePrice is num ? salePrice.toStringAsFixed(0) : salePrice}\$';
    final String productImg =
        product?['thumbnail'] ?? args?['img'] ?? _productImages[0];
    final int productStars = product == null
        ? (args?['stars'] ?? 5)
        : ((product['ratingAverage'] as num?) ?? 0).round();
    final int productReviews = product == null
        ? (args?['reviews'] ?? 10)
        : ((product['reviewCount'] as num?) ?? 0).toInt();
    final int? productId = (product?['id'] as int?) ?? args?['apiId'] as int?;
    final String productDescription =
        product?['productDescription'] ??
        args?['description'] ??
        'Short dress in soft cotton jersey with decorative buttons down the front and a wide, frill-trimmed collar. Short puff sleeves with narrow, covered elastication, and a flared skirt.';

    // Cập nhật danh sách ảnh hiển thị chính
    final apiImages = (product?['images'] as List<dynamic>? ?? [])
        .map((value) => '$value')
        .toList();
    final List<String> displayImages = apiImages.isEmpty
        ? [productImg, ..._productImages.skip(1)]
        : apiImages;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textBlack,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          productName,
          style: const TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.textBlack),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shared successfully!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Carousel (Scrollable)
            SizedBox(
              height: 410,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16, right: 8),
                itemCount: displayImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SafeNetworkImage(
                      url: displayImages[index],
                      width: MediaQuery.of(context).size.width * 0.72,
                      height: 410,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // 2. Dropdowns & Favorite row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Size Dropdown
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showSizeSelection(context, productId),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderGrey),
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedSize,
                              style: const TextStyle(
                                color: AppColors.textBlack,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.textBlack,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Color Dropdown
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showColorSelection(context),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderGrey),
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedColor,
                              style: const TextStyle(
                                color: AppColors.textBlack,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.textBlack,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Favorite button
                  GestureDetector(
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        if (productId == null) {
                          throw Exception('Product is not synced with API');
                        }
                        if (!ApiService.hasSession) {
                          throw Exception('Please login first');
                        }
                        if (_isFavorite) {
                          await ApiService.removeFavorite(productId);
                        } else {
                          await ApiService.addFavorite(productId);
                        }
                        if (!mounted) return;
                        setState(() {
                          _isFavorite = !_isFavorite;
                        });
                      } catch (error) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Cannot update favorite: $error'),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
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
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite
                            ? AppColors.primaryRed
                            : AppColors.textGrey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Product info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productBrand,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          productName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Stars Rating
                        GestureDetector(
                          onTap: productId == null
                              ? null
                              : () async {
                                  await Navigator.pushNamed(
                                    context,
                                    '/rating_reviews',
                                    arguments: {'productId': productId},
                                  );
                                  if (!mounted) return;
                                  await _loadProductData(productId);
                                },
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < productStars
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 14,
                                  );
                                }),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '($productReviews)',
                                style: const TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    productPrice,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Description text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                productDescription,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textBlack,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. Add to Cart Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      if (productId == null) {
                        throw Exception('Product is not synced with API');
                      }
                      await ApiService.addCartItem(
                        productId,
                        size: _selectedSize == 'Size' ? 'L' : _selectedSize,
                        color: _selectedColor,
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added $productName to cart!')),
                      );
                    } catch (error) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cannot add to cart: $error')),
                      );
                    }
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
                    'ADD TO CART',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Divider(height: 1, color: AppColors.borderGrey),

            // 5. Collapsible menu items
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening Shipping Info...')),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Shipping info',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textBlack,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_right, color: AppColors.textGrey),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.borderGrey),

            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening Support...')),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Support',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textBlack,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_right, color: AppColors.textGrey),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.borderGrey),
            const SizedBox(height: 24),

            // 6. You can also like this
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'You can also like this',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  Text(
                    '${_relatedProducts.length} items',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Related Products Horizontal List
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _relatedProducts.length,
                itemBuilder: (context, index) {
                  final item = _relatedProducts[index];
                  final isNew = item['discount'] == 'NEW';
                  final hasDiscount =
                      !isNew && (item['discount'] as String).isNotEmpty;

                  return GestureDetector(
                    onTap: () => _openRelatedProduct(item),
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image with Tags & Heart Button
                          Stack(
                            children: [
                              SafeNetworkImage(
                                url: item['img'],
                                height: 180,
                                width: 150,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              // Discount / NEW label
                              if (isNew || hasDiscount)
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isNew
                                          ? AppColors.textBlack
                                          : AppColors.primaryRed,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      item['discount'],
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              // Heart Button
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: GestureDetector(
                                    onTap: () => _toggleRelatedFavorite(item),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        item['isFavorite'] as bool
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: item['isFavorite'] as bool
                                            ? AppColors.primaryRed
                                            : AppColors.textGrey,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Rating
                          Row(
                            children: [
                              Row(
                                children: List.generate(5, (sIdx) {
                                  return Icon(
                                    sIdx < item['stars']
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 12,
                                  );
                                }),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${item['reviews']})',
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
                            item['brand'],
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 11,
                            ),
                          ),
                          // Name
                          Text(
                            item['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textBlack,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Price
                          Row(
                            children: [
                              if (hasDiscount) ...[
                                Text(
                                  '${item['originalPrice']} ',
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: AppColors.textGrey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  item['price'],
                                  style: const TextStyle(
                                    color: AppColors.primaryRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ] else
                                Text(
                                  item['price'],
                                  style: const TextStyle(
                                    color: AppColors.textBlack,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _openRelatedProduct(Map<String, dynamic> item) {
    Navigator.pushNamed(
      context,
      '/product_detail',
      arguments: {
        "apiId": item['apiId'],
        "name": item['name'] ?? '',
        "brand": item['brand'] ?? '',
        "img": item['img'] ?? '',
        "price": item['price'] ?? '',
        "description": item['description'] ?? '',
        "images": item['images'] ?? [],
      },
    );
  }

  Future<void> _toggleRelatedFavorite(Map<String, dynamic> item) async {
    final productId = item['apiId'] as int?;
    if (productId == null) return;
    if (!ApiService.hasSession) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save favorites.')),
      );
      return;
    }
    final isFavorite = item['isFavorite'] as bool? ?? false;
    try {
      if (isFavorite) {
        await ApiService.removeFavorite(productId);
      } else {
        await ApiService.addFavorite(productId);
      }
      if (!mounted) return;
      setState(() {
        item['isFavorite'] = !isFavorite;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot update favorite: $error')));
    }
  }

  // Show Size Selection (custom sheet or existing dialog style)
  void _showSizeSelection(BuildContext context, int? productId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String innerSize = _selectedSize == 'Size' ? '' : _selectedSize;
        final List<String> sizes = _availableSizes;

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
                        final isSelected = size == innerSize;
                        final itemWidth =
                            (MediaQuery.of(context).size.width - 32 - 32) / 3;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              innerSize = size;
                            });
                            setState(() {
                              _selectedSize = size;
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
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening Size Info...')),
                      );
                    },
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
                            Icons.keyboard_arrow_right,
                            color: AppColors.textGrey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.borderGrey),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            if (productId == null) {
                              throw Exception('Product is not synced with API');
                            }
                            await ApiService.addCartItem(
                              productId,
                              size: _selectedSize == 'Size'
                                  ? 'L'
                                  : _selectedSize,
                              color: _selectedColor,
                            );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added to cart with size $_selectedSize!',
                                ),
                              ),
                            );
                          } catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Cannot add to cart: $error'),
                              ),
                            );
                          }
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
                          'ADD TO CART',
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

  // Show Color Selection
  void _showColorSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String innerColor = _selectedColor;
        final List<String> colors = _availableColors;

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
                    'Select color',
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
                      children: colors.map((colorName) {
                        final isSelected = colorName == innerColor;
                        final itemWidth =
                            (MediaQuery.of(context).size.width - 32 - 32) / 3;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              innerColor = colorName;
                            });
                            setState(() {
                              _selectedColor = colorName;
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
                              colorName,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'CONFIRM',
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
