import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/report_browser.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/ui_extensions.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final incidents = context.watch<IncidentProvider>();
    final stats = incidents.myStats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientHeader(
          title: 'My reports',
          subtitle: 'Track every issue you have reported.',
          bottom: StatRow(tiles: [
            StatTile(
              value: stats.total,
              label: 'Total',
              icon: Icons.description_rounded,
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
