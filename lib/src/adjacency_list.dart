import 'package:graph/src/directed_graph.dart';

class AdjacencyList<V> implements DirectedGraph<V> {
  final Map<V, List<V>> _vertices = Map();

  void add(V vertex, List<V> neighbors) {
    _vertices[vertex] = neighbors;
  }

  List<V> neighbors(V vertex) => _vertices[vertex]!;

  int get vertexCount => _vertices.length;

  Iterable<V> get vertices => _vertices.keys;

  @override
  String toString() {
    final buffer = StringBuffer();
    for (var item in _vertices.entries) {
      buffer.write('vertex: ${item.key}; neighbors: ${item.value}\n');
    }
    return buffer.toString();
  }
}
