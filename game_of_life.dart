import 'dart:html';
import 'dart:math';

const RESOLUTION = 5;

CanvasElement canvas;
CanvasRenderingContext2D ctx;

void main() async {
  canvas = querySelector('#canvas');
  ctx = canvas.getContext('2d');
//   clear();
//   drawPoint(1, 1);
//   Grid grid = Grid()..draw();
//   grid.nextGeneration();
//   await Future.delayed(Duration(seconds: 2));
//   clear();
//   grid.draw();
  GameOfLife()..run();
}

void drawPoint(int row, int col) {
  int x = col * RESOLUTION;
  int y = row * RESOLUTION;
  ctx
    ..fillStyle = "white"
    ..strokeStyle = "black"
    ..fillRect(x, y, RESOLUTION, RESOLUTION)
    ..strokeRect(x, y, RESOLUTION, RESOLUTION);
}

void clear() {
  ctx
    ..fillStyle = "black"
    ..fillRect(0, 0, canvas.height, canvas.width);
}

class Grid {
  List<List<int>> _grid;
  int rows;
  int cols;

  Grid() {
    rows = canvas.height ~/ RESOLUTION;
    cols = canvas.width ~/ RESOLUTION;
    initGrid();
  }

  List<List<int>> make2DArray(int rows, int cols) =>
      List.generate(rows, (i) => List.generate(cols, (i) => 0));

  void initGrid() {
    _grid = make2DArray(rows, cols);
    Random r = Random();
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        _grid[i][j] = r.nextInt(2);
      }
    }
  }

  void draw() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (_grid[i][j] == 1) {
          drawPoint(i, j);
        }
      }
    }
  }

  void nextGeneration() {
    List<List<int>> next = make2DArray(rows, cols);
    // COMPUTE THE NEXT GEN
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        int state = _grid[i][j];

        if (i == 0 || j == 0 || i == rows - 1 || j == cols - 1) {
          next[i][j] = state;
          continue;
        }
        int neighbours = _countNeighbours(i, j);
        if (state == 0 && neighbours == 3) {
          next[i][j] = 1;
        } else if (state == 1 && ((neighbours < 2) || (neighbours > 3))) {
          next[i][j] = 0;
        } else {
          next[i][j] = state;
        }
      }
    }
    _grid = next;
  }

  int _countNeighbours(int x, int y) {
    int sum = 0;
    for (int i = -1; i < 2; i++) {
      for (int j = -1; j < 2; j++) {
        int row = (x + i);
        int col = (y + j);
        sum += _grid[row][col];
      }
    }
    sum -= _grid[x][y];
    return sum;
  }
}

class GameOfLife {
  static const GAME_SPEED = 150;

  num _lastUpdated = 0;

  Grid _grid;

  GameOfLife() {
    _grid = Grid();
  }

  void run() async {
    update(await window.animationFrame);
  }

  void update(delta) {
    var diff = delta - _lastUpdated;
    if (diff > GAME_SPEED) {
      clear();
      _grid.draw();
      _grid.nextGeneration();
    }
    run();
  }
}
