/* The Selection Rectangle object */

class SelectRect extends Rect {
  Rect[] corners = new Rect[4];
  private Vec2D vecToMouse = ORIGIN;
  
  int getRectMode() {
    Vec2D mouseVec = new Vec2D(mouseX, mouseY);
    if (mouseVec.isInRectangle(this)) {
      int dragCorner = getCornerWithMouse();
      if (dragCorner == -1)
        return TRANSPOSE;
      else {
        if (dragCorner == 0)
          mousePos = getBottomRight();
        else if (dragCorner == 1)
          mousePos = getBottomLeft();
        else if (dragCorner == 2)
          mousePos = getTopLeft();
        else if (dragCorner == 3)
          mousePos = getTopRight();
        return DRAG;
      }
    }
    return NONE;
  }
  
  /* Draw the selection rectangle */
  void display() {
    fill(color(50, 50, 255, 50));
    rect(selectRect.x, selectRect.y, selectRect.width, selectRect.height);
    Vec2D mouseVec = new Vec2D(mouseX, mouseY);
    int cornerIndex = -1;
    if (mousePressed)
      cornerIndex = getCornerCloseToMouse();
    else
      cornerIndex = getCornerWithMouse();
    if (cornerIndex != -1)
      rect(corners[cornerIndex].x, corners[cornerIndex].y, corners[cornerIndex].width, corners[cornerIndex].height);
  }
    
  /*
   * Updates the selection to the current mouse position, and updates the corner and side rects
   * all rects must start in the upper-left and have positive
   * width and heigt so that particle.isInRectangle(this) works.
   */
  void update() {
    Vec2D mouseVec = new Vec2D(mouseX, mouseY);
    updateCorners();
    if (rectMode == TRANSPOSE) // transpose
      setPosition(mouseVec.add(vecToMouse));
    else { // scale
      float x = min(mousePos.x(), mouseX);
      float y = min(mousePos.y(), mouseY);
      float rectWidth = abs(mousePos.x() - mouseX);
      float rectHeight = abs(mousePos.y() - mouseY);
      set(x, y, rectWidth, rectHeight);
    }
  }
 
  /* Updates the location and size of the corner rectangles.
   * Should be updated every time the rectangle changes.
   */
  void updateCorners() {
    float dim = min(width/8, height/8);
    corners[0] = new Rect(getLeft(), getTop(), dim, dim); // top left
    corners[1] = new Rect(getRight() - dim, getTop(), dim, dim); // top right
    corners[2] = new Rect(getRight() - dim, getBottom() - dim, dim, dim); // bottom right
    corners[3] = new Rect(getLeft(), getBottom() - dim, dim, dim); // bottom left
  }
  
  /* If the mouse is within any corner, it is returned.
   * Otherwise, null is returned.
   */
  int getCornerWithMouse() {
    Vec2D mouseVec = new Vec2D(mouseX, mouseY);
    for (int i = 0; i < 4; ++i)
      if (corners[i] != null && mouseVec.isInRectangle(corners[i]))
        return i;
    return -1;
  }
  
  /* Used as an alternative to getCornerWithMouse() above when dragging the corner.
   * Since the mouse can lag and lead inside and outside of the actual corner,
   * we only need the mouse to be "close enough"
   */
  int getCornerCloseToMouse() {
    Vec2D mouseVec = new Vec2D(mouseX, mouseY);
    for (int i = 0; i < 4; ++i)
      if (corners[i] != null &&
          mouseVec.isInRectangle(new Rect(corners[i].x - 10, corners[i].y - 10,
                                          corners[i].width + 20, corners[i].height + 20)))
        return i;
    return -1;
  }     
  
  /* Returns a list of all the particles within the selection rect */
  ArrayList<Particle> particlesInside() {
    ArrayList<Particle> inside = new ArrayList<Particle>();
    for (VerletParticle2D p : physics.particles)
      if (p.isInRectangle(this))
        inside.add((Particle)p);
    return inside;
  }
  
  /* Used for Transpose Mode.
   * When user clicks in the rectangle, this vector is set so it can always have
   * the dragging mouse in the same relative location within.
   */
  void anchorMouse(Vec2D mouseVec) {
    vecToMouse = getTopLeft().sub(mouseVec);
  } 
  
  Vec2D getBottomLeft() {
    return new Vec2D(getLeft(), getBottom());
  }
  
  Vec2D getTopRight() {
    return new Vec2D(getRight(), getTop());
  }
}
