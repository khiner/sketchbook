import processing.core.*; 
import processing.xml.*; 

import toxi.geom.*; 
import toxi.physics2d.behaviors.AttractionBehavior; 
import toxi.physics2d.behaviors.ParticleBehavior2D; 
import toxi.physics2d.*; 
import java.util.Collections; 
import controlP5.*; 
import toxi.physics2d.constraints.*; 
import toxi.physics2d.behaviors.AttractionBehavior; 
import toxi.physics2d.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class InjectImage extends PApplet {

/*repulsion
  Image Inject
  Visualizing images as a cellular cluster of particles
  House mouse to inject the image onto the canvas
  Author: Karl Hiner
  Inspired By: http://www.escapemotions.com/experiments/biolab/index.html
*/








final int SNAP_DIST_SQUARED = 4;
PImage img;
ControlP5 controlP5;
VerletPhysics2D physics = new VerletPhysics2D();
ArrayList<Particle> particleAmmo = new ArrayList<Particle>();
AttractionBehavior mouseAttractor;
Vec2D mousePos;
int particleSize = 10;
boolean randomSize = false;
boolean repulsion = false;
boolean follow = false;  // toggle for particles to follow the mouse
float repulsionStrength = -1.2f;

public void setup() {
  size(600, 600, P2D);
  noStroke();
  controlP5 = new ControlP5(this);
  physics.setWorldBounds(new Rect(0, 0, width, height));
  physics.setDrag(0.05f);
  img = loadImage("sunset.jpg");
  img.resize(450, (int)map(img.height, 0, img.width, 0, 450));
  img.loadPixels();
  loadParticleGun();
  controlP5.addToggle("follow", follow, 5, height - 25, 10, 10);
  controlP5.addToggle("random", randomSize, 45, height - 25, 10, 10);
  controlP5.addSlider("particleSize", 2, 16, particleSize, 60, height - 25, 50, 10).setLabel("Particle Size");
  controlP5.addToggle("repulsion", repulsion, 190, height - 25, 10, 10).trigger();
  controlP5.addSlider("repulsionStrength", 0, 2, 1.2f, 205, height - 25, 50, 10).setLabel("repulsion strength");
  controlP5.addButton("reset", 1, width - 50, height - 25, 32, 15);
}


public void draw() {
  background(color(0));
  if (mousePressed && !particleAmmo.isEmpty() && !controlP5.window(this).isMouseOver()) {
    Particle p = particleAmmo.remove(particleAmmo.size() - 1);
        p.setRepulsiveForce(20, repulsionStrength, .01f);
        p.set(new Vec2D(mouseX, mouseY));
        if (randomSize)
          p.setSize(2 + (int)random(14));
        else
          p.setSize(particleSize);
        p.unlock();  // don't know why, but if we don't use this,
                     // the particle gets shot out from the mouse to the edge
        physics.addParticle(p);
  }
  for (VerletParticle2D p : physics.particles) {
      Particle par = (Particle)p;
      fill(par.getColor());
      ellipse(par.x(), par.y(), par.getSize(), par.getSize());
  }
  physics.update();
  controlP5.draw();
}

public void loadParticleGun() {
  for (int x = 0; x < img.width; x += 10) {
    for (int y = 0; y < img.height; y += 10) {
      int c = img.pixels[y*img.width + x];
      Particle p = new Particle(x+(width/2)-img.width/2, y+(height/2)-img.height/2, particleSize, c);
      particleAmmo.add(p);
    }
  }
  Collections.shuffle(particleAmmo);  // randomize the particle pixels
}

public void follow(boolean value) {
  follow = value;
}

public void particleSize(float value) {
  particleSize = (int)value;
}

public void random(boolean value) {
  randomSize = value;
}

public void repulsion(boolean value) {
  repulsion = value;
  for (VerletParticle2D p : physics.particles) {
    Particle par = (Particle)p;
    if (repulsion)
      physics.addBehavior(par.getRepulsiveForce());
    else
      physics.removeBehavior(par.getRepulsiveForce());
  }
  if (repulsion) {
    // by default, repulsion to the center
    mouseAttractor = new AttractionBehavior(new Vec2D(width/2, height/2), 1000, 0.5f);
    physics.addBehavior(mouseAttractor);
  } else // turn off the extra mouse attractor so the particles can go to their homes
    physics.removeBehavior(mouseAttractor);
}

public void repulsionStrength(float value) {
  repulsionStrength = -value;
  for (VerletParticle2D p : physics.particles) {
    Particle par = (Particle)p;
    par.getRepulsiveForce().setStrength(repulsionStrength);
  }
}

public void reset(int value) {
 for (VerletParticle2D p : physics.particles) {
    Particle par = (Particle)p;
    physics.removeBehavior(par.getRepulsiveForce());
    //physics.removeParticle(par);
  }
  physics.clear();
  particleAmmo.clear();
  loadParticleGun();
}

public void mousePressed() {
  if (follow && !controlP5.window(this).isMouseOver()) {
    physics.removeBehavior(mouseAttractor);
  mousePos = new Vec2D(mouseX, mouseY);
  // create a new positive attraction force field around the mouse position (radius=250px)
  mouseAttractor = new AttractionBehavior(mousePos, 1000, 0.5f);
  physics.addBehavior(mouseAttractor);
  }
}
 
public void mouseDragged() {
    if (follow && !controlP5.window(this).isMouseOver()) {
  // update mouse attraction focal point
  mousePos.set(mouseX, mouseY);
    }
}
 
public void mouseReleased() {
  // remove the mouse attraction when button has been released
  if (!repulsion && !controlP5.window(this).isMouseOver())
  physics.removeBehavior(mouseAttractor);
}





class Particle extends VerletParticle2D {
  int myColor;
  int mySize;
  AttractionBehavior repulsiveForce;
  
  Particle(float x, float y, int sz, int c) {
    super(width/2, height/2);
    addBehavior(new AttractionBehavior(new Vec2D(x, y), 1000, .2f));
    myColor = c;
    mySize = sz;
    setWeight(2);
  }
  
  public int getColor() { return myColor; }
  public void setColor(int c) { myColor = c; }
  public int getSize() { return mySize; }
  public void setSize(int newSize) { mySize = newSize; }
  public void setRepulsiveForce(float range, float strength, float jitter) {
    repulsiveForce = new AttractionBehavior(this, range, strength, jitter);
    if (repulsion)
      physics.addBehavior(repulsiveForce);
  }
  public AttractionBehavior getRepulsiveForce() { return repulsiveForce; }
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#DFDFDF", "InjectImage" });
  }
}
