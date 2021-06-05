import 'package:collection/collection.dart';
import 'package:graph/src/directed_graph.dart';

const bigInt = 1 << 30;

class _VertexWithDistance<V> {
  final V vertex;
  int distance;

  _VertexWithDistance(this.vertex, this.distance);

  @override
  bool operator ==(dynamic other) =>
      vertex == other.vertex && distance == other.distance;

  @override
  int get hashCode => vertex.hashCode;
}

int _comparison<V>(_VertexWithDistance<V> v1, _VertexWithDistance<V> v2) =>
    v1.distance - v2.distance;

/// Returns shortest path between startVertex and endVertex. All edge weights are assumed to be 1
List<V> shortestPath<V>(
    {required DirectedGraph<V> directedGraph,
    required V startVertex,
    required V endVertex}) {
  //
  // https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
  // https://www.programiz.com/dsa/dijkstra-algorithm
  // Distances stored in two places? (distances & priorityQueue)?
  //

  final Map<V, int> distances = Map.fromIterable(directedGraph.vertices,
      key: (vertex) => vertex,
      value: (vertex) => vertex == startVertex ? 0 : bigInt);

  final Map<V, V?>? previousVertices = Map.fromIterable(directedGraph.vertices,
      key: (vertex) => vertex, value: (_) => null);

  final priorityQueue = HeapPriorityQueue<_VertexWithDistance<V>>(_comparison);

  priorityQueue.addAll(directedGraph.vertices.map((vertex) =>
      _VertexWithDistance<V>(vertex, vertex == startVertex ? 0 : bigInt)));

  _VertexWithDistance<V>? minItem;

  while (priorityQueue.isNotEmpty) {
    minItem = priorityQueue.removeFirst();
    if (minItem.vertex == endVertex) {
      break;
    }

    for (var neighbor in directedGraph.neighbors(minItem.vertex)) {
      final neighborInQueue =
          _VertexWithDistance<V>(neighbor, distances[neighbor]!);
      if (priorityQueue.contains(neighborInQueue)) {
        final tempDistance = distances[minItem.vertex]! + 1; // 1 = weight

        if (tempDistance < distances[neighbor]!) {
          priorityQueue.remove(neighborInQueue);
          priorityQueue.add(_VertexWithDistance<V>(neighbor, tempDistance));
          distances[neighbor] = tempDistance;
          previousVertices![neighbor] = minItem.vertex;
        }
      }
    }
  }
  final List<V> path = [];

  V? next = minItem!.vertex;

  while (next != null) {
    path.insert(0, next);
    next = previousVertices![next];
  }

  return path;
}
