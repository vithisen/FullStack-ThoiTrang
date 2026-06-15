import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../widgets/safe_network_image.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _activeSubTab = 0;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await ApiService.categories();
      if (!mounted) return;
      setState(() {
        final categoryMap = {
          for (final item in data.whereType<Map<String, dynamic>>())
            '${item['categoryName'] ?? ''}': item,
        };
        _categories = ['New', 'Clothes', 'Shoes', 'Accessories'].map((name) {
          final item = categoryMap[name];
          return {
            "id": item?['id'],
            "name": name,
            "img":
                item?['image'] ??
                (name == 'Shoes'
                    ? "assets/picture/shoes/shoes1.webp"
                    : name == 'Accessories'
                    ? "assets/picture/accesories/accesories1.webp"
                    : name == 'New'
                    ? "assets/picture/categories/new.webp"
                    : "assets/picture/categories/clothes.webp"),
          };
        }).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
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
            // Nhấn back sẽ không làm gì nếu đây là root tab của BottomNav,
            // nhưng để đúng thiết kế ta vẫn để hàm quay lại
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Categories',
          style: TextStyle(
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
        children: [
          Container(
            color: AppColors.white,
            height: 48,
            child: Row(
              children: [
                _buildSubTab(0, 'Women'),
                _buildSubTab(1, 'Men'),
                _buildSubTab(2, 'Kids'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryRed,
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryRed.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          child: const Column(
                            children: [
                              Text(
                                'SUMMER SALES',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Up to 50% off',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _categories.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final item = _categories[index];
                            return GestureDetector(
                              onTap: () => _openCategory(item),
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Tên danh mục bên trái
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 24.0,
                                        ),
                                        child: Text(
                                          '${item['name']}',
                                          style: const TextStyle(
                                            color: AppColors.textBlack,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Hình ảnh danh mục bên phải
                                    SafeNetworkImage(
                                      url: '${item['img']}',
                                      width: 170,
                                      height: 100,
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTab(int index, String label) {
    final bool isActive = _activeSubTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeSubTab = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.primaryRed : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textBlack,
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openCategory(Map<String, dynamic> item) {
    final name = item['name'] as String;
    final id = item['id'] as int?;
    if (name == 'Clothes') {
      Navigator.pushNamed(
        context,
        '/sub_categories',
        arguments: {'categoryId': id, 'category': name},
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/catalog',
      arguments: {
        if (name == 'Shoes') 'categoryId': id,
        'category': name,
        'subcategory': 'All Items',
        if (name == 'New') 'sort': 'newest',
        if (name == 'Accessories') 'q': 'Dior',
      },
    );
  }
}
