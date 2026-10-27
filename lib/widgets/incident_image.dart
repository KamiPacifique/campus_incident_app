import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shows a report photo from a network URL (Firebase Storage) or a local
/// file path, with a tidy placeholder when there is no image.
class IncidentImage extends StatelessWidget {
  const IncidentImage({
    super.key,
    required this.path,
    required this.fallbackIcon,
    this.width,
    this.height,
    this.radius = 12,
  });

  final String? path;
  final IconData fallbackIcon;
  final double? width;
  final double? height;
  final double radius;

  Widget _placeholder() => Container(
        color: AppColors.primarySoft,
        alignment: Alignment.center,
        child: Icon(fallbackIcon, color: AppColors.primary, size: 28),
      );

  @override
  Widget build(BuildContext context) {
    final p = path;
    Widget child;
    if (p == null || p.isEmpty) {
      child = _placeholder();
    } else if (p.startsWith('http')) {
      child = Image.network(
        p,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (context, widget, progress) =>
            progress == null ? widget : _placeholder(),
      );
    } else {
      child = Image.file(
        File(p),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}
