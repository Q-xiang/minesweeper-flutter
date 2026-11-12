import 'dart:math';

/// 单个格子
class Cell {
  bool isMine = false;
  bool isRevealed = false;
  bool isFlagged = false;
  int around = 0;

  void reset() {
    isMine = false;
    isRevealed = false;
    isFlagged = false;
    around = 0;
  }
}

/// 扫雷核心逻辑：布雷、翻格、插旗、判胜负
class MinesweeperGame {
  MinesweeperGame({
    required this.rows,
    required this.cols,
    required this.mines,
  }) {
    board = List.generate(rows, (_) => List.generate(cols, (_) => Cell()));
  }

  final int rows;
  final int cols;
  final int mines;
  final Random _random = Random();

  late List<List<Cell>> board;

  int revealedCount = 0;
  int flagCount = 0;
  bool isStarted = false;
  bool isOver = false;
  bool isWin = false;

  int get minesLeft => mines - flagCount;
  int get safeTotal => rows * cols - mines;

  void restart() {
    for (final row in board) {
      for (final cell in row) {
        cell.reset();
      }
    }
    revealedCount = 0;
    flagCount = 0;
    isStarted = false;
    isOver = false;
    isWin = false;
  }

  /// 首次点击后布雷，并保证首点及其周围 3×3 无雷
  void _placeMines(int safeRow, int safeCol) {
    final candidates = <List<int>>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final near = (r - safeRow).abs() <= 1 && (c - safeCol).abs() <= 1;
        if (!near) candidates.add([r, c]);
      }
    }
    candidates.shuffle(_random);
    final total = min(mines, candidates.length);
    for (var i = 0; i < total; i++) {
      board[candidates[i][0]][candidates[i][1]].isMine = true;
    }
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        board[r][c].around = _countAround(r, c);
      }
    }
    isStarted = true;
  }

  int _countAround(int r, int c) {
    var count = 0;
    for (var dr = -1; dr <= 1; dr++) {
      for (var dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final nr = r + dr;
        final nc = c + dc;
        if (nr < 0 || nc < 0 || nr >= rows || nc >= cols) continue;
        if (board[nr][nc].isMine) count++;
      }
    }
    return count;
  }

  /// 翻开格子，返回 true 表示踩到雷
  bool reveal(int r, int c) {
    if (isOver) return false;
    final cell = board[r][c];
    if (cell.isRevealed || cell.isFlagged) return false;
    if (!isStarted) _placeMines(r, c);

    if (cell.isMine) {
      cell.isRevealed = true;
      isOver = true;
      isWin = false;
      return true;
    }
    _floodFill(r, c);
    if (revealedCount >= safeTotal) {
      isOver = true;
      isWin = true;
    }
    return false;
  }

  void _floodFill(int startRow, int startCol) {
    final stack = <List<int>>[
      [startRow, startCol]
    ];
    while (stack.isNotEmpty) {
      final p = stack.removeLast();
      final r = p[0];
      final c = p[1];
      final cell = board[r][c];
      if (cell.isRevealed || cell.isFlagged || cell.isMine) continue;
      cell.isRevealed = true;
      revealedCount++;
      if (cell.around != 0) continue;
      for (var dr = -1; dr <= 1; dr++) {
        for (var dc = -1; dc <= 1; dc++) {
          final nr = r + dr;
          final nc = c + dc;
          if (nr < 0 || nc < 0 || nr >= rows || nc >= cols) continue;
          if (!board[nr][nc].isRevealed) stack.add([nr, nc]);
        }
      }
    }
  }

  void toggleFlag(int r, int c) {
    if (isOver) return;
    final cell = board[r][c];
    if (cell.isRevealed) return;
    cell.isFlagged = !cell.isFlagged;
    flagCount += cell.isFlagged ? 1 : -1;
  }

  /// 提示：随机返回一个未翻开的非雷格子
  List<int>? randomSafeCell() {
    final list = <List<int>>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final cell = board[r][c];
        if (cell.isRevealed || cell.isFlagged) continue;
        if (isStarted && cell.isMine) continue;
        list.add([r, c]);
      }
    }
    if (list.isEmpty) return null;
    return list[_random.nextInt(list.length)];
  }

  /// 游戏结束时把所有雷显示出来
  void revealAllMines() {
    for (final row in board) {
      for (final cell in row) {
        if (cell.isMine) cell.isRevealed = true;
      }
    }
  }
}
