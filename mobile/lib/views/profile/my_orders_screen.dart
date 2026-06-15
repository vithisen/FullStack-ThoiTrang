import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import 'order_details_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  String _activeTab = 'Delivered';

  // Mock orders data
  List<Map<String, dynamic>> _orders = [
    {
      "number": "1947034",
      "date": "05-12-2019",
      "tracking": "IW3475453455",
      "quantity": 3,
      "amount": 112,
      "status": "Delivered",
    },
    {
      "number": "1947035",
      "date": "06-12-2019",
      "tracking": "IW3475453456",
      "quantity": 1,
      "amount": 45,
      "status": "Delivered",
    },
    {
      "number": "1947036",
      "date": "08-12-2019",
      "tracking": "IW3475453457",
      "quantity": 2,
      "amount": 80,
      "status": "Processing",
    },
    {
      "number": "1947037",
      "date": "10-12-2019",
      "tracking": "IW3475453458",
      "quantity": 4,
      "amount": 150,
      "status": "Cancelled",
    },
  ];
  bool _isLoading = false;

  List<Map<String, dynamic>> get _filteredOrders {
    return _orders.where((order) => order['status'] == _activeTab).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final orders = await ApiService.orders();
      if (!mounted) return;
      setState(() {
        _orders = orders
            .whereType<Map<String, dynamic>>()
            .map(_mapOrder)
            .toList();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot load orders: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _mapOrder(Map<String, dynamic> order) {
    final items = order['items'] as List<dynamic>? ?? [];
    final amount = order['orderTotal'];
    return {
      "apiId": order['id'],
      "number": order['orderNumber'] ?? order['id'].toString(),
      "date": (order['createdAt'] ?? '').toString().split('T').first,
      "tracking": order['trackingNumber'] ?? '',
      "quantity": items.fold<int>(0, (sum, item) {
        if (item is Map<String, dynamic>) {
          return sum + ((item['quantity'] as num?)?.toInt() ?? 0);
        }
        return sum;
      }),
      "amount": amount is num ? amount.toStringAsFixed(0) : amount,
      "status": order['status'] ?? 'Processing',
      "items": items,
      "shippingAddress": order['shippingAddress'],
    };
  }

  Widget _buildTabButton(String tabName) {
    final bool isActive = _activeTab == tabName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = tabName;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.textBlack : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          tabName,
          style: TextStyle(
            color: isActive ? AppColors.white : AppColors.textBlack,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textBlack,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'My Orders',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTabButton('Delivered'),
                _buildTabButton('Processing'),
                _buildTabButton('Cancelled'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Orders list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryRed,
                    ),
                  )
                : _filteredOrders.isEmpty
                ? Center(
                    child: Text(
                      'No $_activeTab orders found.',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _filteredOrders.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      final Color statusColor = order['status'] == 'Delivered'
                          ? AppColors.successGreen
                          : order['status'] == 'Processing'
                          ? Colors.orange
                          : AppColors.errorRed;

                      return Container(
                        padding: const EdgeInsets.all(16),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order №${order['number']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                                Text(
                                  order['date'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textGrey,
                                ),
                                children: [
                                  const TextSpan(text: 'Tracking number: '),
                                  TextSpan(
                                    text: order['tracking'],
                                    style: const TextStyle(
                                      color: AppColors.textBlack,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Quantity: ${order['quantity']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textGrey,
                                    ),
                                    children: [
                                      const TextSpan(text: 'Total Amount: '),
                                      TextSpan(
                                        text: '${order['amount']}\$',
                                        style: const TextStyle(
                                          color: AppColors.textBlack,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: 36,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OrderDetailsScreen(
                                                orderData: order,
                                              ),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.textBlack,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: const Text(
                                      'Details',
                                      style: TextStyle(
                                        color: AppColors.textBlack,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  order['status'],
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
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
  }
}
