private class Polygon extends Polygon2D {
  private class ColorLine2D extends Line2D {
    private int col = 0;
    private float width = 1;
    private boolean visible = true;
    
    ColorLine2D(Line2D line, int col, float width, boolean visible) {
      super(line.a, line.b);
      this.col = col;
      this.width = width;
      this.visible = visible;
    }
  }
  
  private boolean finished = false;
  private boolean selected = false;
  private List<Line2D> edges = new ArrayList<Line2D>();
  private Vec2D anchor = null;
  private Vec2D velocity = new Vec2D(0, 0);
  private color col = color(200, 200, 200);
  private color selectedColor = color(255, 200, 200);
  
  private List<ColorLine2D> extraLines = new ArrayList<ColorLine2D>();
  
  Polygon() {
    super();
  }
  
  Polygon(List<Vec2D> vertices) {
    super(vertices);
  }
  
  private void move() {
    if (!selected && anchor != null) {
      move(new Vec2D(velocity.x, velocity.y));
    }
  }
  
  public void draw() {
    if (vertices.isEmpty()) {
      return;
    }
    if (finished) {
      fill(selected ? selectedColor : col);
      stroke(0);
      //finish();
      gfx.polygon2D(this);
      noFill();
      for (ColorLine2D line : extraLines) {
        stroke(line.col);
        strokeWeight(line.width);
        if (line.visible) {
          line(line.a.x, line.a.y, line.b.x, line.b.y);
        }
      }
    } else {
      noFill();
      stroke(0);
      strokeWeight(1);
      beginShape();
      for (Vec2D vertex : vertices) {
        vertex(vertex.x, vertex.y);
      }  
      endShape();   
    }
  }

  public void updateEdges() {
    int numVertices = vertices.size();
    for (int i = 0; i < numVertices; i++) {
      edges.add(new Line2D(vertices.get(i), vertices.get((i + 1) % numVertices)));
    }    
  }
  
  private void jitter() {
    for (Vec2D vertex : vertices) {
      vertex.x += random(-2, 3);
      vertex.y += random(-2, 3);
    }
  }
  
  private void createExtraLines() {
    extraLines = new ArrayList<ColorLine2D>();
    for (int i = 0; i < 8; i++) {
      Polygon extraPolygon = new Polygon(vertices);
      extraPolygon.smooth(.02 * random(0, i), .02 * random(0, i));
      extraPolygon.jitter();
      extraPolygon.updateEdges();
      for (Line2D edge : extraPolygon.edges) {
        extraLines.add(new ColorLine2D(edge, (int)random(100), random(2), (int)random(2) == 0));
      }
    }
  }
  
  public void finish() {
    smooth(.01, 0.03);
    updateEdges();
    createExtraLines();
    finished = true;
  }

  public boolean intersectsPolygon(Polygon polygon) {
    for (Line2D ea : edges) {
      for (Line2D eb : polygon.edges) {
        final Line2D.LineIntersection.Type isec = ea.intersectLine(eb).getType();
        if (isec == Line2D.LineIntersection.Type.INTERSECTING) {
          return true;
        }
      }
    }
    return false;
  }

  public void move(Vec2D delta) {
    for (Vec2D vertex : vertices) {
      vertex.addSelf(delta);
    }
    velocity = delta;
    anchor.addSelf(delta);
    for (Line2D extraLine : extraLines) {
      extraLine.a.addSelf(velocity);
    }
  }
}
