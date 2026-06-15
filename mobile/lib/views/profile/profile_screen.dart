import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../widgets/safe_network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _customer;
  int _orderCount = 0;
  int _addressCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final results = await Future.wait([
        ApiService.customer(),
        ApiService.orders(),
        ApiService.addresses(),
      ]);
      if (!mounted) return;
      setState(() {
        _customer = results[0] as Map<String, dynamic>;
        _orderCount = (results[1] as List).length;
        _addressCount = (results[2] as List).length;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstName = _customer?['firstName'] ?? 'Demo';
    final lastName = _customer?['lastName'] ?? 'Customer';
    final email = _customer?['email'] ?? 'demo@fashion.test';
    final fullName = '$firstName $lastName'.trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: AppColors.textBlack,
              size: 24,
            ),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Search tapped!')));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'My profile',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile Header Info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        ClipOval(
                          child: SafeNetworkImage(
                            url:
                                'assets/picture/main page/main3_menhoodies.webp',
                            width: 64,
                            height: 64,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBlack,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textBlack.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Menu Items List
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      _buildMenuItem(
                        title: 'My orders',
                        subtitle: 'Already have $_orderCount orders',
                        onTap: () {
                          Navigator.pushNamed(context, '/my_orders');
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      _buildMenuItem(
                        title: 'Shipping addresses',
                        subtitle: '$_addressCount addresses',
                        onTap: () {
                          Navigator.pushNamed(context, '/shipping_addresses');
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      _buildMenuItem(
                        title: 'Payment methods',
                        subtitle: 'Visa **34',
                        onTap: () {
                          Navigator.pushNamed(context, '/payment_methods');
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      _buildMenuItem(
                        title: 'Promocodes',
                        subtitle: 'You have special promocodes',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Promocodes tapped!')),
                          );
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      _buildMenuItem(
                        title: 'My reviews',
                        subtitle: 'Reviews for 4 items',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('My reviews tapped!')),
                          );
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      _buildMenuItem(
                        title: 'Settings',
                        subtitle: 'Notifications, password',
                        onTap: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
