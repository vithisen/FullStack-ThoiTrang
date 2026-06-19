import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../widgets/safe_network_image.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> _favoriteItems = [];

  final List<String> _tags = [
    "Summer",
    "T-Shirts",
    "Shirts",
    "Accessories",
    "Shoes",
  ];
  String _selectedTag = "Summer";
  bool _isListView = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (!ApiService.hasSession) {
        if (!mounted) return;
        setState(() {
          _favoriteItems = [];
        });
        return;
      }
      final favorites = await ApiService.favorites();
      if (!mounted) return;
      setState(() {
        _favoriteItems = favorites
            .whereType<Map<String, dynamic>>()
            .map(_mapProduct)
            .toList();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot load favorites: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _mapProduct(Map<String, dynamic> product) {
    final salePrice = product['salePrice'];
    final comparePrice = product['comparePrice'];
    return {
      "apiId": product['id'],
      "brand": product['brandName'] ?? '',
      "name": product['productName'] ?? '',
      "color": "Black",
      "size": "L",
      "price":
          "${salePrice is num ? salePrice.toStringAsFixed(0) : salePrice}\$",
      "originalPrice": comparePrice == null
          ? ""
          : "${comparePrice is num ? comparePrice.toStringAsFixed(0) : comparePrice}\$",
      "img": product['thumbnail'] ?? "assets/picture/dresses/dresses1.webp",
      "stars": ((product['ratingAverage'] as num?) ?? 0).round(),
      "reviews": product['reviewCount'] ?? 0,
      "tag": comparePrice == null ? "" : "-20%",
      "isSoldOut": false,
      "description":
          product['productDescription'] ?? product['shortDescription'] ?? '',
      "images": product['images'] ?? [],
    };
  }

  Future<void> _removeFavorite(int index) async {
    final productId = _favoriteItems[index]['apiId'] as int?;
    if (!ApiService.hasSession) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to update favorites.')),
      );
      return;
    }
    try {
      if (productId != null) {
        await ApiService.removeFavorite(productId);
      }
      if (!mounted) return;
      setState(() {
        _favoriteItems.removeAt(index);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove favorite: $e')),
      );
    }
  }

  Future<void> _addToBag(Map<String, dynamic> item) async {
    final productId = item['apiId'] as int?;
    try {
      if (productId != null) {
        await ApiService.addCartItem(productId);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Added ${item['name']} to bag!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to bag: $e')),
      );
    }
  }

  void _openProduct(Map<String, dynamic> item) {
    Navigator.pushNamed(
      context,
      '/product_detail',
      arguments: {
        "apiId": item['apiId'],
        "name": item['name'],
        "brand": item['brand'],
        "img": item['img'],
        "price": item['price'],
        "description": item['description'] ?? '',
        "images": item['images'] ?? [],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
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
          // 1. Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Favorites',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Tags Bar
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tags.length,
              itemBuilder: (context, index) {
                final tag = _tags[index];
                final isSelected = tag == _selectedTag;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTag = tag;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.textBlack
                          : AppColors.textBlack,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tag,
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
          const SizedBox(height: 16),

          // 3. Filter Toolbar
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
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
                IconButton(
                  icon: Icon(
                    _isListView ? Icons.view_module : Icons.view_list,
                    color: AppColors.textBlack,
                    size: 18,
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
          const SizedBox(height: 8),

          // 4. Favorites list or grid items
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryRed,
                    ),
                  )
                : _favoriteItems.isEmpty
                ? const Center(
                    child: Text(
                      'No favorites yet',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                    ),
                  )
                : _isListView
                ? _buildListView()
                : _buildGridView(),
          ),
        ],
      ),
    );
  }

  // A. Giao diện dạng Dọc (List View)
  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _favoriteItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = _favoriteItems[index];
        final bool hasTag = (item['tag'] as String).isNotEmpty;
        final bool isNew = item['tag'] == 'NEW';
        final bool hasDiscount = !isNew && hasTag;
        final bool isSoldOut = item['isSoldOut'] as bool;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Card Content
                GestureDetector(
                  onTap: () => _openProduct(item),
                  child: Container(
                    height: 118,
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
                        // Left Image with Tag
                        Stack(
                          children: [
                            SafeNetworkImage(
                              url: item['img'],
                              width: 112,
                              height: 118,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                            // Tag (NEW or Discount)
                            if (hasTag)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isNew
                                        ? AppColors.textBlack
                                        : AppColors.primaryRed,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    item['tag'],
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        // Middle details
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 36, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['brand'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textGrey,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppColors.textBlack,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Color: ${item['color']}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: AppColors.textBlack,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Size: ${item['size']}',
                                          style: const TextStyle(
                                            color: AppColors.textBlack,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Price
                                    Flexible(
                                      child: Row(
                                        children: [
                                          if (hasDiscount) ...[
                                            Flexible(
                                              child: Text(
                                                '${item['originalPrice']} ',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  color: AppColors.textGrey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              item['price'],
                                              style: const TextStyle(
                                                color: AppColors.primaryRed,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ] else
                                            Flexible(
                                              child: Text(
                                                item['price'],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: AppColors.textBlack,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    // Rating stars
                                    Padding(
                                      padding: const EdgeInsets.only(right: 32),
                                      child: Row(
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
                                          const SizedBox(width: 2),
                                          Text(
                                            '(${item['reviews']})',
                                            style: const TextStyle(
                                              color: AppColors.textGrey,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Close / Delete button at top right
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () async {
                      await _removeFavorite(index);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                ),
                // Shopping bag button at bottom right (if not sold out)
                if (!isSoldOut)
                  Positioned(
                    bottom: -6,
                    right: -6,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.shopping_bag,
                          color: AppColors.white,
                          size: 16,
                        ),
                        onPressed: () async {
                          await _addToBag(item);
                        },
                      ),
                    ),
                  ),
              ],
            ),
            if (isSoldOut) ...[
              const SizedBox(height: 6),
              const Text(
                'Sorry, this item is currently sold out',
                style: TextStyle(color: AppColors.textGrey, fontSize: 11),
              ),
            ],
          ],
        );
      },
    );
  }

  // B. Giao diện dạng Lưới (Grid View)
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.53,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _favoriteItems.length,
      itemBuilder: (context, index) {
        final item = _favoriteItems[index];
        final bool hasTag = (item['tag'] as String).isNotEmpty;
        final bool isNew = item['tag'] == 'NEW';
        final bool hasDiscount = !isNew && hasTag;
        final bool isSoldOut = item['isSoldOut'] as bool;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () => _openProduct(item),
                  child: SafeNetworkImage(
                    url: item['img'],
                    height: 184,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Grey Overlay for Sold Out
                if (isSoldOut)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.white.withOpacity(0.7),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      child: const Text(
                        'Sorry, this item is currently sold out',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                // Tag label
                if (hasTag)
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item['tag'],
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Close button at top right
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () async {
                      await _removeFavorite(index);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                ),
                // Red circular shopping bag button at bottom right (if not sold out)
                if (!isSoldOut)
                  Positioned(
                    bottom: -8,
                    right: -8,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.shopping_bag,
                          color: AppColors.white,
                          size: 16,
                        ),
                        onPressed: () async {
                          await _addToBag(item);
                        },
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Rating Stars
            Row(
              children: [
                Row(
                  children: List.generate(5, (sIdx) {
                    return Icon(
                      sIdx < item['stars'] ? Icons.star : Icons.star_border,
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
                    fontSize: 9,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Brand
            Text(
              item['brand'],
              style: const TextStyle(color: AppColors.textGrey, fontSize: 11),
            ),
            // Title
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
            // Color & Size Row
            Row(
              children: [
                Text(
                  'Color: ${item['color']}',
                  style: const TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Size: ${item['size']}',
                  style: const TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
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
        );
      },
    );
  }
}
