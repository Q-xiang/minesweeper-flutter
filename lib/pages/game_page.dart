import 'dart:math';

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../game_logic.dart';
import '../theme_scope.dart';
import 'result_page.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.mode});
  final GameMode mode;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late final MinesweeperGame _game;
  late final AnimationController _flameCtrl;
  late final AnimationController _boardCtrl;
  late final AnimationController _boomCtrl;

  Offset? _pointer;
  bool _booming = false;

  @override
  void initState() {
    super.initState();
    _game = MinesweeperGame(
      rows: widget.mode.rows,
      cols: widget.mode.cols,
      mines: widget.mode.mines,
    );
    _flameCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    )..repeat(reverse: true);
    _boardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _boomCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  @override
  void dispose() {
    _flameCtrl.dispose();
    _boardCtrl.dispose();
    _boomCtrl.dispose();
    super.dispose();
  }

  void _onTap(int r, int c) {
    if (_game.isOver || _booming) return;
    final hitMine = _game.reveal(r, c);
    setState(() {});
    if (hitMine) { _explode(); return; }
    if (_game.isWin) _finish(true);
  }

  void _onLongPress(int r, int c) {
    if (_game.isOver || _booming) return;
    _game.toggleFlag(r, c);
    setState(() {});
  }

  void _useHint() {
    if (_game.isOver || _booming) return;
    final pos = _game.randomSafeCell();
    if (pos == null) return;
    final hitMine = _game.reveal(pos[0], pos[1]);
    setState(() {});
    if (hitMine) { _explode(); return; }
    if (_game.isWin) _finish(true);
  }

  Future<void> _explode() async {
    _game.revealAllMines();
    setState(() => _booming = true);
    await _boomCtrl.forward();
    if (!mounted) return;
    _finish(false);
  }

  void _finish(bool win) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultPage(mode: widget.mode, win: win),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context).colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.surfaceAlt, c.bg],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(c),
                  _buildStatus(c),
                  Expanded(child: _buildBoardArea(c)),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      '长按插旗 · 点火把可提示一格',
                      style: TextStyle(fontSize: 11, color: c.muted),
                    ),
                  ),
                ],
              ),
              if (_booming)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _boomCtrl,
                      builder: (context, _) => CustomPaint(
                        painter: _BoomPainter(_boomCtrl.value, c),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('取消'),
            style: TextButton.styleFrom(
              foregroundColor: c.muted,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
          const Spacer(),
          Text(
            widget.mode.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: c.text,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _useHint,
            icon: const Icon(Icons.local_fire_department_rounded, size: 18),
            label: const Text('提示'),
            style: TextButton.styleFrom(
              foregroundColor: c.accent,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(ThemeColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Row(
        children: [
          _StatChip(icon: Icons.flag_rounded, color: c.accent, label: '${_game.minesLeft}'),
          const SizedBox(width: 8),
          _StatChip(icon: Icons.grid_on_rounded, color: c.muted, label: '${_game.revealedCount} / ${_game.safeTotal}'),
          const Spacer(),
          Text(
            '${widget.mode.rows} x ${widget.mode.cols}',
            style: TextStyle(fontSize: 12, color: c.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardArea(ThemeColors c) {
    final rows = widget.mode.rows;
    final cols = widget.mode.cols;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth - 28;
        final maxH = constraints.maxHeight - 20;
        final size = min(maxW / cols, maxH / rows);
        final boardW = size * cols;
        final boardH = size * rows;

        return Center(
          child: AnimatedBuilder(
            animation: _boardCtrl,
            builder: (context, child) {
              final t = _boardCtrl.value;
              final glow = 0.08 + 0.06 * (0.5 + 0.5 * sin(t * pi * 2));
              return Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.line),
                  gradient: LinearGradient(
                    begin: Alignment(-1 + t, -1),
                    end: Alignment(1, 1 - t),
                    colors: [
                      c.surfaceAlt,
                      c.surface,
                      c.accent.withValues(alpha: glow),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: c.accent.withValues(alpha: glow * 0.9),
                      blurRadius: 26,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: Listener(
              onPointerDown: (e) => setState(() => _pointer = e.localPosition),
              onPointerMove: (e) => setState(() => _pointer = e.localPosition),
              child: SizedBox(
                width: boardW,
                height: boardH,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        for (var r = 0; r < rows; r++)
                          Row(
                            children: [
                              for (var cc = 0; cc < cols; cc++)
                                _CellTile(
                                  key: ValueKey('cell_${r}_$cc'),
                                  cell: _game.board[r][cc],
                                  size: size,
                                  colors: c,
                                  onTap: () => _onTap(r, cc),
                                  onLongPress: () => _onLongPress(r, cc),
                                ),
                            ],
                          ),
                      ],
                    ),
                    if (_pointer != null)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        left: (_pointer!.dx - 16).clamp(0.0, boardW - 32),
                        top: (_pointer!.dy - 32).clamp(0.0, boardH - 32),
                        child: IgnorePointer(
                          child: AnimatedBuilder(
                            animation: _flameCtrl,
                            builder: (context, _) {
                              final v = _flameCtrl.value;
                              return Opacity(
                                opacity: 0.35 + 0.55 * v,
                                child: Transform.scale(
                                  scale: 0.85 + 0.25 * v,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          c.accent2.withValues(alpha: 0.35),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.local_fire_department_rounded,
                                      size: 20,
                                      color: c.accent,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.color, required this.label});
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, color: c.text)),
        ],
      ),
    );
  }
}

class _CellTile extends StatelessWidget {
  const _CellTile({
    super.key,
    required this.cell,
    required this.size,
    required this.colors,
    required this.onTap,
    required this.onLongPress,
  });

  final Cell cell;
  final double size;
  final ThemeColors colors;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final revealed = cell.isRevealed;
    final gap = size > 26 ? 2.0 : 1.2;

    Widget content;
    if (revealed) {
      if (cell.isMine) {
        content = Icon(
          Icons.local_fire_department_rounded,
          key: const ValueKey('mine'),
          size: size * 0.62,
          color: colors.danger,
        );
      } else if (cell.around > 0) {
        content = Text(
          '${cell.around}',
          key: ValueKey('n${cell.around}'),
          style: TextStyle(
            fontSize: size * 0.52,
            fontWeight: FontWeight.w700,
            color: colors.number(cell.around),
          ),
        );
      } else {
        content = const SizedBox.shrink(key: ValueKey('empty'));
      }
    } else if (cell.isFlagged) {
      content = Icon(
        Icons.flag_rounded,
        key: const ValueKey('flag'),
        size: size * 0.52,
        color: colors.accent,
      );
    } else {
      content = const SizedBox.shrink(key: ValueKey('hidden'));
    }

    return SizedBox(
      width: size,
      height: size,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: EdgeInsets.all(gap / 2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size > 28 ? 6 : 4),
              color: revealed
                  ? (cell.isMine
                      ? colors.danger.withValues(alpha: 0.18)
                      : colors.bg)
                  : colors.surfaceAlt,
              border: Border.all(color: colors.line),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: Tween<double>(begin: 0.6, end: 1).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                    ),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BoomPainter extends CustomPainter {
  _BoomPainter(this.t, this.c);
  final double t;
  final ThemeColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.longestSide * 0.8;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = c.accent.withValues(alpha: (1 - t) * 0.38),
    );

    for (var i = 0; i < 3; i++) {
      final p = (t - i * 0.10).clamp(0.0, 1.0);
      if (p <= 0) continue;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12 * (1 - p)
        ..color = Color.lerp(c.accent2, c.danger, i / 2)!
            .withValues(alpha: 1 - p);
      canvas.drawCircle(center, maxR * p, paint);
    }

    final glow = RadialGradient(
      colors: [
        Colors.white.withValues(alpha: (1 - t) * 0.85),
        c.accent.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromCircle(center: center, radius: 80 * (0.4 + t)));
    canvas.drawCircle(center, 80 * (0.4 + t), Paint()..shader = glow);
  }

  @override
  bool shouldRepaint(covariant _BoomPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.c != c;
}
