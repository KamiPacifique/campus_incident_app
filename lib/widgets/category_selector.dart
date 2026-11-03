import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../theme/app_theme.dart';
import 'ui_extensions.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final IncidentCategory selected;
  final ValueChanged<IncidentCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    const gap = 10.0;
    return LayoutBuilder(builder: (context, constraints) {
      final width = (constraints.maxWidth - gap * 2) / 3;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final c in IncidentCategory.values)
            _CategoryTile(
              category: c,
              width: width,
              isSelected: c == selected,
              onTap: () => onChanged(c),
            ),
        ],
      );
    });
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.width,
    required this.isSelected,
    required this.onTap,
  });

  final IncidentCategory category;
  final double width;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    return Semantics(
      button: true,
      selected: isSelected,
      label: category.label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected ? color : AppColors.border, width: 1.2),
            boxShadow: isSelected ? AppShadows.glow(color) : null,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.22)
                      : category.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(category.icon,
                    color: isSelected ? Colors.white : color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                category.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.ink,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
