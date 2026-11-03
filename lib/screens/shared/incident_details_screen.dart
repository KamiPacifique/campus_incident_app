import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/gradient_header.dart';
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
    final category = incident.category;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            backgroundColor: category.color,
            foregroundColor: Colors.white,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: const Padding(
              padding: EdgeInsets.all(8),
              child: _CircleAction(child: BackButton(color: Colors.white)),
            ),
            actions: [
              if (canWithdraw)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CircleAction(
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded,
                          color: Colors.white),
                      onSelected: (_) => _confirmWithdraw(context, incident),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'withdraw',
                          child: Row(children: [
                            Icon(Icons.delete_outline_rounded,
                                color: AppColors.danger),
                            SizedBox(width: 10),
                            Text('Withdraw report'),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _HeaderImage(incident: incident),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverList.list(
              children: [
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _CategoryPill(category: category),
                          const Spacer(),
                          StatusChip(status: incident.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(incident.title,
                          style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                              color: AppColors.ink)),
                      const SizedBox(height: 14),
                      _MetaRow(
                          icon: Icons.location_on_rounded,
                          text: incident.location),
                      const SizedBox(height: 8),
                      _MetaRow(
                          icon: Icons.calendar_today_rounded,
                          text: 'Submitted ${fullDate(incident.createdAt)}'),
                      const SizedBox(height: 8),
                      _MetaRow(
                          icon: Icons.person_rounded,
                          text: 'Reported by ${incident.reporterName}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Card(
                  title: 'Status timeline',
                  icon: Icons.timeline_rounded,
                  child: StatusTimeline(incident: incident),
                ),
                if (auth.isStaff) ...[
                  const SizedBox(height: 16),
                  _StaffStatusPanel(incident: incident),
                ],
                const SizedBox(height: 16),
                _Card(
                  title: 'Description',
                  icon: Icons.notes_rounded,
                  child: Text(incident.description,
                      style: const TextStyle(
                          fontSize: 15, height: 1.55, color: AppColors.ink)),
                ),
              ],
            ),
          ),
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
        icon: const Icon(Icons.delete_outline_rounded,
            color: AppColors.danger, size: 32),
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
      messenger
          .showSnackBar(const SnackBar(content: Text('Report withdrawn.')));
    } else {
      messenger.showSnackBar(SnackBar(
          content: Text(provider.actionError ?? 'Could not withdraw report.')));
    }
  }
}

/// Photo if one was attached (tap to view full screen), otherwise a
/// category-coloured gradient with the category icon.
class _HeaderImage extends StatelessWidget {
  const _HeaderImage({required this.incident});
  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final category = incident.category;
    final url = incident.imageUrl;

    if (url == null || url.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              category.color,
              Color.lerp(category.color, Colors.black, 0.35)!
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: DecorativeBubbles(opacity: 0.1)),
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(category.icon, color: Colors.white, size: 48),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _PhotoViewer(incident: incident),
      )),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'incident-photo-${incident.id}',
            child: IncidentImage(
              path: url,
              fallbackIcon: category.icon,
              color: category.color,
              radius: 0,
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0x99000000),
                  Colors.transparent,
                  Color(0x66000000)
                ],
                stops: [0, 0.45, 1],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.zoom_out_map_rounded,
                      color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text('Tap to view',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  const _PhotoViewer({required this.incident});
  final Incident incident;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(incident.title,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: InteractiveViewer(
        maxScale: 4,
        child: Center(
          child: Hero(
            tag: 'incident-photo-${incident.id}',
            child: IncidentImage(
              path: incident.imageUrl,
              fallbackIcon: incident.category.icon,
              radius: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
            color: Color(0x40000000), shape: BoxShape.circle),
        child: child,
      );
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.category});
  final IncidentCategory category;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: category.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: 14, color: category.color),
            const SizedBox(width: 5),
            Text(category.label,
                style: TextStyle(
                    color: category.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.title, this.icon});
  final Widget child;
  final String? title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            _Heading(title!, icon: icon),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text, {this.icon});
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink)),
          ),
        ],
      );
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: AppColors.muted),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style:
                      const TextStyle(fontSize: 13.5, color: AppColors.ink))),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _Heading('Update status',
                    icon: Icons.admin_panel_settings_rounded),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('STAFF',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (provider.actionError != null) ...[
            ErrorBanner(message: provider.actionError!),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              for (final s in IncidentStatus.values) ...[
                if (s.index > 0) const SizedBox(width: 8),
                Expanded(
                  child: _StatusOption(
                    status: s,
                    selected: _selected == s,
                    onTap: _saving ? null : () => setState(() => _selected = s),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Update status',
            icon: Icons.check_rounded,
            isLoading: _saving,
            onPressed: changed ? _save : null,
          ),
        ],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  final IncidentStatus status;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: status.label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? status.color : status.background,
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected ? AppShadows.glow(status.color) : null,
          ),
          child: Column(
            children: [
              Icon(status.icon,
                  color: selected ? Colors.white : status.color, size: 22),
              const SizedBox(height: 6),
              Text(
                status.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : status.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
