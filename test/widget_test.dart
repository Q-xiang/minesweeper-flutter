import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:minesweeper_app/app_theme.dart';
import 'package:minesweeper_app/main.dart';
import 'package:minesweeper_app/pages/game_page.dart';
import 'package:minesweeper_app/theme_scope.dart';

Widget _gameApp() => const ThemeScope(
      child: MaterialApp(home: GamePage(mode: GameMode.easy)),
    );

/// 页面内有循环动画，不能用 pumpAndSettle，改用固定帧推进
Future<void> _pumpFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('首页显示三种模式', (WidgetTester tester) async {
    await tester.pumpWidget(const MinesweeperApp());
    await tester.pump();

    expect(find.text('扫雷'), findsOneWidget);
    expect(find.text('简单模式'), findsOneWidget);
    expect(find.text('中等模式'), findsOneWidget);
    expect(find.text('魔鬼模式'), findsOneWidget);
  });

  testWidgets('点击格子会翻开安全格', (WidgetTester tester) async {
    await tester.pumpWidget(_gameApp());
    await _pumpFrames(tester);

    expect(find.text('0 / 71'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('cell_4_4')));
    await _pumpFrames(tester);

    expect(find.text('0 / 71'), findsNothing);
  });

  testWidgets('长按格子会插旗', (WidgetTester tester) async {
    await tester.pumpWidget(_gameApp());
    await _pumpFrames(tester);

    expect(find.byIcon(Icons.flag_rounded), findsOneWidget);
    await tester.longPress(find.byKey(const ValueKey('cell_0_0')));
    await _pumpFrames(tester);

    expect(find.byIcon(Icons.flag_rounded), findsNWidgets(2));
  });

  testWidgets('切换主题后首页背景色与粒子一起改变', (WidgetTester tester) async {
    await tester.pumpWidget(const MinesweeperApp());
    await _pumpFrames(tester);

    Scaffold homeScaffold() =>
        tester.widget<Scaffold>(find.byType(Scaffold).first);

    expect(homeScaffold().backgroundColor, AppThemes.all[0].bg);

    await tester.tap(find.text('THEME'));
    await _pumpFrames(tester);
    expect(find.text('幽萤青'), findsOneWidget);

    await tester.tap(find.text('幽萤青'));
    await _pumpFrames(tester);
    await tester.pump(const Duration(milliseconds: 600));

    expect(homeScaffold().backgroundColor, AppThemes.all[1].bg);
  });
}
