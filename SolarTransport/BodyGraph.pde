class BodyGraph implements Iterable<Body>, Iterator<Body>
{
  private ArrayList<Body> vertices = new ArrayList<Body>();
  private ArrayList<Edge> edges = new ArrayList<Edge>();

  class Edge
  {
    public final Body node1, node2;
    // no weight, since the distances are dynamic

    public Edge(Body node1, Body node2) {
      this.node1 = node1;
      this.node2 = node2;
    }

    public Body getNeighbor(Body body) {
      if (body.equals(node1))
        return node2;
      else if (body.equals(node2))
        return node1;
      else
        return null;
    }
  }

  void addVertex(Body node) {
    vertices.add(node);
  }

  void addEdge(Body node1, Body node2) {
    edges.add(new Edge(node1, node2));
  }

  ArrayList<Body> getNeighbors(Body body) {
    ArrayList<Body> neighbors = new ArrayList<Body>();
    for (Edge edge : edges) {
      Body neighbor = edge.getNeighbor(body);
      if (neighbor != null)
        neighbors.add(neighbor);
    }
    return neighbors;
  }

  Body get(String name) {
    for (Body b : vertices)
      if (b.name.equals(name))
        return b;
    return null;
  }

  public ArrayList<Body> vertices() { 
    return (ArrayList)vertices;
  }

  Iterator iterator() {
    return vertices.iterator();
  }

  Body next() {
    return vertices.iterator().next();
  }

  boolean hasNext() {
    return vertices.iterator().hasNext();
  }

  void remove() {
    throw new UnsupportedOperationException();
  }

  boolean isEmpty() {
    return vertices.isEmpty();
  }

  // Dijkstra's Algorithm finds a shortest path from point a to point b.
  Stack<Body> dijkstra(Body a, Body b) {
    ArrayList<Body> vertices = (ArrayList)bodyGraph.vertices().clone();
    for (Body ver : vertices) {
      ver.distance = Float.MAX_VALUE;
      ver.prev = null;
    }
    a.distance = 0;
    while (!vertices.isEmpty ()) {
      Body body = getSmallestDist(vertices);
      if (body.distance == Float.MAX_VALUE)
        break;
      vertices.remove(body);
      for (Body neighbor : bodyGraph.getNeighbors(body)) {
        if (vertices.contains(neighbor)) {
          float altDist = body.distance + body.distanceTo(neighbor);//body.getArrivalTimeITN(neighbor, body.time);
          if (altDist < neighbor.distance) {
            neighbor.distance = altDist;
            neighbor.prev = body;
          }
        }
      }
    }
    // Hold the path in a stack.
    Stack<Body> path = new Stack<Body>();
    while (b.prev != null) {
      path.push(b);
      b = b.prev;
    }
    path.push(a); // Add the starting location.
    return (Stack)path.clone();
  }
}

