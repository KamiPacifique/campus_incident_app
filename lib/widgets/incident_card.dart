import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../screens/shared/incident_details_screen.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'incident_image.dart';
import 'status_chip.dart';
import 'ui_extensions.dart';

class IncidentCard extends StatelessWidget {
  const IncidentCard({
    super.key,
    required this.incident,
    this.showReporter = false,
  });

  final Incident incident;
  final bool showReporter;

  @override
  Widget build(BuildContext context) {
    final category = incident.category;
    const muted = TextStyle(fontSize: 12.5, color: AppColors.muted);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => IncidentDetailsScreen(incidentId: incident.id),
          )),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IncidentImage(
                  path: incident.imageUrl,
                  fallbackIcon: category.icon,
                  color: category.color,
                  width: 72,
                  height: 72,
                  radius: 14,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(category.icon, size: 14, color: category.color),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${category.label} · ${incident.location}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          StatusChip(status: incident.status),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              showReporter
                                  ? '${incident.reporterName} · ${timeAgo(incident.createdAt)}'
                                  : timeAgo(incident.createdAt),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
