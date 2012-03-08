import toxi.physics2d.constraints.*;
import toxi.physics2d.behaviors.AttractionBehavior;
import toxi.physics2d.*;

class Particle extends VerletParticle2D {
  color myColor;
  int mySize;
  Vec2D unscaled;// the proper location of the particle in grid mode
  AttractionBehavior repulsiveForce, placementForce, gridForce;
  private Vec2D vecToMouse = ORIGIN; // used for dragging of multiple particles to keep the relative vector to mouse


  Particle(float x, float y, int sz, color c) {
    super(width/2, height/2);
    unscaled = new Vec2D(x, y);
    gridForce = new AttractionBehavior(unscaled.copy(), 1000, .2);
    // by defauly, this particle "wants" to be in its grid location.
    placementForce = new AttractionBehavior(unscaled.copy(), 1000, .2);
    setRepulsiveForce(20, repulsionStrength, .01);
    addBehavior(gridForce);
    myColor = c;
    mySize = sz;
    setWeight(2);
  }

  void place(Vec2D loc) {
    placementForce.setAttractor(loc.add(vecToMouse));
  }

  void setGridLoc(Vec2D loc) {
    gridForce.setAttractor(loc.add(vecToMouse));
  }

  void setVecToMouse(Vec2D mouseVec) {
    vecToMouse = this.sub(mouseVec);
  }

  color getColor() { 
    return myColor;
  }
  void setColor(color c) { 
    myColor = c;
  }
  int getSize() { 
    return mySize;
  }
  void setSize(int newSize) { 
    mySize = newSize;
  }

  void togglePlacementForce(boolean value) {
    removeBehavior(gridForce);
    removeBehavior(placementForce);
    if (value)
      addBehavior(placementForce);
  }

  void toggleGridForce(boolean value) {
    removeBehavior(gridForce);
    removeBehavior(placementForce);
    if (value)
      addBehavior(gridForce);
  }

  void scale() {
    float newX = map(unscaled.x(), scaleRect.x, scaleRect.x + scaleRect.width, selectRect.x, selectRect.x + selectRect.width);
    float newY = map(unscaled.y(), scaleRect.y, scaleRect.y + scaleRect.height, selectRect.y, selectRect.y + selectRect.height);
    Vec2D newAttractor = new Vec2D(newX, newY);
    if (shootMode == SHOOT)
      placementForce.setAttractor(newAttractor);
    else if (shootMode == GRID)
      gridForce.setAttractor(newAttractor);
  }

  void setUnscaled() {
    if (shootMode == SHOOT)
      unscaled = placementForce.getAttractor().copy();
    else if (shootMode == GRID)
      unscaled = gridForce.getAttractor().copy();
  }

  void setRepulsiveForce(float range, float strength, float jitter) {
    repulsiveForce = new AttractionBehavior(this, range, strength, jitter);
  }

  AttractionBehavior getRepulsiveForce() { 
    return repulsiveForce;
  }

  void draw() {
    if (displayMode == CONFETTI) { // draw confetti particle
      stroke(myColor, 190);
      strokeWeight(mySize);
      line(x(), y(), x() + getVelocity().x()*mySize/3 + 2, y() + getVelocity().y()*mySize/3 + 2);
    } 
    else { // draw circle/square particle
      fill(myColor, 190);
      if (displayMode == CIRCLE)
        ellipse(x(), y(), mySize, mySize);
      else if (displayMode == SQUARE)
        rect(x() - mySize/2, y() - mySize/2, mySize, mySize);
    }
  }

  // draw circles/squares (depending on display setting) around selected particles

  void drawSelected() {
    noFill();
    stroke(255);
    strokeWeight(2);
    if (displayMode == SQUARE) // if the particle is square, draw a square around it
      rect(x - mySize/2, y - mySize/2, mySize + 2, mySize + 2);
    else // otherwise, for circles and confetti, draw a circle around it
    ellipse(x, y, mySize + 2, mySize + 2);
  }
}

