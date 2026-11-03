import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/incident_provider.dart';
import '../theme/app_theme.dart';
import 'empty_state.dart';
import 'error_banner.dart';
import 'incident_card.dart';
import 'ui_extensions.dart';

/// Search + status chips + category filter + list of reports.
/// Shared by the student "My Reports" tab and the staff dashboard.
class ReportBrowser extends StatefulWidget {
  const ReportBrowser({
    super.key,
    required this.items,
    this.showReporter = false,
    this.emptyTitle = 'No reports yet',
    this.emptyMessage = 'Reports you submit will show up here.',
  });

  final List<Incident> items;
  final bool showReporter;
  final String emptyTitle;
  final String emptyMessage;

  @override
  State<ReportBrowser> createState() => _ReportBrowserState();
}

class _ReportBrowserState extends State<ReportBrowser> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final category = provider.categoryFilter;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppShadows.card,
                  ),
                  child: TextField(
                    controller: _search,
                    onChanged: provider.setQuery,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search title, location…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _search.clear();
                                provider.setQuery('');
                              },
                            ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _CategoryFilterButton(provider: provider),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _StatusChoice(
                label: 'All',
                color: AppColors.primary,
                selected: provider.statusFilter == null,
                onTap: () => provider.setStatusFilter(null),
              ),
              for (final s in IncidentStatus.values)
                _StatusChoice(
                  label: s.label,
                  color: s.color,
                  icon: s.icon,
                  selected: provider.statusFilter == s,
                  onTap: () => provider.setStatusFilter(s),
                ),
            ],
          ),
        ),
        if (category != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InputChip(
                avatar: Icon(category.icon, color: category.color, size: 18),
                label: Text(category.label),
                labelStyle: TextStyle(
                    color: category.color, fontWeight: FontWeight.w700),
                backgroundColor: category.background,
                side: BorderSide.none,
                deleteIconColor: category.color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                onDeleted: () => provider.setCategoryFilter(null),
              ),
            ),
          ),
        const SizedBox(height: 14),
        Expanded(child: _buildBody(provider)),
      ],
    );
  }

  Widget _buildBody(IncidentProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.loadError != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.topCenter,
          child: ErrorBanner(
              message: provider.loadError!, onRetry: provider.retry),
        ),
      );
    }
    if (widget.items.isEmpty) {
      if (provider.hasActiveFilters) {
        return EmptyState(
          icon: Icons.search_off_rounded,
          title: 'No matching reports',
          message: 'Try a different search or clear your filters.',
          actionLabel: 'Clear filters',
          onAction: () {
            _search.clear();
            provider.clearFilters();
          },
        );
      }
      return EmptyState(
        icon: Icons.inbox_rounded,
        title: widget.emptyTitle,
        message: widget.emptyMessage,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: widget.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => IncidentCard(
        incident: widget.items[i],
        showReporter: widget.showReporter,
      ),
    );
  }
}

class _StatusChoice extends StatelessWidget {
  const _StatusChoice({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.ink;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: icon == null
            ? null
            : Icon(icon, size: 16, color: selected ? Colors.white : color),
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: color,
        backgroundColor: AppColors.surface,
        side: BorderSide(color: selected ? color : AppColors.border),
        labelStyle: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class _CategoryFilterButton extends StatelessWidget {
  const _CategoryFilterButton({required this.provider});
  final IncidentProvider provider;

  @override
  Widget build(BuildContext context) {
    final active = provider.categoryFilter != null;
    return PopupMenuButton<String>(
      tooltip: 'Filter by category',
      onSelected: (v) => provider.setCategoryFilter(
          v == 'all' ? null : IncidentCategory.values.byName(v)),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'all', child: Text('All categories')),
        for (final c in IncidentCategory.values)
          PopupMenuItem(
            value: c.name,
            child: Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration:
                    BoxDecoration(color: c.background, shape: BoxShape.circle),
                child: Icon(c.icon, size: 18, color: c.color),
              ),
              const SizedBox(width: 12),
              Text(c.label),
            ]),
          ),
      ],
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.card,
        ),
        child: Icon(Icons.tune_rounded,
            color: active ? Colors.white : AppColors.ink),
      ),
    );
  }
}
