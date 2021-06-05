abstract class DirectedGraph<V> {
  void add(V vertex, List<V> neighbors);
  List<V> neighbors(V vertex);
  Iterable<V> get vertices;
  int get vertexCount;
}
