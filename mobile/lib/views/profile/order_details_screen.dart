import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../widgets/safe_network_image.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailsScreen({super.key, required this.orderData});

  // Mock list of items inside the order
  final List<Map<String, dynamic>> _items = const [
    {
      "name": "Pullover",
      "brand": "Mango",
      "color": "Gray",
      "size": "L",
      "units": 1,
      "price": 51,
      "img": "assets/picture/main page/main2.webp",
    },
    {
      "name": "T-Shirt",
      "brand": "Mango",
      "color": "Gray",
      "size": "L",
      "units": 1,
      "price": 30,
      "img": "assets/picture/main page/main3_menhoodies.webp",
    },
    {
      "name": "Sport Dress",
      "brand": "Mango",
      "color": "Gray",
      "size": "L",
      "units": 1,
      "price": 43,
      "img": "assets/picture/main page/main3_black.webp",
    },
  ];

  Widget _buildMasterCardLogo() {
    return SizedBox(
      width: 26,
      height: 16,
      child: Stack(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: Color(0xFFEB0015), // MasterCard Red
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            left: 10,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFFFF5F00), // MasterCard Orange
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String label, required Widget valueWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
          ),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiItems = (orderData['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final product = item['product'] as Map<String, dynamic>? ?? {};
          final price = item['price'];
          return {
            "productId": product['id'],
            "name": product['productName'] ?? '',
            "brand": product['brandName'] ?? '',
            "color": item['color'] ?? 'Black',
            "size": item['size'] ?? 'L',
            "units": item['quantity'] ?? 1,
            "price": price is num ? price.toStringAsFixed(0) : '$price',
            "img": product['thumbnail'] ?? '',
          };
        })
        .toList();
    final items = apiItems.isEmpty ? _items : apiItems;
    final shipping = orderData['shippingAddress'] as Map<String, dynamic>?;
    final shippingText = shipping == null
        ? 'No shipping address'
        : '${shipping['addressLine1'] ?? ''}, ${shipping['city'] ?? ''} ${shipping['postalCode'] ?? ''}, ${shipping['country'] ?? ''}';
    final shippingMethod = orderData['shippingMethod'] as Map<String, dynamic>?;
    final shippingMethodText = shippingMethod == null
        ? 'No shipping method'
        : '${shippingMethod['displayName'] ?? shippingMethod['name']}, ${orderData['shippingFee'] ?? 0}\$';
    final discountAmount = orderData['discountAmount'] ?? 0;
    final totalAmount = orderData['orderTotal'] ?? orderData['amount'] ?? 0;
    final Color statusColor = orderData['status'] == 'Delivered'
        ? AppColors.successGreen
        : orderData['status'] == 'Processing'
        ? Colors.orange
        : AppColors.errorRed;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textBlack,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: AppColors.textBlack,
              size: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Header summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order №${orderData['number']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      Text(
                        orderData['date'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textGrey,
                          ),
                          children: [
                            const TextSpan(text: 'Tracking number: '),
                            TextSpan(
                              text: orderData['tracking'],
                              style: const TextStyle(
                                color: AppColors.textBlack,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        orderData['status'],
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Quantity label
                  Text(
                    '${items.length} items',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Items List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        height: 118,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Product Image
                            SafeNetworkImage(
                              url: item['img'],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                              width: 104,
                              height: 118,
                            ),
                            const SizedBox(width: 12),
                            // Details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                  horizontal: 8,
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
                                        Text(
                                          item['name'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.textBlack,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item['brand'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textGrey,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Color: ${item['color']}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: AppColors.textGrey,
                                                  fontSize: 11,
                                                ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Units: ${item['units']}',
                                          style: const TextStyle(
                                            color: AppColors.textGrey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            child: Text(
                                              '${item['price']}\$',
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
                  const SizedBox(height: 28),

                  // Order information title
                  const Text(
                    'Order information',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Order Info Rows
                  _buildInfoRow(
                    label: 'Shipping Address:',
                    valueWidget: Text(
                      shippingText,
                      style: const TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ),
                  _buildInfoRow(
                    label: 'Payment method:',
                    valueWidget: Row(
                      children: [
                        _buildMasterCardLogo(),
                        const SizedBox(width: 8),
                        const Text(
                          '**** **** **** 3947',
                          style: TextStyle(
                            color: AppColors.textBlack,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildInfoRow(
                    label: 'Delivery method:',
                    valueWidget: Text(
                      shippingMethodText,
                      style: const TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _buildInfoRow(
                    label: 'Discount:',
                    valueWidget: Text(
                      '${orderData['couponCode'] ?? 'No promo'}, -$discountAmount\$',
                      style: const TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _buildInfoRow(
                    label: 'Total Amount:',
                    valueWidget: Text(
                      '$totalAmount\$',
                      style: const TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () async {
                        try {
                          final orderId = orderData['apiId'] as int?;
                          if (orderId == null) {
                            throw Exception('Order is not synced with API');
                          }
                          await ApiService.reorder(orderId);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Order items added back to cart!'),
                            ),
                          );
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Cannot reorder: $error')),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.textBlack),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Reorder',
                        style: TextStyle(
                          color: AppColors.textBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 6,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final productId = items.isEmpty
                            ? null
                            : items.first['productId'];
                        if (productId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cannot find product to review'),
                            ),
                          );
                          return;
                        }
                        Navigator.pushNamed(
                          context,
                          '/rating_reviews',
                          arguments: {'productId': productId},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Leave feedback',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
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
  }
}
