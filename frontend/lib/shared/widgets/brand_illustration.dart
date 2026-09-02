import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/app_colors.dart';

/// Où l'illustration de marque est utilisée — chaque variante choisit une
/// composition de couches différente (voir [_layersFor]).
enum BrandIllustrationVariant { splash, hero, emptyState, logo }

/// Illustration vectorielle "maison" — campus stylisé, pile de livres,
/// toque de diplômé et particules orbitales — entièrement dessinée en code
/// (CustomPainter) dans la palette verte/or de la marque. Aucune photo,
/// aucun asset externe : ça scale et s'anime nativement à toutes les tailles.
///
/// Composée de plusieurs couches indépendantes plutôt qu'un seul painter
/// monolithique, pour pouvoir les faire apparaître en cascade (splash) tout
/// en gardant une seule couche en boucle "respirante" (orbite) — jamais
/// toute l'illustration qui boucle, ce qui distrairait.
class BrandIllustration extends StatelessWidget {
  const BrandIllustration({
    super.key,
    required this.variant,
    this.size = 240,
    this.animated = true,
  });

  final BrandIllustrationVariant variant;
  final double size;
  final bool animated;

  bool get _staggerEntrance => variant == BrandIllustrationVariant.splash;

  @override
  Widget build(BuildContext context) {
    final layers = _layersFor(variant, size);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final entry in layers.indexed)
            if (animated && _staggerEntrance)
              entry.$2
                  .animate(delay: (entry.$1 * 160).ms)
                  .fadeIn(duration: 420.ms, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(0.82, 0.82),
                    curve: Curves.easeOutBack,
                    duration: 420.ms,
                  )
            else
              entry.$2,
        ],
      ),
    );
  }

  List<Widget> _layersFor(BrandIllustrationVariant variant, double size) {
    switch (variant) {
      case BrandIllustrationVariant.splash:
        return [
          _GlowLayer(size: size),
          _CampusLayer(size: size),
          _OrbitLayer(size: size, animated: animated),
          _BookStackLayer(size: size),
          _CapLayer(size: size),
          _SparkleLayer(size: size),
        ];
      case BrandIllustrationVariant.hero:
        return [
          _GlowLayer(size: size),
          _CampusLayer(size: size),
          _OrbitLayer(size: size, animated: animated),
          _CapLayer(size: size),
          _SparkleLayer(size: size),
        ];
      case BrandIllustrationVariant.emptyState:
        return [_BookStackLayer(size: size), _CapLayer(size: size)];
      case BrandIllustrationVariant.logo:
        return [_CampusLayer(size: size), _CapLayer(size: size)];
    }
  }
}

class _GlowLayer extends StatelessWidget {
  const _GlowLayer({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.16),
            AppColors.primaryLight.withValues(alpha: 0.06),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

class _CampusLayer extends StatelessWidget {
  const _CampusLayer({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CampusPainter()),
    );
  }
}

class _CampusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final baseY = size.height * 0.72;
    final buildings = <_Building>[
      _Building(size.width * 0.18, baseY, size.width * 0.14, size.height * 0.20),
      _Building(size.width * 0.34, baseY, size.width * 0.18, size.height * 0.30, pediment: true),
      _Building(size.width * 0.56, baseY, size.width * 0.14, size.height * 0.16),
    ];

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: AppColors.primaryGradient,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    for (final b in buildings) {
      final rect = Rect.fromLTWH(b.x, b.y - b.height, b.width, b.height);
      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(rrect, fill);

      if (b.pediment) {
        final peak = Offset(b.x + b.width / 2, b.y - b.height - size.height * 0.06);
        final path = Path()
          ..moveTo(b.x - 2, b.y - b.height)
          ..lineTo(peak.dx, peak.dy)
          ..lineTo(b.x + b.width + 2, b.y - b.height)
          ..close();
        canvas.drawPath(path, fill);
      }

      // fenêtres — petits carrés dorés
      final windowPaint = Paint()..color = AppColors.accent.withValues(alpha: 0.85);
      const cols = 2;
      final rows = (b.height / (size.height * 0.06)).floor().clamp(1, 4);
      final wSize = b.width * 0.14;
      for (var r = 0; r < rows; r++) {
        for (var c = 0; c < cols; c++) {
          final wx = b.x + b.width * (0.22 + c * 0.42);
          final wy = b.y - b.height + b.height * 0.22 + r * (b.height * 0.24);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(wx, wy, wSize, wSize),
              const Radius.circular(1.5),
            ),
            windowPaint,
          );
        }
      }
    }

    // sol
    final groundPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.25);
    canvas.drawRect(
      Rect.fromLTWH(0, baseY, size.width, 2),
      groundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Building {
  _Building(this.x, this.y, this.width, this.height, {this.pediment = false});
  final double x;
  final double y;
  final double width;
  final double height;
  final bool pediment;
}

class _BookStackLayer extends StatelessWidget {
  const _BookStackLayer({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.5, 0.68),
      child: SizedBox(
        width: size * 0.42,
        height: size * 0.22,
        child: CustomPaint(painter: _BookStackPainter()),
      ),
    );
  }
}

