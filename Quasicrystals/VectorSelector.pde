/* A circle of controllable vectors*/
class VectorSelector {
  float[] angles;
  int sz = 70;
  int vecWithMouse = -1;
  float arrowLength = sz*.4;
  int x = width - 50, y = 50; // center
  
  VectorSelector() {
    initAngles();
  }

  void initAngles() {
    angles = new float[SYMMETRY];
    for (int i = 0; i < SYMMETRY; i++)
      angles[i] = i*TWO_PI/SYMMETRY;
  }
  
  void draw() {
    pushStyle(); // encapsulate the drawing style (fill, stroke)
    fill(1);
    ellipse(x, y, sz, sz); // draw white circle
    for (int i = 0; i < SYMMETRY; i++) {
      if (i == vecWithMouse) // draw arrow being dragged as red
        stroke(color(1, 0, 0));
      else
        stroke(0); // otherwise, draw black arrow
      arrow(x, y, x + arrowLength*cos(angles[i]), y + arrowLength*sin(angles[i]), angles[i]);
    }
    popStyle(); // go back to previous drawing style
  }

  boolean isMouseOver() {
    return new Vector(mouseX, mouseY).distanceToSquared(x, y) < sz*sz;
  }
  
  void arrow(float x1, float y1, float x2, float y2, float a) {
    line(x1, y1, x2, y2);
    pushMatrix();
    translate(x2, y2);
    rotate(a - HALF_PI);
    line(0, 0, -4, -4);
    line(0, 0, 4, -4);
    popMatrix();
  }

  void mouseMoved() {
    for (int i = 0; i < SYMMETRY; i++) {
      for (int j = 0; j < arrowLength; j+= 4) {
        if (new Vector(mouseX, mouseY).distanceToSquared(x + j*cos(angles[i]), y + j*sin(angles[i])) < 20) {
          vecWithMouse = i;
          return;
        }
      }
    }
    vecWithMouse = -1;
  }

  void mouseDragged() {
    if (vecWithMouse != -1)
      angles[vecWithMouse] = atan2(mouseY - y, mouseX - x);
  }
  
  boolean selected() {
    return vecWithMouse != -1;
  }
  
  float getAngle(int index) {
    return angles[index];
  }
  
  /*
   * Add the given amount to the angle with given index.
   */
  void addToAngle(int index, float add) {
    angles[index] += add;
  }
}

