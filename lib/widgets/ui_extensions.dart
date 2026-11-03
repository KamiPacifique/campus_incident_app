import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../theme/app_theme.dart';

extension IncidentCategoryUi on IncidentCategory {
  IconData get icon => switch (this) {
        IncidentCategory.facilities => Icons.apartment_rounded,
        IncidentCategory.water => Icons.water_drop_rounded,
        IncidentCategory.electricity => Icons.bolt_rounded,
        IncidentCategory.safety => Icons.shield_rounded,
        IncidentCategory.sanitation => Icons.cleaning_services_rounded,
        IncidentCategory.furniture => Icons.chair_rounded,
      };

  /// Each category has its own colour so reports are easy to scan.
  Color get color => switch (this) {
        IncidentCategory.facilities => const Color(0xFF6366F1),
        IncidentCategory.water => const Color(0xFF0EA5E9),
        IncidentCategory.electricity => const Color(0xFFF59E0B),
        IncidentCategory.safety => const Color(0xFFEF4444),
        IncidentCategory.sanitation => const Color(0xFF10B981),
        IncidentCategory.furniture => const Color(0xFFA16207),
      };

  Color get background => color.withValues(alpha: 0.12);
}

extension IncidentStatusUi on IncidentStatus {
  Color get color => switch (this) {
        IncidentStatus.submitted => AppColors.warning,
        IncidentStatus.inProgress => AppColors.info,
        IncidentStatus.resolved => AppColors.success,
      };

  Color get background => switch (this) {
        IncidentStatus.submitted => AppColors.warningSoft,
        IncidentStatus.inProgress => AppColors.infoSoft,
        IncidentStatus.resolved => AppColors.successSoft,
      };

  IconData get icon => switch (this) {
        IncidentStatus.submitted => Icons.outbox_rounded,
        IncidentStatus.inProgress => Icons.engineering_rounded,
        IncidentStatus.resolved => Icons.check_circle_rounded,
      };
}
