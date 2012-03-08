import toxi.physics2d.constraints.*;
import toxi.physics2d.behaviors.AttractionBehavior;
import toxi.physics2d.*;

class Particle extends VerletParticle2D {
  color myColor;
  int mySize;
  AttractionBehavior repulsiveForce;
  
  Particle(float x, float y, int sz, color c) {
    super(width/2, height/2);
    addBehavior(new AttractionBehavior(new Vec2D(x, y), 1000, .2));
    myColor = c;
    mySize = sz;
    setWeight(2);
  }
  
  color getColor() { return myColor; }
  void setColor(color c) { myColor = c; }
  int getSize() { return mySize; }
  void setSize(int newSize) { mySize = newSize; }
  void setRepulsiveForce(float range, float strength, float jitter) {
    repulsiveForce = new AttractionBehavior(this, range, strength, jitter);
    if (repulsion)
      physics.addBehavior(repulsiveForce);
  }
  AttractionBehavior getRepulsiveForce() { return repulsiveForce; }
}
