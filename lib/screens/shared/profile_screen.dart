import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/ui_extensions.dart';
import '../../widgets/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon:
            const Icon(Icons.logout_rounded, color: AppColors.danger, size: 30),
        title: const Text('Sign out?'),
        content:
            const Text('You will need to sign in again to see your reports.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Sign out')),
        ],
      ),
    );
    if (confirmed == true) await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final incidents = context.watch<IncidentProvider>();
    final stats = user.isStaff ? incidents.allStats : incidents.myStats;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        GradientHeader(
          title: user.name,
          subtitle: user.email,
          trailing: UserAvatar(name: user.name, size: 64),
          bottom: StatRow(tiles: [
            StatTile(
              value: stats.total,
              label: user.isStaff ? 'All reports' : 'Total reports',
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
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    _InfoTile(
                      icon: user.isStaff
                          ? Icons.badge_rounded
                          : Icons.school_rounded,
                      label: 'Role',
                      value: user.isStaff ? 'Campus staff' : 'Student',
                    ),
                    const Divider(height: 1, indent: 64),
                    _InfoTile(
                      icon: Icons.alternate_email_rounded,
                      label: 'Email',
                      value: user.email,
                    ),
                    const Divider(height: 1, indent: 64),
                    const _InfoTile(
                      icon: Icons.verified_user_rounded,
                      label: 'Account',
                      value: 'Verified ALU account',
                      valueColor: AppColors.success,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(
                      color: AppColors.danger.withValues(alpha: 0.4)),
                ),
                onPressed: () => _confirmSignOut(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = AppColors.ink,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 2),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: valueColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
