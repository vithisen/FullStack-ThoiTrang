import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class AddShippingAddressScreen extends StatefulWidget {
  final Map<String, dynamic>? addressToEdit;

  const AddShippingAddressScreen({super.key, this.addressToEdit});

  @override
  State<AddShippingAddressScreen> createState() =>
      _AddShippingAddressScreenState();
}

class _AddShippingAddressScreenState extends State<AddShippingAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _zipController;
  late final TextEditingController _countryController;
  bool _isDefault = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text:
          widget.addressToEdit?['name'] ??
          widget.addressToEdit?['fullName'] ??
          '',
    );
    _addressController = TextEditingController(
      text:
          widget.addressToEdit?['address'] ??
          widget.addressToEdit?['addressLine1'] ??
          '',
    );
    _cityController = TextEditingController(
      text: widget.addressToEdit?['city'] ?? '',
    );
    _stateController = TextEditingController(
      text: widget.addressToEdit?['state'] ?? '',
    );
    _zipController = TextEditingController(
      text:
          widget.addressToEdit?['zip'] ??
          widget.addressToEdit?['postalCode'] ??
          '',
    );
    _countryController = TextEditingController(
      text: widget.addressToEdit?['country'] ?? 'United States',
    );
    _isDefault =
        widget.addressToEdit?['isDefault'] == true ||
        widget.addressToEdit?['defaultAddress'] == true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      final body = {
        "fullName": _nameController.text.trim(),
        "addressLine1": _addressController.text.trim(),
        "addressLine2": widget.addressToEdit?['addressLine2'] ?? '',
        "phoneNumber": widget.addressToEdit?['phoneNumber'] ?? '',
        "city": _cityController.text.trim(),
        "postalCode": _zipController.text.trim(),
        "country": _countryController.text.trim(),
        "defaultAddress": _isDefault,
      };
      try {
        final id = widget.addressToEdit?['id'];
        final saved = id == null || '$id'.isEmpty
            ? await ApiService.addAddress(body)
            : await ApiService.updateAddress(
                id is int ? id : int.parse('$id'),
                body,
              );
        if (!mounted) return;
        Navigator.pop(context, _mapAddress(saved));
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Cannot save address: $error')));
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool isSelector = false,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: isSelector
          ? InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.text.isEmpty
                                ? 'Select'
                                : controller.text,
                            style: const TextStyle(
                              color: AppColors.textBlack,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textBlack,
                      size: 20,
                    ),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                  ),
                ),
                TextFormField(
                  controller: controller,
                  validator: validator,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              ],
            ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      builder: (context) {
        final List<String> countries = [
          'United States',
          'Vietnam',
          'Canada',
          'United Kingdom',
          'Germany',
          'France',
          'Japan',
        ];
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Country',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(countries[index]),
                      onTap: () {
                        setState(() {
                          _countryController.text = countries[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.addressToEdit != null;

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
        title: Text(
          isEditMode ? 'Editing Shipping Address' : 'Adding Shipping Address',
          style: const TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _buildInputField(
                        label: 'Full name',
                        controller: _nameController,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Please enter full name'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        label: 'Address',
                        controller: _addressController,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Please enter address'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        label: 'City',
                        controller: _cityController,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Please enter city'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        label: 'State/Province/Region',
                        controller: _stateController,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Please enter state'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        label: 'Zip Code (Postal Code)',
                        controller: _zipController,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Please enter zip code'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        label: 'Country',
                        controller: _countryController,
                        isSelector: true,
                        onTap: _showCountryPicker,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Please select country'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Use as default shipping address',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textBlack,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: _isDefault,
                        activeThumbColor: AppColors.successGreen,
                        onChanged: (value) {
                          setState(() {
                            _isDefault = value;
                          });
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'SAVE ADDRESS',
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
    );
  }
}
