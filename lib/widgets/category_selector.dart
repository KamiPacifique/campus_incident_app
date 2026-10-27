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
    final fg = isSelected ? Colors.white : AppColors.muted;
    return Semantics(
      button: true,
      selected: isSelected,
      label: category.label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border),
          ),
          child: Column(
            children: [
              Icon(category.icon, color: fg, size: 24),
              const SizedBox(height: 6),
              Text(
                category.label,
                style: TextStyle(
                    color: fg, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
