import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import 'payment_methods_screen.dart';
import 'shipping_addresses_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final double orderAmount;
  final double discountPercent;
  final String? couponCode;

  const CheckoutScreen({
    super.key,
    required this.orderAmount,
    required this.discountPercent,
    this.couponCode,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _cardType = "mastercard";
  String _cardNumber = "**** **** **** 3947";
  String _shippingName = "Jane Doe";
  String _shippingAddress =
      "3 Newbridge Court\nChino Hills, CA 91709, United States";
  int? _shippingAddressId;

  // Delivery methods data
  List<Map<String, dynamic>> _deliveryMethods = [
    {
      "id": 1,
      "name": "FedEx",
      "price": 15,
      "logo": "FedEx",
      "logoColor": Colors.deepPurple,
      "textColor": Colors.orange,
      "time": "2-3 days",
    },
    {
      "id": 2,
      "name": "USPS",
      "price": 10,
      "logo": "USPS",
      "logoColor": Colors.blue[900],
      "textColor": Colors.red,
      "time": "2-3 days",
    },
    {
      "id": 3,
      "name": "DHL",
      "price": 20,
      "logo": "DHL",
      "logoColor": Colors.amber[700],
      "textColor": Colors.red,
      "time": "2-3 days",
    },
  ];

  int? _selectedDeliveryId = 1;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
    _loadShippingMethods();
  }

  Future<void> _loadShippingMethods() async {
    try {
      final methods = await ApiService.shippingMethods();
      if (!mounted || methods.isEmpty) return;
      setState(() {
        _deliveryMethods = methods.whereType<Map<String, dynamic>>().map((
          method,
        ) {
          return {
            "id": method['id'],
            "name": method['displayName'] ?? method['name'] ?? '',
            "price": method['price'] ?? 0,
            "logo": method['displayName'] ?? method['name'] ?? '',
            "logoColor": Colors.deepPurple,
            "textColor": Colors.orange,
            "time": "2-3 days",
          };
        }).toList();
        _selectedDeliveryId = _deliveryMethods.first['id'] as int?;
      });
    } catch (_) {}
  }

  Future<void> _loadDefaultAddress() async {
    try {
      final addresses = await ApiService.addresses();
      if (addresses.isEmpty || !mounted) return;
      final selected = addresses.cast<Map<String, dynamic>>().firstWhere(
        (address) => address['defaultAddress'] == true,
        orElse: () => addresses.first as Map<String, dynamic>,
      );
      setState(() {
        _shippingAddressId = selected['id'] as int?;
        _shippingName = selected['fullName'] ?? _shippingName;
        _shippingAddress =
            '${selected['addressLine1'] ?? ''}\n${selected['city'] ?? ''} ${selected['postalCode'] ?? ''}, ${selected['country'] ?? ''}';
      });
    } catch (_) {}
  }

  double get _discountedOrderAmount {
    return widget.orderAmount -
        (widget.orderAmount * (widget.discountPercent / 100));
  }

  double get _deliveryPrice {
    final method = _deliveryMethods.firstWhere(
      (m) => m['id'] == _selectedDeliveryId,
      orElse: () => _deliveryMethods[0],
    );
    final price = method['price'];
    return price is num ? price.toDouble() : double.tryParse('$price') ?? 0;
  }

  double get _totalAmount {
    return _discountedOrderAmount + _deliveryPrice;
  }

  Future<void> _submitOrder() async {
    setState(() {
      _isSubmitting = true;
    });
    try {
      await ApiService.createOrder(
        addressId: _shippingAddressId,
        couponCode: widget.couponCode,
        shippingMethodId: _selectedDeliveryId,
      );
      if (!mounted) return;
      Navigator.pushNamed(context, '/order_success');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot submit order: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildCardLogo() {
    if (_cardType == 'visa') {
      return Text(
        'VISA',
        style: TextStyle(
          color: Colors.blue[800],
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    return SizedBox(
      width: 32,
      height: 20,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFEB0015), // Red
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 12,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(
                  0xFFFF5F00,
                ).withOpacity(0.85), // Yellow-orange
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
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
            Icons.arrow_back_ios_new,
            color: AppColors.textBlack,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Scrollable form area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Shipping address title
                  const Text(
                    'Shipping address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Shipping address card
                  Container(
                    padding: const EdgeInsets.all(16),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _shippingName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textBlack,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _shippingAddress,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textBlack.withValues(
                                    alpha: 0.8,
                                  ),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ShippingAddressesScreen(),
                              ),
                            );
                            if (result != null &&
                                result is Map<String, dynamic>) {
                              setState(() {
                                _shippingAddressId = result['id'] as int?;
                                _shippingName = result['name'];
                                _shippingAddress =
                                    '${result['address']}\n${result['city']} ${result['zip']}, ${result['country']}';
                              });
                            }
                          },
                          child: const Text(
                            'Change',
                            style: TextStyle(
                              color: AppColors.primaryRed,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Payment title and link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PaymentMethodsScreen(),
                            ),
                          );
                          if (result != null &&
                              result is Map<String, dynamic>) {
                            setState(() {
                              _cardType = result['type'];
                              _cardNumber = result['fullName'];
                            });
                          }
                        },
                        child: const Text(
                          'Change',
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Payment card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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
                        _buildCardLogo(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _cardNumber,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textBlack,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Delivery method title
                  const Text(
                    'Delivery method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Delivery options row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _deliveryMethods.map((method) {
                      final isSelected = method['id'] == _selectedDeliveryId;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDeliveryId = method['id'];
                          });
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 48) / 3,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryRed
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isSelected ? 0.08 : 0.04,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    method['logo'],
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: method['logoColor'],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                method['time'],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // 2. Pinned bottom container for totals and action button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Order:',
                      style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                    ),
                    Text(
                      '${_discountedOrderAmount.toStringAsFixed(0)}\$',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Delivery:',
                      style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                    ),
                    Text(
                      '${_deliveryPrice.toStringAsFixed(0)}\$',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Summary:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                      ),
                    ),
                    Text(
                      '${_totalAmount.toStringAsFixed(0)}\$',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Text(
                            'SUBMIT ORDER',
                            style: TextStyle(
                              fontSize: 14,
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
  }
}
