import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/report_browser.dart';
import '../../widgets/stat_tile.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final incidents = context.watch<IncidentProvider>();
    final stats = incidents.myStats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text('My reports',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Row(
            children: [
              Expanded(child: StatTile(value: stats.total, label: 'Total')),
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
            items: incidents.filteredMine,
            emptyTitle: 'No reports yet',
            emptyMessage:
                'Reports you submit will appear here so you can track them.',
          ),
        ),
      ],
    );
  }
}
