import 'package:flutter/material.dart';

/// 粒子花纹类型
enum ParticleType { snowflake, leaf, maple, cherry, flower }

/// 单个主题的全部颜色 + 粒子类型 + 名字
class ThemeColors {
  const ThemeColors({
    required this.name,
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.line,
    required this.accent,
    required this.accent2,
    required this.text,
    required this.muted,
    required this.danger,
    required this.success,
    required this.particle,
    required this.numberColors,
  });

  final String name;
  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color line;
  final Color accent;
  final Color accent2;
  final Color text;
  final Color muted;
  final Color danger;
  final Color success;
  final ParticleType particle;

  /// 数字 1~8 的颜色（index 1..8）
  final List<Color> numberColors;

  Color number(int n) => numberColors[n.clamp(0, 8)];
}

/// 5 套主题总表
class AppThemes {
  static const List<ThemeColors> all = [
    // 0 深紫 × 菀雾紫 × 晴霜白 —— 原主题，粒子：小花
    ThemeColors(
      name: '紫罗兰',
      bg: Color(0xFF1B1533),
      surface: Color(0xFF2A2147),
      surfaceAlt: Color(0xFF382B5E),
      line: Color(0xFF4D3F76),
      accent: Color(0xFF9B84C2),
      accent2: Color(0xFFC8B3E6),
      text: Color(0xFFF3F1F8),
      muted: Color(0xFFB4A6D6),
      danger: Color(0xFFC76B9B),
      success: Color(0xFF7FD1B1),
      particle: ParticleType.flower,
      numberColors: [
        Color(0xFFB4A6D6), // 0 未使用
        Color(0xFFB4A6D6), // 1
        Color(0xFFC8B3E6), // 2
        Color(0xFF9B84C2), // 3
        Color(0xFF7B6DA4), // 4
        Color(0xFFC76B9B), // 5
        Color(0xFF8FC8D3), // 6
        Color(0xFFE6B885), // 7
        Color(0xFFF3F1F8), // 8
      ],
    ),

    // 1 深海墨 × 幽萤青 —— 粒子：雪花
    ThemeColors(
      name: '幽萤青',
      bg: Color(0xFF1A2F44),
      surface: Color(0xFF223B54),
      surfaceAlt: Color(0xFF2C4B6B),
      line: Color(0xFF3D6380),
      accent: Color(0xFF62D2C2),
      accent2: Color(0xFF8EE8DA),
      text: Color(0xFFE8F4F2),
      muted: Color(0xFF9FB9B5),
      danger: Color(0xFFE88C6C),
      success: Color(0xFF62D2C2),
      particle: ParticleType.snowflake,
      numberColors: [
        Color(0xFF9FB9B5), // 0
        Color(0xFF9FB9B5), // 1
        Color(0xFF62D2C2), // 2
        Color(0xFF8EE8DA), // 3
        Color(0xFF4C9D92), // 4
        Color(0xFFE88C6C), // 5
        Color(0xFF6FA8FF), // 6
        Color(0xFFE6D085), // 7
        Color(0xFFE8F4F2), // 8
      ],
    ),

    // 2 砾岩棕 × 砂金橙 —— 粒子：落叶
    ThemeColors(
      name: '砂金橙',
      bg: Color(0xFF3D2E22),
      surface: Color(0xFF4A3A2C),
      surfaceAlt: Color(0xFF5A4736),
      line: Color(0xFF6B5540),
      accent: Color(0xFFE6A25C),
      accent2: Color(0xFFF2BE84),
      text: Color(0xFFF5ECE0),
      muted: Color(0xFFC4A788),
      danger: Color(0xFFD46A4A),
      success: Color(0xFF8DB87A),
      particle: ParticleType.leaf,
      numberColors: [
        Color(0xFFC4A788),
        Color(0xFFC4A788), // 1
        Color(0xFFE6A25C), // 2
        Color(0xFFF2BE84), // 3
        Color(0xFFB8823E), // 4
        Color(0xFFD46A4A), // 5
        Color(0xFF8DB87A), // 6
        Color(0xFFD4C09A), // 7
        Color(0xFFF5ECE0), // 8
      ],
    ),

    // 3 奶霜 × 酒红 × 深咖 —— 粒子：枫叶
    ThemeColors(
      name: '酒红霜',
      bg: Color(0xFF4A312C),
      surface: Color(0xFF5A3E37),
      surfaceAlt: Color(0xFF6B4B43),
      line: Color(0xFF7D5B52),
      accent: Color(0xFF8C3D4F),
      accent2: Color(0xFFB86577),
      text: Color(0xFFF3E8DA),
      muted: Color(0xFFC7A79C),
      danger: Color(0xFFC24A5A),
      success: Color(0xFFA8B89C),
      particle: ParticleType.maple,
      numberColors: [
        Color(0xFFC7A79C),
        Color(0xFFC7A79C), // 1
        Color(0xFFB86577), // 2
        Color(0xFF8C3D4F), // 3
        Color(0xFFE0B8AA), // 4
        Color(0xFFC24A5A), // 5
        Color(0xFFD4A870), // 6
        Color(0xFF7D5B52), // 7
        Color(0xFFF3E8DA), // 8
      ],
    ),

    // 4 裸粉 × 蜜桃 × 藏灰 —— 粒子：樱花
    ThemeColors(
      name: '蜜桃粉',
      bg: Color(0xFF2D2D42),
      surface: Color(0xFF3A3A52),
      surfaceAlt: Color(0xFF464665),
      line: Color(0xFF585877),
      accent: Color(0xFFF1A4D7),
      accent2: Color(0xFFF7C3E8),
      text: Color(0xFFFDF0F5),
      muted: Color(0xFFC8B5C8),
      danger: Color(0xFFE87C8D),
      success: Color(0xFFA8D8B8),
      particle: ParticleType.cherry,
      numberColors: [
        Color(0xFFC8B5C8),
        Color(0xFFC8B5C8), // 1
        Color(0xFFF1A4D7), // 2
        Color(0xFFF7C3E8), // 3
        Color(0xFFB87AB0), // 4
        Color(0xFFE87C8D), // 5
        Color(0xFF8FB8D8), // 6
        Color(0xFFE8C88D), // 7
        Color(0xFFFDF0F5), // 8
      ],
    ),
  ];
}

/// 各模式配置（主题无关，保留）
class GameMode {
  const GameMode({
    required this.name,
    required this.desc,
    required this.rows,
    required this.cols,
    required this.mines,
  });

  final String name;
  final String desc;
  final int rows;
  final int cols;
  final int mines;

  static const easy = GameMode(
    name: '简单模式',
    desc: '9 x 9 · 10 颗雷',
    rows: 9,
    cols: 9,
    mines: 10,
  );

  static const medium = GameMode(
    name: '中等模式',
    desc: '12 x 12 · 24 颗雷',
    rows: 12,
    cols: 12,
    mines: 24,
  );

  static const devil = GameMode(
    name: '魔鬼模式',
    desc: '16 x 16 · 48 颗雷',
    rows: 16,
    cols: 16,
    mines: 48,
  );

  static const List<GameMode> all = [easy, medium, devil];
}
