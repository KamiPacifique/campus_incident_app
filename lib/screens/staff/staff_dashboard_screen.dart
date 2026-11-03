import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/report_browser.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/ui_extensions.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final incidents = context.watch<IncidentProvider>();
    final stats = incidents.allStats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientHeader(
          title: 'Staff dashboard',
          subtitle: 'Review reports and update their status.',
          trailing: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded,
                color: Colors.white),
          ),
          bottom: StatRow(tiles: [
            StatTile(
              value: stats.total,
              label: 'All',
              icon: Icons.inbox_rounded,
            ),
            StatTile(
              value: stats.submitted,
              label: 'New',
              icon: IncidentStatus.submitted.icon,
              color: AppColors.warning,
            ),
            StatTile(
              value: stats.inProgress,
              label: 'In progress',
              icon: IncidentStatus.inProgress.icon,
              color: AppColors.info,
            ),
            StatTile(
              value: stats.resolved,
              label: 'Resolved',
              icon: IncidentStatus.resolved.icon,
              color: AppColors.success,
            ),
          ]),
        ),
        const SizedBox(height: 18),
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
