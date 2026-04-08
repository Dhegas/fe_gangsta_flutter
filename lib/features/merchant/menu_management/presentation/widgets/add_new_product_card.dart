import 'dart:math' as math;

import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_radius.dart';
import 'package:fe_gangsta_flutter/design_system/tokens/app_spacing.dart';
import 'package:flutter/material.dart';

class AddNewProductCard extends StatelessWidget {
  const AddNewProductCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: CustomPaint(
        painter: _DashedOutlinePainter(
          color: const Color(0xFFB6C3D2).withValues(alpha: 0.75),
          radius: AppRadius.xl,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceNeutral,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE7EDF5),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.add_rounded,
                      color: Color(0xFF6A7E99),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    'Add New Product',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF5F7390),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    'Quickly upload new menu\nitems to your digital\ncatalog',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8FA0B7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedOutlinePainter extends CustomPainter {
  _DashedOutlinePainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    const dashWidth = 7.0;
    const dashSpace = 5.0;
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final currentDash = math.min(dashWidth, metric.length - distance);
        canvas.drawPath(
          metric.extractPath(distance, distance + currentDash),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedOutlinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
