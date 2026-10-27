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

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _picker = ImagePicker();

  IncidentCategory _category = IncidentCategory.facilities;
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
        content: Text('Could not open the photo picker. Check app permissions.'),
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
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
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
                value: _location,
                isExpanded: true,
                validator: Validators.location,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_on_outlined),
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
            borderRadius: BorderRadius.circular(14),
            child: Image.file(File(path!),
                height: 180, width: double.infinity, fit: BoxFit.cover),
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
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          color: Colors.white,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                color: AppColors.primary, size: 30),
            SizedBox(height: 6),
            Text('Tap to add photos',
                style: TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
