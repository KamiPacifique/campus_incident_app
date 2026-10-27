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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onChanged: provider.setQuery,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search reports',
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CategoryFilterButton(provider: provider),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _StatusChoice(
                label: 'All',
                selected: provider.statusFilter == null,
                onTap: () => provider.setStatusFilter(null),
              ),
              for (final s in IncidentStatus.values)
                _StatusChoice(
                  label: s.label,
                  selected: provider.statusFilter == s,
                  onTap: () => provider.setStatusFilter(s),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
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
        icon: Icons.description_outlined,
        title: widget.emptyTitle,
        message: widget.emptyMessage,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: widget.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
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
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.muted,
          fontWeight: FontWeight.w600,
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
              Icon(c.icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(c.label),
            ]),
          ),
      ],
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Icon(Icons.tune_rounded,
            color: active ? Colors.white : AppColors.muted),
      ),
    );
  }
}
