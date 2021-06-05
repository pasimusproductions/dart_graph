import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:graph/graph.dart';

enum Direction { left, top, right, bottom, none }

extension Ints on Direction {
  int get intValue {
    switch (this) {
      case Direction.left:
        return 1;
      case Direction.top:
        return 2;
      case Direction.right:
        return 4;
      case Direction.bottom:
        return 8;
      default:
        return 0;
    }
  }

  int get xShift => this == Direction.left
      ? -1
      : this == Direction.right
          ? 1
          : 0;

  int get yShift => this == Direction.top
      ? -1
      : this == Direction.bottom
          ? 1
          : 0;

  Direction get opposite => this == Direction.left
      ? Direction.right
      : this == Direction.right
          ? Direction.left
          : this == Direction.top
              ? Direction.bottom
              : this == Direction.bottom
                  ? Direction.top
                  : Direction.none; // none's oposite not well defined
}

/// Cell in a maze
class Cell extends Equatable {
  // Bits 0 to 3 define if there is open route on that side; see Ints extension above
  final int routes;
  final int xIndex;
  final int yIndex;

  Cell({required this.xIndex, required this.yIndex, required this.routes});

  Cell.fromOther({required Cell other, required Direction newOpenSide})
      : xIndex = other.xIndex,
        yIndex = other.yIndex,
        routes = other.routes | newOpenSide.intValue;

  bool get leftOpen => (routes & Direction.left.intValue) != 0;
  bool get topOpen => (routes & Direction.top.intValue) != 0;
  bool get rightOpen => (routes & Direction.right.intValue) != 0;
  bool get bottomOpen => (routes & Direction.bottom.intValue) != 0;
  bool get notVisited => routes == 0;
  bool sideOpen(Direction direction) => (routes & direction.intValue) != 0;

  @override
  toString() =>
      'Cell: $xIndex $yIndex $leftOpen $topOpen $rightOpen $bottomOpen';

  List<Object> get props => [xIndex, yIndex];
}

/// Maze of cells, currently consisting of 10 x 10 cells
class Maze {
  final int size = 10; // TODO
  late List<List<Cell>> cells;
  late AdjacencyList<Cell> graph;
  late List<Cell> optimalPath;

  /// Generate maze with backtracking algorithm
  /// This is from: https://weblog.jamisbuck.org/2010/12/27/maze-generation-recursive-backtracking
  Maze.generate() {
    //TODO: Some nicer way to fill with separate Cell objects

    cells = List.empty(growable: true);

    for (var i = 0; i < size; ++i) {
      cells.add(List.empty(growable: true));
      for (var j = 0; j < size; ++j) {
        cells[i].add(Cell(xIndex: i, yIndex: j, routes: 0));
      }
    }
    _generate(0, 0);

    var graph = toAdjacencyList();
    // print(graph);
    optimalPath = shortestPath(
        directedGraph: graph,
        startVertex: cells[0][0],
        endVertex: cells[size - 1][size - 1]);
    // print(optimalPath);
  }

  void _generate(int x, int y) {
    final directions = [
      Direction.left,
      Direction.top,
      Direction.right,
      Direction.bottom
    ]..shuffle(Random());

    directions.forEach((direction) {
      final newX = x + direction.xShift;
      final newY = y + direction.yShift;

      if (newX >= 0 &&
          newX < size &&
          newY >= 0 &&
          newY < size &&
          (cells[newX][newY]).notVisited) {
        cells[x][y] =
            Cell.fromOther(other: cells[x][y], newOpenSide: direction);
        cells[newX][newY] = Cell.fromOther(
            other: cells[newX][newY], newOpenSide: direction.opposite);
        _generate(newX, newY);
      }
    });
  }

  /// For a [cell] return the next cell in the specified [direction].
  /// Returns the same cell if no more cells in the specified direction
  Cell nextCell(Cell cell, Direction direction) {
    final nextX = cell.xIndex + direction.xShift;

    if (nextX < 0 || nextX >= size) {
      return cell;
    }

    final nextY = cell.yIndex + direction.yShift;

    if (nextY < 0 || nextY >= size) {
      return cell;
    }

    return cells[nextX][nextY];
  }

  /// For a [cell] return the next cell with an encountered wall in the specified [direction].
  /// Returns the current cell if there's wall in the specified direction in the current cell
  Cell nextCellWithWall(Cell cell, Direction direction) {
    Cell candidate;

    for (;;) {
      if (!cell.sideOpen(direction)) {
        return cell;
      }
      candidate = nextCell(cell, direction);

      if (candidate == cell) {
        return cell;
      }
      cell = candidate;
    }
  }

  AdjacencyList<Cell> toAdjacencyList() {
    final graph = AdjacencyList<Cell>();

    for (var x = 0; x < size; ++x) {
      for (var y = 0; y < size; ++y) {
        final cell = cells[x][y];
        List<Cell> neighbors = [];

        if (cell.leftOpen) {
          neighbors.add(cells[x - 1][y]);
        }

        if (cell.topOpen) {
          neighbors.add(cells[x][y - 1]);
        }

        if (cell.rightOpen) {
          neighbors.add(cells[x + 1][y]);
        }

        if (cell.bottomOpen) {
          neighbors.add(cells[x][y + 1]);
        }

        graph.add(cell, neighbors);
      }
    }

    return graph;
  }
}
