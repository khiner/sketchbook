class Vector {
  float x, y;
  float slope;
  float intercept;

  Vector() {
    x = 0.0;
    y = 0.0;
    slope = 0.0;
  }

  Vector(float x, float y) {
    this.x = x;
    this.y = y;
    slope = y/x;
  }

  void set(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void add(float x, float y) {
    this.x += x;
    this.y += y;
  }
  
  void add(Vector vec) {
    x += vec.x;
    y += vec.y;
  }

  void sub(float x, float y) {
    this.x -= x;
    this.y -= y;
  }
  
  void sub(Vector vec) {
    x -= vec.x;
    y -= vec.y;
  }

  Vector scale(float s) {
    x *= s;
    y *= s;
    return this;
  }

  float dot(Vector vec) {
    return x*vec.x + y*vec.y;
  }

  Vector getScaled(float s) {
    return new Vector(x*s, y*s);
  }

  Vector getAdd(Vector vec) {
    return new Vector(x + vec.x, y + vec.y);
  }
  
  Vector getSub(Vector vec) {
    return new Vector(x - vec.x, y - vec.y);
  }
  
  Vector getNormal() {
    return new Vector(-y, x).scale(sqrt(x*x + y*y));
  }
  
  float minDistToPoint(Vector p, float b) {
    float dist = (p.y - slope*p.x - b)/sqrt(slope*slope + 1);
    return b >= 0 ? -dist : dist; // given the orientation and labeling of the lines, this is correct sign
  }

  float distanceToSquared(float x, float y) {
    return (x - this.x)*(x - this.x) + (y - this.y)*(y - this.y);
  }
}
