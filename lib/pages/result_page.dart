import 'dart:math';

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../theme_scope.dart';
import 'loading_page.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key, required this.mode, required this.win});
  final GameMode mode;
  final bool win;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with TickerProviderStateMixin {
  late final AnimationController _flowerCtrl;
  late final AnimationController _cloudCtrl;

  @override
  void initState() {
    super.initState();
    _flowerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _cloudCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _flowerCtrl.dispose();
    _cloudCtrl.dispose();
    super.dispose();
  }

  GameMode get _nextMode {
    if (widget.mode == GameMode.easy) return GameMode.medium;
    return GameMode.devil;
  }

  void _replay(GameMode mode) {
    Navigator.of(context).pushReplacement(
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
          Positioned.fill(child: _buildBackdrop(c)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  widget.win ? _buildSuccessFace(c) : _buildFailFace(c),
                  const SizedBox(height: 28),
                  Text(
                    widget.win ? '雷区清空' : '踩到雷了',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: c.text,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.win
                        ? '${widget.mode.name} · 所有安全格已翻开'
                        : '${widget.mode.name} · 雷区共 ${widget.mode.mines} 颗雷',
                    style: TextStyle(fontSize: 13, color: c.muted),
                  ),
                  const Spacer(flex: 3),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: () => _replay(
                        widget.win ? _nextMode : widget.mode,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: c.accent,
                        foregroundColor: c.bg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        widget.win ? '下一关' : '重来一局',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context)
                          .popUntil((route) => route.isFirst),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c.muted,
                        side: BorderSide(color: c.line),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('返回首页'),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessFace(ThemeColors c) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _flowerCtrl,
            builder: (context, _) {
              return Transform.rotate(
                angle: _flowerCtrl.value * pi * 2,
                child: CustomPaint(
                  size: const Size(220, 220),
                  painter: _FlowerRingPainter(c),
                ),
              );
            },
          ),
          Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c.surfaceAlt, c.surface],
              ),
              border: Border.all(color: c.line),
              boxShadow: [
                BoxShadow(
                  color: c.accent.withValues(alpha: 0.20),
                  blurRadius: 34,
                ),
              ],
            ),
            child: Icon(
              Icons.sentiment_very_satisfied_rounded,
              size: 62,
              color: c.accent2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailFace(ThemeColors c) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.surface,
              border: Border.all(color: c.line),
              boxShadow: [
                BoxShadow(
                  color: c.danger.withValues(alpha: 0.18),
                  blurRadius: 34,
                ),
              ],
            ),
            child: Icon(
              Icons.sentiment_very_dissatisfied_rounded,
              size: 62,
              color: c.danger,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackdrop(ThemeColors c) {
    if (widget.win) {
      return Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.35),
            radius: 1.1,
            colors: [c.accent.withValues(alpha: 0.12), c.bg],
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _cloudCtrl,
      builder: (context, _) {
        final t = _cloudCtrl.value;
        return Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 + t * 2, -1),
                    end: Alignment(1, 1 - t),
                    colors: [
                      c.surfaceAlt,
                      c.danger.withValues(alpha: 0.14),
                      c.surface,
                      c.accent.withValues(alpha: 0.10),
                    ],
                    stops: const [0, 0.38, 0.72, 1],
                  ),
                ),
              ),
            ),
            Positioned.fill(child: CustomPaint(painter: _CloudPainter(t, c))),
          ],
        );
      },
    );
  }
}

class _FlowerRingPainter extends CustomPainter {
  _FlowerRingPainter(this.c);
  final ThemeColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.42;
    final colors = [c.accent, c.accent2, c.line, c.success];
    for (var i = 0; i < 7; i++) {
      final angle = i * pi * 2 / 7;
      final pos = center + Offset(cos(angle), sin(angle)) * radius;
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 0.85);
      for (var p = 0; p < 5; p++) {
        final a = p * pi * 2 / 5 + angle;
        canvas.drawCircle(
          pos + Offset(cos(a), sin(a)) * 5,
          3.6,
          paint,
        );
      }
      canvas.drawCircle(
        pos,
        2.4,
        Paint()..color = c.text.withValues(alpha: 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FlowerRingPainter oldDelegate) =>
      oldDelegate.c != c;
}

class _CloudPainter extends CustomPainter {
  _CloudPainter(this.t, this.c);
  final double t;
  final ThemeColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = c.surfaceAlt.withValues(alpha: 0.75);
    final random = Random(3);
    for (var i = 0; i < 7; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = 30 + random.nextDouble() * size.height * 0.36;
      final drift = (t + i * 0.13) % 1.0;
      final x = (baseX + drift * size.width * 1.4) % (size.width + 160) - 80;
      final w = 60 + random.nextDouble() * 70;
      final h = w * 0.52;
      canvas.drawOval(Rect.fromCenter(center: Offset(x, baseY), width: w * 1.6, height: h), paint);
      canvas.drawOval(Rect.fromCenter(center: Offset(x + w * 0.4, baseY - h * 0.25), width: w, height: h), paint);
      canvas.drawOval(Rect.fromCenter(center: Offset(x - w * 0.45, baseY - h * 0.15), width: w * 0.8, height: h * 0.8), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.c != c;
}
