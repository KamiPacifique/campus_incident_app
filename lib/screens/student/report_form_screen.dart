import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/category_selector.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/form_label.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/ui_extensions.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key, this.initialCategory});

  /// Preselected when opened from a "Quick report" shortcut.
  final IncidentCategory? initialCategory;

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _picker = ImagePicker();

  late IncidentCategory _category =
      widget.initialCategory ?? IncidentCategory.facilities;
  String? _location;
  String? _photoPath;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (file != null && mounted) setState(() => _photoPath = file.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('Could not open the photo picker. Check app permissions.'),
      ));
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const _SheetIcon(Icons.photo_camera_rounded),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const _SheetIcon(Icons.photo_library_rounded),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().user!;
    final provider = context.read<IncidentProvider>();
    final now = DateTime.now();

    final draft = Incident(
      id: '',
      title: _title.text.trim(),
      description: _description.text.trim(),
      category: _category,
      location: _location!,
      status: IncidentStatus.submitted,
      reporterId: user.uid,
      reporterName: user.name,
      createdAt: now,
      history: [StatusEvent(status: IncidentStatus.submitted, at: now)],
    );

    final ok = await provider.submit(draft, localImagePath: _photoPath);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Report submitted. You can track it under Reports.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Report an incident')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              if (provider.actionError != null) ...[
                ErrorBanner(message: provider.actionError!),
                const SizedBox(height: 16),
              ],
              const _PrivacyNote(),
              const SizedBox(height: 20),
              const FormLabel('Select a category'),
              CategorySelector(
                selected: _category,
                onChanged: (c) => setState(() => _category = c),
              ),
              const SizedBox(height: 20),
              const FormLabel('Title'),
              TextFormField(
                controller: _title,
                maxLength: 80,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: Validators.title,
                decoration: const InputDecoration(
                  hintText: 'Briefly describe the issue',
                  prefixIcon: Icon(Icons.title_rounded),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 20),
              const FormLabel('Description'),
              TextFormField(
                controller: _description,
                maxLines: 4,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                validator: Validators.description,
                decoration: const InputDecoration(
                  hintText:
                      'Provide more details: what happened, when, and the impact',
                ),
              ),
              const SizedBox(height: 20),
              const FormLabel('Location'),
              DropdownButtonFormField<String>(
                initialValue: _location,
                isExpanded: true,
                validator: Validators.location,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                decoration: InputDecoration(
                  prefixIcon:
                      Icon(Icons.location_on_rounded, color: _category.color),
                ),
                hint: const Text('Select location',
                    style: TextStyle(color: AppColors.muted)),
                items: [
                  for (final l in campusLocations)
                    DropdownMenuItem(value: l, child: Text(l)),
                ],
                onChanged: (v) => setState(() => _location = v),
              ),
              const SizedBox(height: 20),
              const FormLabel('Add a photo', hint: '(optional)'),
              _PhotoPicker(
                path: _photoPath,
                onTap: _showPhotoOptions,
                onRemove: () => setState(() => _photoPath = null),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Submit report',
                icon: Icons.send_rounded,
                color: AppColors.accent,
                onPressed: _submit,
                isLoading: provider.isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.path,
    required this.onTap,
    required this.onRemove,
  });

  final String? path;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (path != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(File(path!),
                height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onTap,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_horiz_rounded,
                          color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text('Change',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton.filled(
              tooltip: 'Remove photo',
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, color: Colors.white),
            ),
          ),
        ],
      );
    }
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35), width: 1.5),
          color: AppColors.primarySoft.withValues(alpha: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: AppShadows.card,
              ),
              child: const Icon(Icons.add_a_photo_rounded,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 10),
            const Text('Take or choose a photo',
                style: TextStyle(
                    color: AppColors.ink, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            const Text('A clear photo helps staff fix it faster',
                style: TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SheetIcon extends StatelessWidget {
  const _SheetIcon(this.icon);
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
            color: AppColors.primarySoft, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.primary, size: 20),
      );
}

/// Reminds students not to capture other people in photos or descriptions.
class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.privacy_tip_rounded, color: AppColors.primary, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your report goes straight to campus staff. Please avoid '
              'including other people\'s faces or personal details.',
              style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}
