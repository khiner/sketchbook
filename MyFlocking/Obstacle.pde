class Obstacle {
  PVector origin;
  float rad;
  
  Obstacle(float x, float y, float rad) {
    origin = new PVector(x, y);
    this.rad = rad;
  }
  
  void set(float x, float y) {
    origin = new PVector(x, y);
  }
  
  void draw() {
    fill(255);
    ellipse(origin.x, origin.y, rad, rad);
  }
}
