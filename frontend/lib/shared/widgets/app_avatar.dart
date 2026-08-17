import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String initials;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final List<Color>? gradientColors;
  final String? semanticLabel;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.imageBytes,
    required this.initials,
    this.radius = 18.0,
    this.backgroundColor,
    this.textColor,
    this.gradientColors,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final double size = radius * 2;
    
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: gradientColors == null ? (backgroundColor ?? AppColors.primaryBg) : null,
        gradient: gradientColors != null
            ? LinearGradient(
                colors: gradientColors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: imageBytes != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Image.memory(
                imageBytes!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildInitials(),
              ),
            )
          : imageUrl != null && imageUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: Image.network(
                    imageUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildInitials(),
                  ),
                )
              : _buildInitials(),
    );

    return Semantics(
      label: semanticLabel ?? "User avatar showing initials $initials",
      image: true,
      child: avatar,
    );
  }

  Widget _buildInitials() {
    return Text(
      initials.toUpperCase(),
      style: AppTypography.bodySemibold.copyWith(
        color: textColor ?? AppColors.primary,
        fontSize: radius * 0.75,
      ),
    );
  }
}
