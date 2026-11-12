import 'dart:async';

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../theme_scope.dart';
import 'game_page.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key, required this.mode});
  final GameMode mode;

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  late final AnimationController _rotateCtrl;
  late final AnimationController _breathCtrl;
  late final Animation<double> _breath;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _breath = Tween<double>(begin: 0.88, end: 1.08).animate(
      CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut),
    );

    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => GamePage(mode: widget.mode)),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rotateCtrl.dispose();
    _breathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context).colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _breath,
              child: RotationTransition(
                turns: _rotateCtrl,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.surface,
                    border: Border.all(color: c.line),
                    boxShadow: [
                      BoxShadow(
                        color: c.accent.withValues(alpha: 0.18),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.settings_rounded,
                    size: 64,
                    color: c.accent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              widget.mode.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: c.text,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '正在布置雷区…',
              style: TextStyle(fontSize: 13, color: c.muted),
            ),
            const SizedBox(height: 6),
            Text(
              widget.mode.desc,
              style: TextStyle(
                fontSize: 12,
                color: c.muted.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
