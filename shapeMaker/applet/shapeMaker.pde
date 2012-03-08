ArrayList<Line> lines = new ArrayList<Line>();

void setup() {
  size(800, 500, P2D);
  strokeWeight(2);
  stroke(0);
  noFill();
  for (int i = 0; i < 20; ++i)
    lines.add(new Line(new PVector(random(width - 1), random(height - 1)), random(TWO_PI), random(1, 1.5)));
}

void draw() {
  background(255);
  for (Line l : lines) {
    //for (Line otherl : lines)
      //if (!l.intersecting(otherl))
    l.stretch();
    l.draw();
  }
}

