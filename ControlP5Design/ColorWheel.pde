/*
   Code adapted from the processing website:
 http://processing.org/learning/basics/colorwheel.html
 */
class ColorWheel {
  float x = 0;
  float y = 0;
  int segs = 12;
  int steps = 8;
  float rotAdjust = TWO_PI / segs / 2;
  float radius = 50;
  float segWidth = radius / steps;
  float interval = TWO_PI / segs;
  color[][] cols;
  boolean visible = false;

  ColorWheel() {
    cols = new color[steps][segs];
    for (int j = 0; j < steps; j++) {
      cols[j] = new color[] { 
        color(255-(255/steps)*j, 255-(255/steps)*j, 0), 
        color(255-(255/steps)*j, (255/1.5)-((255/1.5)/steps)*j, 0), 
        color(255-(255/steps)*j, (255/2)-((255/2)/steps)*j, 0), 
        color(255-(255/steps)*j, (255/2.5)-((255/2.5)/steps)*j, 0), 
        color(255-(255/steps)*j, 0, 0), 
        color(255-(255/steps)*j, 0, (255/2)-((255/2)/steps)*j), 
        color(255-(255/steps)*j, 0, 255-(255/steps)*j), 
        color((255/2)-((255/2)/steps)*j, 0, 255-(255/steps)*j), 
        color(0, 0, 255-(255/steps)*j), 
        color(0, 255-(255/steps)*j, (255/2.5)-((255/2.5)/steps)*j), 
        color(0, 255-(255/steps)*j, 0), 
        color((255/2)-((255/2)/steps)*j, 255-(255/steps)*j, 0)
      };
    }
  }

  void setPosition(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void setVisible(boolean flag) {
    visible = flag;
  }

  int getWidth() {
    return (int)(radius*2);
  }
  
  color getSelectedColor() {
    loadPixels();
    return pixels[width*mouseY + mouseX];
  }

  boolean isVisible() {
    return visible;
  }

  boolean isMouseOver() {
    //return the rectangle surrounding the wheel for now
    return new Vec2D(mouseX, mouseY).isInRectangle(new Rect(x, y, 2*radius, 2*radius));
    //return dist(mouseX, mouseY, x + radius, y + radius) <= radius;
  }

  void draw() {
    if (visible) {
      noStroke();
      drawShadeWheel();
    }
  }

  void drawShadeWheel() {
    float tempRadius = radius;
    for (int j = 0; j < steps; j++) {
      for (int i = 0; i < segs; i++) {
        fill(cols[j][i]);
        arc(x + radius, y + radius, tempRadius, tempRadius, 
        interval*i+rotAdjust, interval*(i+1)+rotAdjust);
      }
      tempRadius -= segWidth;
    }
  }
}

