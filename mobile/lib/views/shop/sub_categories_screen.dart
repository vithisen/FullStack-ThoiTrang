import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class SubCategoriesScreen extends StatefulWidget {
  const SubCategoriesScreen({super.key});

  @override
  State<SubCategoriesScreen> createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> {
  late final String _categoryName;
  late final int? _categoryId;
  bool _didInitArgs = false;
  bool _isLoadingCategories = true;
  Map<String, int> _categoryIdsByName = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitArgs) return;
    _didInitArgs = true;
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final args = rawArgs is Map<String, dynamic>
        ? rawArgs
        : <String, dynamic>{};
    _categoryName =
        args['category'] as String? ??
        (rawArgs is String ? rawArgs : "Clothes");
    _categoryId = args['categoryId'] as int?;
    _loadCategoryIds();
  }

  Future<void> _loadCategoryIds() async {
    try {
      final categories = await ApiService.categories();
      if (!mounted) return;
      setState(() {
        _categoryIdsByName = {
          for (final item in categories.whereType<Map<String, dynamic>>())
            if (item['id'] is int) '${item['categoryName'] ?? ''}': item['id'],
        };
        _isLoadingCategories = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  List<String> get _subCategories {
    if (_categoryName == "New") {
      return [
        "New Arrivals",
        "Trending Now",
        "Clearance Sale",
        "Summer Collection",
        "Winter Preview",
      ];
    }
    if (_categoryName == "Shoes") {
      return ["Heels", "Sneakers", "Boots", "Sandals", "Flats", "Loafers"];
    }
    if (_categoryName == "Accessories") {
      return [
        "Necklaces",
        "Bags & Purses",
        "Belts",
        "Hats & Caps",
        "Sunglasses",
        "Jewelry",
      ];
    }
    return [
      "Tops",
      "Shirts & Blouses",
      "Cardigans & Sweaters",
      "Knitwear",
      "Blazers",
      "Outerwear",
      "Pants",
      "Jeans",
      "Shorts",
      "Skirts",
      "Dresses",
    ];
  }

  Map<String, dynamic> _catalogArgsFor(String subcategory) {
    final mappedCategory = switch (subcategory) {
      'Shirts & Blouses' => 'Tops',
      'Cardigans & Sweaters' => 'Knitwear',
      'Blazers' => 'Outerwear',
      'Pants' || 'Jeans' || 'Shorts' || 'Skirts' => 'Bottoms',
      _ => subcategory,
    };
    final query = switch (subcategory) {
      'Shirts & Blouses' => 'shirt&blouses',
      'Cardigans & Sweaters' => 'Cardigans & Sweaters',
      'Blazers' => 'blazer',
      'Pants' => 'pants',
      'Jeans' => 'jeans',
      'Shorts' => 'short',
      'Skirts' => 'skirt',
      _ => null,
    };
    final mappedId = _categoryIdsByName[mappedCategory] ?? _categoryId;
    return {
      'categoryId': mappedId,
      'category': _categoryName,
      'subcategory': subcategory,
      if (query != null) 'q': query,
    };
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
        title: Text(
          _categoryName,
          style: const TextStyle(
            color: AppColors.textBlack,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/catalog',
                    arguments: {
                      'categoryId': _categoryId,
                      'category': _categoryName,
                      'subcategory': 'All Items',
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 2,
                  shadowColor: AppColors.primaryRed.withOpacity(0.4),
                ),
                child: const Text(
                  'VIEW ALL ITEMS',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Choose category',
              style: TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.white,
              child: _isLoadingCategories
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryRed,
                      ),
                    )
                  : ListView.separated(
                      itemCount: _subCategories.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.background,
                      ),
                      itemBuilder: (context, index) {
                        final subcategory = _subCategories[index];
                        return ListTile(
                          title: Text(
                            subcategory,
                            style: const TextStyle(
                              color: AppColors.textBlack,
                              fontSize: 16,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 4,
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/catalog',
                              arguments: _catalogArgsFor(subcategory),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
