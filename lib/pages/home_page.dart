import 'dart:math';
import 'dart:math' as m;

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../theme_scope.dart';
import 'loading_page.dart';
import 'theme_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  void _start(GameMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LoadingPage(mode: mode)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context).colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgCtrl,
              builder: (context, _) {
                final c = ThemeScope.of(context).colors;
                return CustomPaint(
                  painter: _PatternPainter(_bgCtrl.value, c.particle, c),
                );
              },
            ),
          ),
          // 底部光晕（随主题 accent 变色）
          Positioned(
            left: -80,
            right: -80,
            bottom: -180,
            child: Container(
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    c.accent.withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BadgeRow(),
                  const SizedBox(height: 18),
                  Text(
                    '扫雷',
                    style: TextStyle(
                      fontSize: 44,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      color: c.text,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '踩雷之前，先把雷区算清楚',
                    style: TextStyle(fontSize: 14, color: c.muted),
                  ),
                  const Spacer(),
                  Text(
                    '选择难度',
                    style: TextStyle(
                      fontSize: 13,
                      color: c.muted,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < GameMode.all.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ModeCard(
                        mode: GameMode.all[i],
                        index: i,
                        onTap: () => _start(GameMode.all[i]),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app_outlined, size: 14, color: c.muted),
                      const SizedBox(width: 6),
                      Text(
                        '点击翻开 · 长按插旗',
                        style: TextStyle(
                          fontSize: 12,
                          color: c.muted.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// THEME 标签：可点击进入主题选择页
class _BadgeRow extends StatelessWidget {
  const _BadgeRow();

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context).colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ThemePage()),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.palette_rounded, size: 13, color: c.accent),
              const SizedBox(width: 6),
              Text(
                'THEME',
                style: TextStyle(
                  fontSize: 11,
                  color: c.muted,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, size: 14, color: c.muted.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.index,
    required this.onTap,
  });

  final GameMode mode;
  final int index;
  final VoidCallback onTap;

  static const _icons = [
    Icons.spa_rounded,
    Icons.bolt_rounded,
    Icons.local_fire_department_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context).colors;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + index * 120),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: child,
          ),
        );
      },
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: c.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _icons[index],
                    color: index == 2 ? c.accent : c.accent2,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mode.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: c.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mode.desc,
                        style: TextStyle(fontSize: 12, color: c.muted),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: c.muted, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 背景花纹：按主题绘制雪花 / 落叶 / 枫叶 / 樱花 / 小花
class _PatternPainter extends CustomPainter {
  _PatternPainter(this.t, this.type, this.colors);

  final double t;
  final ParticleType type;
  final ThemeColors colors;

  static final Map<ParticleType, List<_Particle>> _cache = {};

  List<_Particle> _getParticles() {
    return _cache.putIfAbsent(type, () {
      final random = Random(type.index * 7 + 3);
      final count = type == ParticleType.snowflake ? 48 : 34;
      return List.generate(count, (i) {
        return _Particle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          radius: 3 + random.nextDouble() * 6,
          speed: 0.28 + random.nextDouble() * 0.45,
          phase: random.nextDouble() * m.pi * 2,
          opacity: 0.06 + random.nextDouble() * 0.12,
        );
      });
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final list = _getParticles();
    for (final p in list) {
      final progress = (p.y + t * p.speed) % 1.0;
      final dy = progress * (size.height + 40) - 20;
      final dx =
          p.x * size.width + m.sin((t * 2 + p.phase) * m.pi) * 16;
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(t * m.pi * 2 * 0.3 + p.phase);
      switch (type) {
        case ParticleType.snowflake:
          _drawSnowflake(canvas, p);
        case ParticleType.leaf:
          _drawLeaf(canvas, p);
        case ParticleType.maple:
          _drawMaple(canvas, p);
        case ParticleType.cherry:
          _drawCherry(canvas, p);
        case ParticleType.flower:
          _drawFlower(canvas, p);
      }
      canvas.restore();
    }
  }

  // —— 雪花：六边 ——
  void _drawSnowflake(Canvas canvas, _Particle p) {
    final paint = Paint()
      ..color = colors.accent2.withValues(alpha: p.opacity * 1.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final r = p.radius;
    for (var i = 0; i < 6; i++) {
      canvas.save();
      canvas.rotate(i * m.pi / 3);
      canvas.drawLine(Offset(0, 0), Offset(0, -r * 1.4), paint);
      canvas.drawLine(
          Offset(0, -r * 0.6), Offset(r * 0.3, -r * 0.9), paint);
      canvas.drawLine(
          Offset(0, -r * 0.6), Offset(-r * 0.3, -r * 0.9), paint);
      canvas.restore();
    }
  }

  // —— 落叶：椭圆 + 叶脉 ——
  void _drawLeaf(Canvas canvas, _Particle p) {
    final fill = Paint()
      ..color = colors.accent.withValues(alpha: p.opacity * 1.6)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = colors.accent2.withValues(alpha: p.opacity * 2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final r = p.radius;
    final path = Path()
      ..moveTo(0, -r * 1.6)
      ..quadraticBezierTo(r * 0.9, -r * 0.4, 0, r * 1.6)
      ..quadraticBezierTo(-r * 0.9, -r * 0.4, 0, -r * 1.6);
    canvas.drawPath(path, fill);
    canvas.drawLine(Offset(0, -r * 1.4), Offset(0, r * 1.4), stroke);
  }

  // —— 枫叶：五裂 ——
  void _drawMaple(Canvas canvas, _Particle p) {
    final paint = Paint()
      ..color = colors.accent.withValues(alpha: p.opacity * 1.6)
      ..style = PaintingStyle.fill;
    final r = p.radius;
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final ang = -m.pi / 2 + i * m.pi * 2 / 5;
      final px = m.cos(ang) * r;
      final py = m.sin(ang) * r;
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        final midAng = ang - m.pi / 5;
        final cx = m.cos(midAng) * r * 0.35;
        final cy = m.sin(midAng) * r * 0.35;
        path.quadraticBezierTo(cx, cy, px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  // —— 樱花：五瓣圆润 + 中心小点点 ——
  void _drawCherry(Canvas canvas, _Particle p) {
    final fill = Paint()
      ..color = colors.accent.withValues(alpha: p.opacity * 1.6)
      ..style = PaintingStyle.fill;
    final center = Paint()
      ..color = colors.accent2.withValues(alpha: p.opacity * 1.8)
      ..style = PaintingStyle.fill;
    final r = p.radius;
    for (var i = 0; i < 5; i++) {
      canvas.save();
      canvas.rotate(i * m.pi * 2 / 5);
      canvas.drawCircle(Offset(0, -r * 0.7), r * 0.55, fill);
      canvas.restore();
    }
    canvas.drawCircle(Offset.zero, r * 0.25, center);
  }

  // —— 小花：五瓣 ——
  void _drawFlower(Canvas canvas, _Particle p) {
    final fill = Paint()
      ..color = colors.accent2.withValues(alpha: p.opacity * 1.6)
      ..style = PaintingStyle.fill;
    final center = Paint()
      ..color = colors.text.withValues(alpha: p.opacity * 1.8)
      ..style = PaintingStyle.fill;
    final r = p.radius;
    for (var i = 0; i < 5; i++) {
      canvas.save();
      canvas.rotate(i * m.pi * 2 / 5);
      canvas.drawCircle(Offset(0, -r * 0.8), r * 0.55, fill);
      canvas.restore();
    }
    canvas.drawCircle(Offset.zero, r * 0.28, center);
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.type != type ||
      oldDelegate.colors != colors;
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.opacity,
  });

  final double x;
  final double y;
  final double radius;
  final double speed;
  final double phase;
  final double opacity;
}
