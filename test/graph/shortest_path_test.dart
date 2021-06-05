import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graph/graph.dart';

class Vertex extends Equatable {
  const Vertex(this.id);

  final int id;

  @override
  List<Object> get props => [id];
}

main() {
  test('shortest path', () {
    var adjacencyList = AdjacencyList<Vertex>();

    final vertex1 = Vertex(1);
    final vertex2 = Vertex(2);
    final vertex3 = Vertex(3);
    final vertex4 = Vertex(4);
    final vertex5 = Vertex(5);

    adjacencyList.add(vertex1, [vertex2, vertex3]);
    adjacencyList.add(vertex2, [vertex1, vertex4]);
    adjacencyList.add(vertex3, [vertex1, vertex5]);
    adjacencyList.add(vertex4, [vertex2, vertex5]);
    adjacencyList.add(vertex5, [vertex3, vertex4]);

    var path = shortestPath<Vertex>(
        directedGraph: adjacencyList, startVertex: vertex1, endVertex: vertex5);
    expect(path, [vertex1, vertex3, vertex5]);
  });
}
