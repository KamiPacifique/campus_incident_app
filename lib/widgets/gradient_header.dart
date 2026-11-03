import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Branded teal header used at the top of every main tab. It draws behind
/// the status bar, so the screens using it should not wrap it in a SafeArea.
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  /// Optional content under the title, e.g. a row of [StatTile]s.
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.vertical(bottom: Radius.circular(28));
    final top = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.hero,
          borderRadius: radius,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              const Positioned.fill(child: DecorativeBubbles()),
              Padding(
                padding: EdgeInsets.fromLTRB(20, top + 16, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  subtitle!,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.82),
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: 12),
                          trailing!,
                        ],
                      ],
                    ),
                    if (bottom != null) ...[
                      const SizedBox(height: 18),
                      bottom!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soft translucent circles that add depth to gradient surfaces.
class DecorativeBubbles extends StatelessWidget {
  const DecorativeBubbles({super.key, this.opacity = 0.07});
  final double opacity;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _BubblePainter(opacity));
}

class _BubblePainter extends CustomPainter {
  _BubblePainter(this.opacity);
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
    canvas.drawCircle(Offset(size.width * 0.92, size.height * 0.08),
        size.shortestSide * 0.55, paint);
    canvas.drawCircle(Offset(size.width * 0.08, size.height * 1.05),
        size.shortestSide * 0.35, paint);
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.5), 22, paint);
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.opacity != opacity;
}
