import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../widgets/safe_network_image.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = false;

  // Mock promo codes data
  List<Map<String, dynamic>> _promos = [
    {
      "code": "mypromocode2020",
      "title": "Personal offer",
      "discountPercent": 10,
      "daysRemaining": 6,
      "color": AppColors.primaryRed,
      "isImage": false,
    },
    {
      "code": "summer2020",
      "title": "Summer Sale",
      "discountPercent": 15,
      "daysRemaining": 23,
      "color": null,
      "isImage": true,
      "imgUrl": "assets/picture/catalog1/pullover.webp",
    },
    {
      "code": "mypromocode2022",
      "title": "Personal offer",
      "discountPercent": 22,
      "daysRemaining": 6,
      "color": AppColors.textBlack,
      "isImage": false,
    },
  ];

  String _appliedPromoCode = "";
  double _discountPercent = 0.0;
  final TextEditingController _promoController = TextEditingController();

  double get _subtotal {
    double total = 0;
    for (var item in _cartItems) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  double get _total {
    double sub = _subtotal;
    return sub - (sub * (_discountPercent / 100));
  }

  String _formatMoney(num value) {
    final amount = value.toDouble();
    if (amount == amount.roundToDouble()) {
      return amount.toStringAsFixed(0);
    }
    return amount.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final cart = await ApiService.cart();
      final coupons = await ApiService.coupons();
      final items = (cart['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(_mapCartItem)
          .toList();
      if (!mounted) return;
      setState(() {
        _cartItems = items;
        _promos = coupons
            .whereType<Map<String, dynamic>>()
            .map(_mapCoupon)
            .toList();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot load cart: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _mapCoupon(Map<String, dynamic> coupon) {
    final discount = coupon['discountValue'];
    return {
      "code": coupon['code'] ?? '',
      "title": "Personal offer",
      "discountPercent": discount is num
          ? discount.toDouble()
          : double.tryParse('$discount') ?? 0,
      "daysRemaining": 30,
      "color": AppColors.primaryRed,
      "isImage": false,
    };
  }

  Future<void> _deleteCartItem(int index) async {
    final item = _cartItems[index];
    final itemId = item['apiId'] as int?;
    if (itemId != null) {
      await ApiService.deleteCartItem(itemId);
    }
    if (!mounted) return;
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  Future<void> _changeQuantity(int index, int nextQuantity) async {
    final item = _cartItems[index];
    if (nextQuantity <= 0) {
      await _deleteCartItem(index);
      return;
    }
    final itemId = item['apiId'] as int?;
    if (itemId != null) {
      await ApiService.updateCartItem(itemId, nextQuantity);
    }
    if (!mounted) return;
    setState(() {
      item['quantity'] = nextQuantity;
    });
  }

  Future<void> _addCartItemToFavorite(Map<String, dynamic> item) async {
    final productId = item['productId'] as int?;
    if (!ApiService.hasSession) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save favorites.')),
      );
      return;
    }
    if (productId != null) {
      await ApiService.addFavorite(productId);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${item['name']} to favorites!')),
    );
  }

  Map<String, dynamic> _mapCartItem(Map<String, dynamic> item) {
    final product = item['product'] as Map<String, dynamic>? ?? {};
    final price = product['salePrice'];
    return {
      "apiId": item['id'],
      "productId": product['id'],
      "name": product['productName'] ?? '',
      "color": item['color'] ?? "Black",
      "size": item['size'] ?? "L",
      "price": price is num ? price.toDouble() : double.tryParse('$price') ?? 0,
      "quantity": item['quantity'] ?? 1,
      "img": product['thumbnail'] ?? 'assets/picture/catalog1/blouse.webp',
    };
  }

  void _applyPromo(String code, double percent) {
    setState(() {
      _appliedPromoCode = code;
      _discountPercent = percent;
      _promoController.text = code;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Applied promo code: $code (-$percent%)')),
    );
  }

  void _showPromoBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Drag handle
                  Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Input Promo Code at top of Bottom Sheet
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
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
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: TextField(
                                controller: _promoController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your promo code',
                                  hintStyle: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_promoController.text.isNotEmpty) {
                                // Find matched promo
                                final entered = _promoController.text.trim();
                                final matched = _promos.firstWhere(
                                  (p) =>
                                      p['code'].toString().toLowerCase() ==
                                      entered.toLowerCase(),
                                  orElse: () => {},
                                );
                                if (matched.isNotEmpty) {
                                  _applyPromo(
                                    matched['code'],
                                    matched['discountPercent'].toDouble(),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Invalid promo code'),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.textBlack,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                color: AppColors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Your Promo Codes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Promos list
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _promos.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final promo = _promos[index];
                        return Container(
                          height: 80,
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
                              // Left Visual Box
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                                child: promo['isImage']
                                    ? Stack(
                                        children: [
                                          SafeNetworkImage(
                                            url: promo['imgUrl'],
                                            width: 80,
                                            height: 80,
                                          ),
                                          Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${promo['discountPercent']}%\noff',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: AppColors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                height: 1.1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(
                                        width: 80,
                                        height: 80,
                                        color:
                                            promo['color'] ??
                                            AppColors.primaryRed,
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${promo['discountPercent']}%\noff',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            height: 1.1,
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              // Middle content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      promo['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.textBlack,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      promo['code'],
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textBlack,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Right Action & Remaining days
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${promo['daysRemaining']} days remaining',
                                      style: const TextStyle(
                                        color: AppColors.textGrey,
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 32,
                                      width: 76,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _applyPromo(
                                            promo['code'],
                                            promo['discountPercent'].toDouble(),
                                          );
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryRed,
                                          foregroundColor: AppColors.white,
                                          padding: EdgeInsets.zero,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Apply',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'My Bag',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Items List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryRed,
                    ),
                  )
                : _cartItems.isEmpty
                ? const Center(
                    child: Text(
                      'Your bag is empty',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _cartItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return Container(
                        height: 104,
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
                            // Product Image
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                              child: SafeNetworkImage(
                                url: item['img'],
                                width: 104,
                                height: 104,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Product details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 4,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item['name'],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: AppColors.textBlack,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: PopupMenuButton<String>(
                                                color: AppColors.white,
                                                offset: const Offset(-30, 0),
                                                icon: const Icon(
                                                  Icons.more_vert,
                                                  color: AppColors.textGrey,
                                                  size: 20,
                                                ),
                                                padding: EdgeInsets.zero,
                                                style: const ButtonStyle(
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),
                                                onSelected: (value) async {
                                                  if (value == 'favorite') {
                                                    await _addCartItemToFavorite(
                                                      item,
                                                    );
                                                  } else if (value ==
                                                      'delete') {
                                                    await _deleteCartItem(
                                                      index,
                                                    );
                                                  }
                                                },
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(
                                                    value: 'favorite',
                                                    child: Text(
                                                      'Add to favorites',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text(
                                                      'Delete from the list',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 1),
                                        Row(
                                          children: [
                                            Text(
                                              'Color: ${item['color']}',
                                              style: const TextStyle(
                                                color: AppColors.textGrey,
                                                fontSize: 11,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Size: ${item['size']}',
                                              style: const TextStyle(
                                                color: AppColors.textGrey,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        // Counter
                                        Flexible(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  await _changeQuantity(
                                                    index,
                                                    (item['quantity'] as int) -
                                                        1,
                                                  );
                                                },
                                                child: Container(
                                                  width: 28,
                                                  height: 28,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.white,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.08),
                                                        blurRadius: 4,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Icon(
                                                    Icons.remove,
                                                    color: AppColors.textGrey,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  '${item['quantity']}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: AppColors.textBlack,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              GestureDetector(
                                                onTap: () async {
                                                  await _changeQuantity(
                                                    index,
                                                    (item['quantity'] as int) +
                                                        1,
                                                  );
                                                },
                                                child: Container(
                                                  width: 28,
                                                  height: 28,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.white,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.08),
                                                        blurRadius: 4,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Icon(
                                                    Icons.add,
                                                    color: AppColors.textGrey,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Price
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 12,
                                            ),
                                            child: Text(
                                              '${_formatMoney((item['price'] as num) * (item['quantity'] as int))}\$',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: AppColors.textBlack,
                                              ),
                                            ),
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
                      );
                    },
                  ),
          ),

          // Promo code Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _promoController,
                        readOnly: true,
                        onTap: _showPromoBottomSheet,
                        decoration: const InputDecoration(
                          hintText: 'Enter your promo code',
                          hintStyle: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _appliedPromoCode.isNotEmpty
                        ? () {
                            setState(() {
                              _appliedPromoCode = "";
                              _discountPercent = 0.0;
                              _promoController.clear();
                            });
                          }
                        : _showPromoBottomSheet,
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _appliedPromoCode.isNotEmpty
                            ? Colors.transparent
                            : AppColors.textBlack,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _appliedPromoCode.isNotEmpty
                            ? Icons.close
                            : Icons.arrow_forward,
                        color: _appliedPromoCode.isNotEmpty
                            ? AppColors.textGrey
                            : AppColors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Total amount
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total amount:',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${_total.toStringAsFixed(0)}\$',
                  style: const TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Check out button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(
                        orderAmount: _subtotal,
                        discountPercent: _discountPercent,
                        couponCode: _appliedPromoCode,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'CHECK OUT',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
