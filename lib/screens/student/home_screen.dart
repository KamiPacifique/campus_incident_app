import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/user_avatar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onReport, required this.onSeeAll});

  final VoidCallback onReport;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final incidents = context.watch<IncidentProvider>();
    final stats = incidents.myStats;
    final recent = incidents.myIncidents.take(3).toList();
    final firstName = user.name.split(' ').first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Hello, $firstName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ),
            UserAvatar(name: user.name),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Help make our campus safer. Report issues and track their resolution.',
          style: TextStyle(color: AppColors.muted, fontSize: 15, height: 1.4),
        ),
        const SizedBox(height: 20),
        _ReportBanner(onReport: onReport),
        const SizedBox(height: 24),
        const _SectionHeader(title: 'Report summary'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatTile(
                value: stats.total,
                label: 'My reports',
                icon: Icons.description_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                value: stats.inProgress,
                label: 'In progress',
                icon: Icons.schedule_rounded,
                color: AppColors.primary,
                background: const Color(0xFFEAF0FF),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                value: stats.resolved,
                label: 'Resolved',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                background: AppColors.successSoft,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                value: stats.submitted,
                label: 'Submitted',
                icon: Icons.error_rounded,
                color: AppColors.danger,
                background: AppColors.dangerSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: 'Recent reports', onSeeAll: onSeeAll),
        const SizedBox(height: 12),
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
            icon: Icons.campaign_outlined,
            title: 'No reports yet',
            message: 'Spotted something broken? Tap “Report an issue” to tell campus staff.',
          )
        else
          for (final incident in recent) ...[
            IncidentCard(incident: incident),
            const SizedBox(height: 10),
          ],
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
        Text(title,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink)),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B3DF5), Color(0xFF8E7BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'See an issue\non campus?',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.15),
          ),
          const SizedBox(height: 6),
          const Text(
            'Report it and help improve our learning environment.',
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onReport,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.add_rounded,
                          color: Colors.white, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Report an issue',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
