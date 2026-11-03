import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/ui_extensions.dart';
import '../../widgets/user_avatar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onReport,
    required this.onQuickReport,
    required this.onSeeAll,
  });

  final VoidCallback onReport;
  final ValueChanged<IncidentCategory> onQuickReport;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final incidents = context.watch<IncidentProvider>();
    final stats = incidents.myStats;
    final recent = incidents.myIncidents.take(3).toList();
    final firstName = user.name.split(' ').first;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        GradientHeader(
          title: '${greeting()}, $firstName',
          subtitle: 'Help keep our campus safe and running smoothly.',
          trailing: UserAvatar(name: user.name, size: 48),
          bottom: StatRow(tiles: [
            StatTile(
              value: stats.total,
              label: 'My reports',
              icon: Icons.description_rounded,
            ),
            StatTile(
              value: stats.submitted,
              label: 'Submitted',
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
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReportBanner(onReport: onReport),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Quick report'),
              const SizedBox(height: 12),
              _QuickCategories(onSelected: onQuickReport),
              const SizedBox(height: 20),
              _SectionHeader(title: 'Recent reports', onSeeAll: onSeeAll),
              const SizedBox(height: 8),
              if (incidents.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (incidents.loadError != null)
                ErrorBanner(
                    message: incidents.loadError!, onRetry: incidents.retry)
              else if (recent.isEmpty)
                const EmptyState(
                  icon: Icons.campaign_rounded,
                  title: 'No reports yet',
                  message:
                      'Spotted something broken? Tap “Report an issue” to tell campus staff.',
                )
              else
                for (final incident in recent) ...[
                  IncidentCard(incident: incident),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink)),
        ),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}

class _ReportBanner extends StatelessWidget {
  const _ReportBanner({required this.onReport});
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: AppGradients.accent,
        boxShadow: AppShadows.glow(AppColors.accent),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            const Positioned.fill(child: DecorativeBubbles(opacity: 0.12)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'See an issue\non campus?',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              height: 1.15),
                        ),
                      ),
                      Icon(Icons.campaign_rounded,
                          color: Colors.white, size: 52),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Report it in under a minute and track it until it is fixed.',
                    style: TextStyle(
                        color: Colors.white, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: onReport,
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.accent,
                              child: Icon(Icons.add_rounded,
                                  color: Colors.white, size: 20),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text('Report an issue',
                                  style: TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                            ),
                            Icon(Icons.arrow_forward_rounded,
                                color: AppColors.accent),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One-tap shortcuts that open the report form with a category preselected.
class _QuickCategories extends StatelessWidget {
  const _QuickCategories({required this.onSelected});
  final ValueChanged<IncidentCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: IncidentCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final c = IncidentCategory.values[i];
          return Semantics(
            button: true,
            label: 'Report ${c.label} issue',
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onSelected(c),
              child: SizedBox(
                width: 72,
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppShadows.card,
                      ),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: c.background, shape: BoxShape.circle),
                          child: Icon(c.icon, color: c.color, size: 22),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
