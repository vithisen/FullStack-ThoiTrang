import 'dart:io';

import 'package:flutter/material.dart';
import '../config/theme.dart';

class SafeNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const SafeNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    final cleanUrl = imageUrl?.trim();
    final child = cleanUrl == null || cleanUrl.isBlank
        ? _placeholder()
        : cleanUrl.startsWith('assets/')
        ? Image.asset(
            cleanUrl,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _placeholder(),
          )
        : cleanUrl.startsWith('file://') || cleanUrl.startsWith('/')
        ? Image.file(
            File(
              cleanUrl.startsWith('file://')
                  ? Uri.parse(cleanUrl).toFilePath()
                  : cleanUrl,
            ),
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _placeholder(),
          )
        : Image.network(
            cleanUrl,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _placeholder(),
          );

    if (borderRadius == null) {
      return child;
    }
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.borderGrey.withValues(alpha: 0.5),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.textGrey,
      ),
    );
  }
}

extension _BlankString on String {
  bool get isBlank => trim().isEmpty;
}
