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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => IncidentDetailsScreen(incidentId: incident.id),
        )),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              IncidentImage(
                path: incident.imageUrl,
                fallbackIcon: incident.category.icon,
                width: 64,
                height: 64,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      incident.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.muted),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          showReporter
                              ? Icons.person_outline_rounded
                              : Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            showReporter
                                ? '${incident.reporterName} · ${timeAgo(incident.createdAt)}'
                                : timeAgo(incident.createdAt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.muted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(status: incident.status),
                  const SizedBox(height: 10),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.muted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
