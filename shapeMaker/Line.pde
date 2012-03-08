class Line {
  float angle;
  float stretchRate;
  float w;
  float x1, x2, y1, y2;
  boolean moveLeft = true;
  boolean moveRight = true;
  int index;
  color myColor = #ffff00;

  Line(float x, float y, float a, float sr, float w, int index) {
    x1 = x2 = x;
    y1 = y2 = y;
    angle = a;
    stretchRate = sr;
    this.w = w;
  }

  void switchColor() { 
    myColor = 0;//color(random(255), random(255), random(255));
  }

  void resetColor() { 
    myColor = #ffff00;
  }

  void grow() {
    grow(stretchRate);
  }

  void grow(float growRate) {
    if (moveLeft) {
      float oldX1 = x1;
      float oldY1 = y1;
      x1 -= growRate*cos(angle);
      y1 -= growRate*sin(angle);
      if (intersecting()) {
        x1 = oldX1;
        y1 = oldY1;
        moveLeft = false;
        //points.add(new PVector(x1, y1));
      }
    }
    if (moveRight) {
      float oldX2 = x2;
      float oldY2 = y2;
      x2 += growRate*cos(angle);
      y2 += growRate*sin(angle);
      if (intersecting()) {
        x2 = oldX2;
        y2 = oldY2;
        moveRight = false;
        //points.add(new PVector(x2, y2));
      }
    }
  }

  void draw() {
    stroke(myColor);
    strokeWeight(w);
    line(x1, y1, x2, y2);
  }

  boolean intersecting(Line l) {
    float denom = (l.y2-l.y1)*(x2-x1)-(l.x2-l.x1)*(y2-y1);
    float na = (l.x2-l.x1)*(y1-l.y1)-(l.y2-l.y1)*(x1-l.x1);
    float nb = (x2-x1)*(y1-l.y1)-(y2-y1)*(x1-l.x1);

    if (denom != 0.0) {
      float ua = na/denom;
      float ub = nb/denom;
      return (ua >= 0.0f && ua <= 1.0 && ub >= 0.0 && ub <= 1.0);
    }
    return false;
  }

  boolean intersecting() {
    for (int i = index + 1; i < lines.size(); ++i)
      if (intersecting(lines.get(i)))
        return true;
    return false;
  }
}