class _BookStackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final books = <(Color, double)>[
      (AppColors.primaryLight, -0.06),
      (AppColors.accent, 0.03),
      (Colors.white, -0.02),
    ];
    final h = size.height / books.length;
    for (var i = 0; i < books.length; i++) {
      final (color, tilt) = books[i];
      final y = size.height - (i + 1) * h;
      canvas.save();
      canvas.translate(size.width / 2, y + h / 2);
      canvas.rotate(tilt);
      final rect = Rect.fromCenter(center: Offset.zero, width: size.width, height: h * 0.82);
      final paint = Paint()..color = color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        paint,
      );
      if (color != Colors.white) {
        final spine = Paint()..color = Colors.white.withValues(alpha: 0.35);
        canvas.drawRect(
          Rect.fromLTWH(rect.left + 6, rect.top, 2.5, rect.height),
          spine,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CapLayer extends StatelessWidget {
  const _CapLayer({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(-0.15, -0.55),
      child: SizedBox(
        width: size * 0.34,
        height: size * 0.24,
        child: CustomPaint(painter: _CapPainter()),
      ),
    );
  }
}

class _CapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..shader = const LinearGradient(colors: AppColors.accentGradient)
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // base du couvre-chef
    final baseRect = Rect.fromLTWH(
      size.width * 0.28,
      size.height * 0.44,
      size.width * 0.44,
      size.height * 0.22,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect, const Radius.circular(3)),
      fill,
    );

    // plateau en losange
    final center = Offset(size.width * 0.5, size.height * 0.38);
    final diamond = Path()
      ..moveTo(center.dx, center.dy - size.height * 0.28)
      ..lineTo(center.dx + size.width * 0.5, center.dy)
      ..lineTo(center.dx, center.dy + size.height * 0.28)
      ..lineTo(center.dx - size.width * 0.5, center.dy)
      ..close();
    canvas.drawPath(diamond, fill);

    // cordon + pompon
    final cordPaint = Paint()
      ..color = AppColors.primaryLight
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final cordStart = Offset(center.dx, center.dy);
    final cordEnd = Offset(center.dx + size.width * 0.14, size.height * 0.86);
    final cordPath = Path()
      ..moveTo(cordStart.dx, cordStart.dy)
      ..quadraticBezierTo(
        cordEnd.dx + 6,
        (cordStart.dy + cordEnd.dy) / 2,
        cordEnd.dx,
        cordEnd.dy,
      );
    canvas.drawPath(cordPath, cordPaint);
    canvas.drawCircle(
      cordEnd,
      size.width * 0.045,
      Paint()..color = AppColors.primaryLight,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrbitLayer extends StatelessWidget {
  const _OrbitLayer({required this.size, required this.animated});
  final double size;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _OrbitPainter()),
    );
    if (!animated) return child;
    return child
        .animate(onPlay: (controller) => controller.repeat())
        .rotate(duration: 9.seconds, curve: Curves.linear);
  }
}

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(
      center: center,
      width: size.width * 0.86,
      height: size.height * 0.7,
    );

    final ringPaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    // anneau en pointillés
    const dashCount = 28;
    for (var i = 0; i < dashCount; i++) {
      if (i.isOdd) continue;
      final startAngle = (i / dashCount) * 2 * math.pi;
      final endAngle = ((i + 1) / dashCount) * 2 * math.pi;
      canvas.drawArc(rect, startAngle, endAngle - startAngle, false, ringPaint);
    }

    final dotPositions = [0.0, math.pi * 0.9, math.pi * 1.5];
    final dotColors = [AppColors.accent, AppColors.primary, AppColors.accentDark];
    for (var i = 0; i < dotPositions.length; i++) {
      final angle = dotPositions[i];
      final dx = center.dx + (rect.width / 2) * math.cos(angle);
      final dy = center.dy + (rect.height / 2) * math.sin(angle);
      canvas.drawCircle(
        Offset(dx, dy),
        size.width * 0.02 + (i == 0 ? 1.2 : 0),
        Paint()..color = dotColors[i],
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SparkleLayer extends StatelessWidget {
  const _SparkleLayer({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SparklePainter()),
    );
  }
}

class _SparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sparkles = [
      (Offset(size.width * 0.14, size.height * 0.2), size.width * 0.03, 0.9),
      (Offset(size.width * 0.86, size.height * 0.3), size.width * 0.025, 0.6),
      (Offset(size.width * 0.8, size.height * 0.6), size.width * 0.018, 0.5),
      (Offset(size.width * 0.1, size.height * 0.55), size.width * 0.02, 0.4),
    ];

    for (final (center, radius, alpha) in sparkles) {
      final paint = Paint()..color = AppColors.accent.withValues(alpha: alpha);
      canvas.drawPath(_starPath(center, radius), paint);
    }
  }

  Path _starPath(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final angle = (i / 4) * 2 * math.pi;
      final outer = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      final innerAngle = angle + math.pi / 4;
      final inner = center + Offset(math.cos(innerAngle), math.sin(innerAngle)) * (radius * 0.35);
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
