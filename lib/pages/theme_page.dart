import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../theme_scope.dart';

/// 主题选择页：5 套主题卡片 + 颜色预览 + 当前选中
class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = ThemeScope.of(context);
    final c = scope.colors;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        foregroundColor: c.text,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        title: Text(
          '主题',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: c.text),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            '选择你的扫雷配色',
            style: TextStyle(fontSize: 13, color: c.muted, letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < AppThemes.all.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ThemeCard(
                index: i,
                active: scope.index == i,
                onSelect: () {
                  scope.setTheme(i);
                  Navigator.of(context).pop();
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.index, required this.active, required this.onSelect});

  final int index;
  final bool active;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.all[index];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active ? t.accent : t.line,
              width: active ? 2.0 : 1.0,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: t.accent.withValues(alpha: 0.30),
                      blurRadius: 22,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // 颜色预览条（5 段代表主题主要颜色）
              _ColorBar(t),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: t.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _particleName(t.particle),
                      style: TextStyle(fontSize: 12, color: t.muted),
                    ),
                  ],
                ),
              ),
              // 选中态标记
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: active
                    ? Icon(Icons.check_circle_rounded, color: t.accent, size: 26, key: const ValueKey('on'))
                    : Icon(Icons.radio_button_unchecked_rounded, color: t.line, size: 22, key: const ValueKey('off')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _particleName(ParticleType p) {
    switch (p) {
      case ParticleType.snowflake:
        return '背景飘落：雪花';
      case ParticleType.leaf:
        return '背景飘落：落叶';
      case ParticleType.maple:
        return '背景飘落：枫叶';
      case ParticleType.cherry:
        return '背景飘落：樱花';
      case ParticleType.flower:
        return '背景飘落：小花';
    }
  }
}

class _ColorBar extends StatelessWidget {
  const _ColorBar(this.t);
  final ThemeColors t;

  @override
  Widget build(BuildContext context) {
    final colors = [t.bg, t.surfaceAlt, t.accent, t.accent2, t.text];
    return SizedBox(
      width: 58,
      height: 58,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            for (var i = 0; i < colors.length; i++)
              Expanded(child: Container(color: colors[i])),
          ],
        ),
      ),
    );
  }
}
