import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/incident_image.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/status_timeline.dart';
import '../../widgets/ui_extensions.dart';

class IncidentDetailsScreen extends StatelessWidget {
  const IncidentDetailsScreen({super.key, required this.incidentId});
  final String incidentId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final auth = context.watch<AuthProvider>();
    final incident = provider.byId(incidentId);

    if (incident == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Incident details')),
        body: const EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Report not found',
          message: 'It may have been withdrawn or removed.',
        ),
      );
    }

    final isOwner = incident.reporterId == auth.user?.uid;
    final canWithdraw = isOwner && incident.status == IncidentStatus.submitted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident details'),
        actions: [
          if (canWithdraw)
            PopupMenuButton<String>(
              onSelected: (_) => _confirmWithdraw(context, incident),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'withdraw', child: Text('Withdraw report')),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IncidentImage(
                      path: incident.imageUrl,
                      fallbackIcon: incident.category.icon,
                      width: 84,
                      height: 84,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(incident.title,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink)),
                          const SizedBox(height: 2),
                          Text('${incident.category.label} · ${incident.location}',
                              style: const TextStyle(color: AppColors.muted)),
                          const SizedBox(height: 8),
                          StatusChip(status: incident.status),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _MetaRow(
                    icon: Icons.calendar_today_outlined,
                    text: 'Submitted on ${fullDate(incident.createdAt)}'),
                const SizedBox(height: 6),
                _MetaRow(
                    icon: Icons.person_outline_rounded,
                    text: 'Reported by ${incident.reporterName}'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _Heading('Status timeline'),
          const SizedBox(height: 12),
          StatusTimeline(incident: incident),
          if (auth.isStaff) ...[
            const SizedBox(height: 24),
            _StaffStatusPanel(incident: incident),
          ],
          const SizedBox(height: 24),
          const _Heading('Description'),
          const SizedBox(height: 8),
          Text(incident.description,
              style: const TextStyle(
                  fontSize: 15, height: 1.5, color: AppColors.ink)),
          if (incident.imageUrl != null) ...[
            const SizedBox(height: 24),
            const _Heading('Attached photo'),
            const SizedBox(height: 10),
            IncidentImage(
              path: incident.imageUrl,
              fallbackIcon: incident.category.icon,
              width: double.infinity,
              height: 220,
              radius: 16,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmWithdraw(BuildContext context, Incident incident) async {
    final provider = context.read<IncidentProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Withdraw this report?'),
        content: const Text(
            'Campus staff will no longer see it. You can only withdraw reports that are still Submitted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep report')),
          TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Withdraw')),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await provider.delete(incident.id);
    if (ok) {
      navigator.pop();
      messenger.showSnackBar(
          const SnackBar(content: Text('Report withdrawn.')));
    } else {
      messenger.showSnackBar(SnackBar(
          content: Text(provider.actionError ?? 'Could not withdraw report.')));
    }
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink));
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.muted))),
        ],
      );
}

/// Only rendered for staff accounts. Firestore Security Rules must also
/// enforce this once the backend is connected.
class _StaffStatusPanel extends StatefulWidget {
  const _StaffStatusPanel({required this.incident});
  final Incident incident;

  @override
  State<_StaffStatusPanel> createState() => _StaffStatusPanelState();
}

class _StaffStatusPanelState extends State<_StaffStatusPanel> {
  late IncidentStatus _selected = widget.incident.status;
  bool _saving = false;

  Future<void> _save() async {
    final provider = context.read<IncidentProvider>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    final ok = await provider.updateStatus(widget.incident.id, _selected);
    if (!mounted) return;
    setState(() => _saving = false);
    messenger.showSnackBar(SnackBar(
      content: Text(ok
          ? 'Status updated to ${_selected.label}.'
          : (provider.actionError ?? 'Could not update status.')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final changed = _selected != widget.incident.status;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.admin_panel_settings_outlined,
                  color: AppColors.primary),
              SizedBox(width: 8),
              Text('Staff: update status',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink)),
            ],
          ),
          const SizedBox(height: 12),
          if (provider.actionError != null) ...[
            ErrorBanner(message: provider.actionError!),
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 8,
            children: [
              for (final s in IncidentStatus.values)
                ChoiceChip(
                  label: Text(s.label),
                  selected: _selected == s,
                  showCheckmark: false,
                  selectedColor: s.color,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                      color: _selected == s ? Colors.white : AppColors.ink,
                      fontWeight: FontWeight.w600),
                  onSelected: _saving ? null : (_) => setState(() => _selected = s),
                ),
            ],
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Update status',
            isLoading: _saving,
            onPressed: changed ? _save : null,
          ),
        ],
      ),
    );
  }
}
