import 'package:flutter/material.dart';

import 'app_theme.dart';

/// 主题状态容器：持有当前主题索引，并通过 InheritedWidget 广播给整棵组件树
class ThemeScope extends StatefulWidget {
  const ThemeScope({super.key, required this.child});

  final Widget child;

  static ThemeScopeState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_ThemeInherit>();
    assert(scope != null, 'ThemeScope not found');
    return scope!.state;
  }

  @override
  State<ThemeScope> createState() => ThemeScopeState();
}

class ThemeScopeState extends State<ThemeScope> {
  int _index = 0;

  int get index => _index;
  ThemeColors get colors => AppThemes.all[_index];

  void setTheme(int i) {
    if (i < 0 || i >= AppThemes.all.length) return;
    if (i == _index) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return _ThemeInherit(
      state: this,
      index: _index,
      child: widget.child,
    );
  }
}

class _ThemeInherit extends InheritedWidget {
  const _ThemeInherit({
    required this.state,
    required this.index,
    required super.child,
  });

  final ThemeScopeState state;

  /// 必须是不可变快照，不能通过 state.index 读取（那样新旧值永远相同）
  final int index;

  @override
  bool updateShouldNotify(covariant _ThemeInherit oldWidget) =>
      oldWidget.index != index;
}
