import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import 'add_shipping_address_screen.dart';

class ShippingAddressesScreen extends StatefulWidget {
  const ShippingAddressesScreen({super.key});

  @override
  State<ShippingAddressesScreen> createState() =>
      _ShippingAddressesScreenState();
}

class _ShippingAddressesScreenState extends State<ShippingAddressesScreen> {
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final data = await ApiService.addresses();
      if (!mounted) return;
      setState(() {
        _addresses = data
            .map((item) => _mapAddress(item as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot load addresses: $error')));
    }
  }

  Map<String, dynamic> _mapAddress(Map<String, dynamic> address) {
    return {
      "id": address['id'],
      "name": address['fullName'] ?? '',
      "address": address['addressLine1'] ?? '',
      "city": address['city'] ?? '',
      "state": '',
      "zip": address['postalCode'] ?? '',
      "country": address['country'] ?? '',
      "isDefault": address['defaultAddress'] == true,
      "api": address,
    };
  }

  Map<String, dynamic>? _selectedOrFirstAddress() {
    if (_addresses.isEmpty) return null;
    return _addresses.firstWhere(
      (addr) => addr['isDefault'] == true,
      orElse: () => _addresses.first,
    );
  }

  Future<void> _selectAddress(dynamic id) async {
    final address = _addresses.firstWhere((addr) => addr['id'] == id);
    final api = Map<String, dynamic>.from(address['api'] as Map);
    api['defaultAddress'] = true;
    try {
      await ApiService.updateAddress(id is int ? id : int.parse('$id'), api);
      await _loadAddresses();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot select address: $error')));
    }
  }

  void _navigateToEdit(Map<String, dynamic> address) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddShippingAddressScreen(addressToEdit: address),
      ),
    );

    if (result != null) await _loadAddresses();
  }

  void _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddShippingAddressScreen()),
    );

    if (result != null) await _loadAddresses();
  }

  Future<void> _deleteAddress(Map<String, dynamic> address) async {
    final id = address['id'];
    if (id == null) return;
    try {
      await ApiService.deleteAddress(id is int ? id : int.parse('$id'));
      await _loadAddresses();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot delete address: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _selectedOrFirstAddress());
      },
      child: Scaffold(
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
            onPressed: () {
              Navigator.pop(context, _selectedOrFirstAddress());
            },
          ),
          title: const Text(
            'Shipping Addresses',
            style: TextStyle(
              color: AppColors.textBlack,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryRed),
              )
            : _addresses.isEmpty
            ? const Center(
                child: Text(
                  'No shipping addresses yet',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _addresses.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final addr = _addresses[index];
                  final bool isSelected = addr['isDefault'] == true;
                  final String fullAddress =
                      '${addr['address']}\n${addr['city']} ${addr['zip']}, ${addr['country']}';

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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              addr['name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBlack,
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _navigateToEdit(addr),
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: AppColors.primaryRed,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () => _deleteAddress(addr),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          fullAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textBlack,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _selectAddress(addr['id']),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.textBlack
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.textBlack
                                        : AppColors.textGrey,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: AppColors.white,
                                        size: 14,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Use as the shipping address',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textBlack,
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.textBlack,
          shape: const CircleBorder(),
          onPressed: _navigateToCreate,
          child: const Icon(Icons.add, color: AppColors.white, size: 24),
        ),
      ),
    );
  }
}
