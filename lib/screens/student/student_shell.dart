import 'package:flutter/material.dart';

import '../../models/incident.dart';
import '../../theme/app_theme.dart';
import '../shared/profile_screen.dart';
import 'home_screen.dart';
import 'my_reports_screen.dart';
import 'report_form_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  void _openReport([IncidentCategory? category]) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => ReportFormScreen(initialCategory: category)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onReport: _openReport,
        onQuickReport: _openReport,
        onSeeAll: () => setState(() => _index = 1),
      ),
      const MyReportsScreen(),
      const ProfileScreen(),
    ];

    // Each tab draws its own gradient header behind the status bar.
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A0F1E2E),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  selected: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
                _NavItem(
                  icon: Icons.description_outlined,
                  activeIcon: Icons.description_rounded,
                  label: 'Reports',
                  selected: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Report an issue',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _openReport,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: AppGradients.accent,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppShadows.glow(AppColors.accent),
                            ),
                            child: const Icon(Icons.add_rounded,
                                color: Colors.white, size: 30),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  selected: _index == 2,
                  onTap: () => setState(() => _index = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.muted;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primarySoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child:
                    Icon(selected ? activeIcon : icon, color: color, size: 24),
              ),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight:
                          selected ? FontWeight.w800 : FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
