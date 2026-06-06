import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';

class AvatarImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final IconData fallbackIcon;
  final double fallbackIconSize;
  final Color? borderColor;
  final double borderWidth;
  final Color backgroundColor;

  const AvatarImage({
    super.key,
    this.imageUrl,
    this.size = 40,
    this.fallbackIcon = Icons.person,
    this.fallbackIconSize = 20,
    this.borderColor,
    this.borderWidth = 0,
    this.backgroundColor = IkoTheme.surfaceContainerLowest,
  });

  bool get _hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  bool get _isNetworkImage {
    final url = imageUrl!.toLowerCase();
    return url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('blob:') ||
        url.startsWith('data:');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: borderWidth > 0
            ? Border.all(color: borderColor ?? IkoTheme.primary, width: borderWidth)
            : null,
      ),
      child: ClipOval(
        child: _hasImage ? _buildImage() : _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Icon(
      fallbackIcon,
      size: fallbackIconSize,
      color: IkoTheme.textSecondary,
    );
  }

  Widget _buildImage() {
    if (imageUrl!.startsWith('data:')) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }

    if (kIsWeb || _isNetworkImage) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }

    return Image.file(
      File(imageUrl!),
      fit: BoxFit.cover,
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => _buildFallback(),
    );
  }
}
