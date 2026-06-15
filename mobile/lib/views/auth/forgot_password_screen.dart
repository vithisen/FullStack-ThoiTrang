import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController(
    text: "demo@fashion.test",
  );
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Forgot password',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                ),
              ),
              const SizedBox(height: 48),

              // Dòng giới thiệu mô tả
              const Text(
                'Please, enter your email address. You will receive a link to create a new password via email.',
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _errorText == null
                        ? Colors.transparent
                        : AppColors.errorRed,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: TextStyle(
                              color: _errorText == null
                                  ? AppColors.textGrey
                                  : AppColors.errorRed,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(
                              color: AppColors.textBlack,
                              fontSize: 14,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _errorText == null ? Icons.check : Icons.close,
                      color: _errorText == null
                          ? AppColors.successGreen
                          : AppColors.errorRed,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  _errorText ?? '',
                  style: const TextStyle(
                    color: AppColors.errorRed,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Nút SEND màu đỏ
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          final email = _emailController.text.trim();
                          if (!email.contains('@')) {
                            setState(() {
                              _errorText =
                                  'Not a valid email address. Should be your@email.com';
                            });
                            return;
                          }
                          setState(() {
                            _isSubmitting = true;
                            _errorText = null;
                          });
                          try {
                            await ApiService.forgotPassword(email);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password reset link sent!'),
                              ),
                            );
                          } catch (error) {
                            if (!mounted) return;
                            setState(() {
                              _errorText = 'Cannot send reset link';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Cannot send reset link: $error'),
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isSubmitting = false;
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primaryRed.withOpacity(0.5),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'SEND',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
