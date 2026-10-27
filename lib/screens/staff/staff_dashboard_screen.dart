import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/report_browser.dart';
import '../../widgets/stat_tile.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final incidents = context.watch<IncidentProvider>();
    final stats = incidents.allStats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text('Staff dashboard',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink)),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Text('Review reports and update their status.',
              style: TextStyle(color: AppColors.muted)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Row(
            children: [
              Expanded(child: StatTile(value: stats.total, label: 'All')),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  value: stats.submitted,
                  label: 'New',
                  color: AppColors.warning,
                  background: AppColors.warningSoft,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  value: stats.inProgress,
                  label: 'In progress',
                  background: const Color(0xFFEAF0FF),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  value: stats.resolved,
                  label: 'Resolved',
                  color: AppColors.success,
                  background: AppColors.successSoft,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReportBrowser(
            items: incidents.filteredAll,
            showReporter: true,
            emptyTitle: 'No reports to review',
            emptyMessage: 'New student reports will appear here.',
          ),
        ),
      ],
    );
  }
}
