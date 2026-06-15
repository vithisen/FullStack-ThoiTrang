import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SubCategoriesScreen extends StatelessWidget {
  const SubCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final args = rawArgs is Map<String, dynamic>
        ? rawArgs
        : <String, dynamic>{};
    final String categoryName =
        args['category'] as String? ??
        (rawArgs is String ? rawArgs : "Clothes");
    final int? categoryId = args['categoryId'] as int?;

    // Danh sách danh mục con động tùy thuộc vào danh mục chính được chọn
    final List<String> subCategories;
    if (categoryName == "New") {
      subCategories = [
        "New Arrivals",
        "Trending Now",
        "Clearance Sale",
        "Summer Collection",
        "Winter Preview",
      ];
    } else if (categoryName == "Shoes") {
      subCategories = [
        "Heels",
        "Sneakers",
        "Boots",
        "Sandals",
        "Flats",
        "Loafers",
      ];
    } else if (categoryName == "Accesories") {
      subCategories = [
        "Necklaces",
        "Bags & Purses",
        "Belts",
        "Hats & Caps",
        "Sunglasses",
        "Jewelry",
      ];
    } else {
      // Mặc định là Clothes
      subCategories = [
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
        // Hiển thị tên danh mục chính động trên AppBar
        title: Text(
          categoryName,
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
          // 1. Nút VIEW ALL ITEMS lớn màu đỏ
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // Chuyển sang màn hình Catalog hiển thị tất cả sản phẩm của danh mục
                  Navigator.pushNamed(
                    context,
                    '/catalog',
                    arguments: {
                      'categoryId': categoryId,
                      'category': categoryName,
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

          // 2. Nhãn "Choose category" màu xám
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Choose category',
              style: TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
          ),

          // 3. Danh sách dọc ngăn cách bởi Dividers
          Expanded(
            child: Container(
              color: AppColors.white,
              child: ListView.separated(
                itemCount: subCategories.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.background,
                ),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      subCategories[index],
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
                      // Chuyển sang màn hình Catalog sản phẩm của danh mục con cụ thể
                      Navigator.pushNamed(
                        context,
                        '/catalog',
                        arguments: {
                          'categoryId': categoryId,
                          'category': categoryName,
                          'subcategory': subCategories[index],
                        },
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
