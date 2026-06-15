import 'package:flutter/material.dart';
import '../../config/theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  // List of payment cards
  final List<Map<String, dynamic>> _cards = [
    {
      "id": "1",
      "type": "mastercard",
      "number": "3947",
      "fullName": "**** **** **** 3947",
      "holder": "Jennyfer Doe",
      "expiry": "05/23",
      "isDefault": true,
      "color": const Color(0xFF222222), // Black card
    },
    {
      "id": "2",
      "type": "visa",
      "number": "4546",
      "fullName": "**** **** **** 4546",
      "holder": "Jennyfer Doe",
      "expiry": "11/22",
      "isDefault": false,
      "color": const Color(0xFF9B9B9B), // Grey card
    },
  ];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _setNewAsDefault = true;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _setDefaultCard(String id) {
    setState(() {
      for (var card in _cards) {
        card['isDefault'] = (card['id'] == id);
      }
    });
  }

  Widget _buildCardChip() {
    return Container(
      width: 36,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withOpacity(0.8), // Gold color
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          // Grid lines to look like a chip
          Positioned(
            top: 6,
            left: 0,
            right: 0,
            child: Container(height: 1, color: Colors.black26),
          ),
          Positioned(
            top: 14,
            left: 0,
            right: 0,
            child: Container(height: 1, color: Colors.black26),
          ),
          Positioned(
            top: 22,
            left: 0,
            right: 0,
            child: Container(height: 1, color: Colors.black26),
          ),
          Positioned(
            left: 12,
            top: 0,
            bottom: 0,
            child: Container(width: 1, color: Colors.black26),
          ),
          Positioned(
            left: 24,
            top: 0,
            bottom: 0,
            child: Container(width: 1, color: Colors.black26),
          ),
        ],
      ),
    );
  }

  Widget _buildMastercardLogo() {
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

  void _showAddCardBottomSheet() {
    _nameController.clear();
    _numberController.clear();
    _expiryController.clear();
    _cvvController.clear();
    _setNewAsDefault = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 16,
                left: 16,
                right: 16,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Container(
                        width: 60,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Add new card',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name on card
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name on card',
                            labelStyle: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter cardholder name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Card number
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _numberController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Card number',
                                  labelStyle: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 12) {
                                    return 'Please enter a valid card number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            _buildMastercardLogo(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Expire Date
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _expiryController,
                          keyboardType: TextInputType.datetime,
                          decoration: const InputDecoration(
                            labelText: 'Expire Date',
                            labelStyle: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null || !value.contains('/')) {
                              return 'Format MM/YY';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // CVV
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cvvController,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'CVV',
                                  labelStyle: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                ),
                                validator: (value) {
                                  if (value == null || value.length < 3) {
                                    return '3 digits';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const Icon(
                              Icons.help_outline,
                              color: AppColors.textGrey,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Set as default checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _setNewAsDefault,
                            activeColor: AppColors.textBlack,
                            onChanged: (bool? val) {
                              setModalState(() {
                                _setNewAsDefault = val ?? true;
                              });
                            },
                          ),
                          const Text(
                            'Set as default payment method',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Add Card Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final numStr = _numberController.text.trim();
                              final last4 = numStr.length >= 4
                                  ? numStr.substring(numStr.length - 4)
                                  : numStr;
                              final type = numStr.startsWith('4')
                                  ? 'visa'
                                  : 'mastercard';

                              final newCard = {
                                "id": (DateTime.now().millisecondsSinceEpoch)
                                    .toString(),
                                "type": type,
                                "number": last4,
                                "fullName": "**** **** **** $last4",
                                "holder": _nameController.text.trim(),
                                "expiry": _expiryController.text.trim(),
                                "isDefault": _setNewAsDefault,
                                "color": type == 'visa'
                                    ? const Color(0xFF9B9B9B)
                                    : const Color(0xFF222222),
                              };

                              setState(() {
                                if (_setNewAsDefault) {
                                  for (var card in _cards) {
                                    card['isDefault'] = false;
                                  }
                                }
                                _cards.add(newCard);
                              });

                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('New card added successfully!'),
                                ),
                              );
                            }
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
                            'ADD CARD',
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textBlack,
          ),
          onPressed: () {
            // Find active default card to pass back
            final defaultCard = _cards.firstWhere(
              (c) => c['isDefault'] == true,
              orElse: () => _cards[0],
            );
            Navigator.pop(context, defaultCard);
          },
        ),
        title: const Text(
          'Payment methods',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Your payment cards',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 20),

            // Card items list
            ..._cards.map((card) {
              final isMC = card['type'] == 'mastercard';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stylized card widget
                  Container(
                    height: 200,
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: card['color'],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Card chip or Logo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (isMC) _buildCardChip(),
                            if (!isMC) const Spacer(),
                            if (!isMC)
                              const Text(
                                'VISA',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),

                        // Card number
                        Text(
                          card['fullName'],
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 22,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        // Chip for visa on bottom left / MC logo on bottom right
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Card Holder Name',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 9,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  card['holder'],
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Expiry Date',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 9,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  card['expiry'],
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (isMC) _buildMastercardLogo(),
                            if (!isMC) _buildCardChip(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Use as default checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: card['isDefault'],
                        activeColor: AppColors.textBlack,
                        onChanged: (bool? val) {
                          if (val == true) {
                            _setDefaultCard(card['id']);
                          }
                        },
                      ),
                      const Text(
                        'Use as default payment method',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCardBottomSheet,
        backgroundColor: AppColors.textBlack,
        foregroundColor: AppColors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }
}
