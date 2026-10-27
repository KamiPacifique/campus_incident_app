import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../theme/app_theme.dart';

extension IncidentCategoryUi on IncidentCategory {
  IconData get icon => switch (this) {
        IncidentCategory.facilities => Icons.apartment_rounded,
        IncidentCategory.water => Icons.water_drop_outlined,
        IncidentCategory.electricity => Icons.bolt_rounded,
        IncidentCategory.safety => Icons.shield_outlined,
        IncidentCategory.sanitation => Icons.delete_outline_rounded,
        IncidentCategory.furniture => Icons.chair_outlined,
      };
}

extension IncidentStatusUi on IncidentStatus {
  Color get color => switch (this) {
        IncidentStatus.submitted => AppColors.warning,
        IncidentStatus.inProgress => AppColors.primary,
        IncidentStatus.resolved => AppColors.success,
      };

  Color get background => switch (this) {
        IncidentStatus.submitted => AppColors.warningSoft,
        IncidentStatus.inProgress => AppColors.primarySoft,
        IncidentStatus.resolved => AppColors.successSoft,
      };
}
