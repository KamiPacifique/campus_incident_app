import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

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
              label: steps[i].label,
              time: incident.timeOf(steps[i]),
              isFirst: i == 0,
              isLast: i == steps.length - 1,
              leftActive: i <= current,
              rightActive: i + 1 <= current,
              isDone: i < current,
              isCurrent: i == current,
            ),
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.time,
    required this.isFirst,
    required this.isLast,
    required this.leftActive,
    required this.rightActive,
    required this.isDone,
    required this.isCurrent,
  });

  final String label;
  final DateTime? time;
  final bool isFirst;
  final bool isLast;
  final bool leftActive;
  final bool rightActive;
  final bool isDone;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    Widget line(bool visible, bool active) => Expanded(
          child: Container(
            height: 3,
            color: !visible
                ? Colors.transparent
                : (active ? AppColors.primary : AppColors.border),
          ),
        );

    final reached = isDone || isCurrent;
    return Column(
      children: [
        Row(
          children: [
            line(!isFirst, leftActive),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: reached ? AppColors.primary : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone ? Icons.check_rounded : Icons.circle,
                size: isDone ? 18 : 8,
                color: reached ? Colors.white : AppColors.muted,
              ),
            ),
            line(!isLast, rightActive),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: reached ? AppColors.ink : AppColors.muted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time == null ? '—' : shortDate(time!),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}
