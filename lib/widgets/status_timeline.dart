import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'ui_extensions.dart';

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.incident});
  final Incident incident;

  @override
  Widget build(BuildContext context) {
    const steps = IncidentStatus.values;
    final current = incident.status.index;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            child: _Step(
              status: steps[i],
              time: incident.timeOf(steps[i]),
              isFirst: i == 0,
              isLast: i == steps.length - 1,
              leftActive: i <= current,
              rightActive: i + 1 <= current,
              isCurrent: i == current,
              reached: i <= current,
            ),
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.status,
    required this.time,
    required this.isFirst,
    required this.isLast,
    required this.leftActive,
    required this.rightActive,
    required this.isCurrent,
    required this.reached,
  });

  final IncidentStatus status;
  final DateTime? time;
  final bool isFirst;
  final bool isLast;
  final bool leftActive;
  final bool rightActive;
  final bool isCurrent;
  final bool reached;

  @override
  Widget build(BuildContext context) {
    Widget line(bool visible, bool active) => Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: !visible
                  ? Colors.transparent
                  : (active ? status.color : AppColors.border),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );

    return Column(
      children: [
        Row(
          children: [
            line(!isFirst, leftActive),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: reached ? status.color : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: reached ? status.color : AppColors.border,
                  width: 2,
                ),
                boxShadow: isCurrent ? AppShadows.glow(status.color) : null,
              ),
              child: Icon(
                status.icon,
                size: 18,
                color: reached ? Colors.white : AppColors.muted,
              ),
            ),
            line(!isLast, rightActive),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          status.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: reached ? AppColors.ink : AppColors.muted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time == null ? 'Pending' : shortDate(time!),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}
