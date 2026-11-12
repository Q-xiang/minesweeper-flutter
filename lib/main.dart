import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/home_page.dart';
import 'theme_scope.dart';

void main() {
  runApp(const MinesweeperApp());
}

class MinesweeperApp extends StatelessWidget {
  const MinesweeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ThemeScope(child: _AppShell());
  }
}

/// 依赖 ThemeScope，主题切换时整体重建 MaterialApp（含 ThemeData）
class _AppShell extends StatelessWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context).colors;
    return MaterialApp(
      title: appFlavor == 'dev' ? '扫雷 Dev' : '扫雷',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: c.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: c.accent,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}
