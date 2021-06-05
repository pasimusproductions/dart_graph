import 'package:graph/graph.dart';
import 'package:test/test.dart';

main() {
  test('maze generation', () {
    final maze = Maze.generate();
    final firstCell = maze.cells[0][0];

    expect(
        firstCell.topOpen ||
            firstCell.bottomOpen ||
            firstCell.leftOpen ||
            firstCell.rightOpen,
        true);
    //TODO: More tests
  });
}
