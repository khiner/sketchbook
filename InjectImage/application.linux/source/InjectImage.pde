/*repulsion
  Image Inject
  Visualizing images as a cellular cluster of particles
  House mouse to inject the image onto the canvas
  Author: Karl Hiner
  Inspired By: http://www.escapemotions.com/experiments/biolab/index.html
*/

import toxi.geom.*;
import toxi.physics2d.behaviors.AttractionBehavior;
import toxi.physics2d.behaviors.ParticleBehavior2D;
import toxi.physics2d.*;
import java.util.Collections;
import controlP5.*;

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
float repulsionStrength = -1.2;

void setup() {
  size(600, 600, P2D);
  noStroke();
  controlP5 = new ControlP5(this);
  physics.setWorldBounds(new Rect(0, 0, width, height));
  physics.setDrag(0.05);
  img = loadImage("sunset.jpg");
  img.resize(450, (int)map(img.height, 0, img.width, 0, 450));
  img.loadPixels();
  loadParticleGun();
  controlP5.addToggle("follow", follow, 5, height - 25, 10, 10);
  controlP5.addToggle("random", randomSize, 45, height - 25, 10, 10);
  controlP5.addSlider("particleSize", 2, 16, particleSize, 60, height - 25, 50, 10).setLabel("Particle Size");
  controlP5.addToggle("repulsion", repulsion, 190, height - 25, 10, 10).trigger();
  controlP5.addSlider("repulsionStrength", 0, 2, 1.2, 205, height - 25, 50, 10).setLabel("repulsion strength");
  controlP5.addButton("reset", 1, width - 50, height - 25, 32, 15);
}


void draw() {
  background(color(0));
  if (mousePressed && !particleAmmo.isEmpty() && !controlP5.window(this).isMouseOver()) {
    Particle p = particleAmmo.remove(particleAmmo.size() - 1);
        p.setRepulsiveForce(20, repulsionStrength, .01);
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

void loadParticleGun() {
  for (int x = 0; x < img.width; x += 10) {
    for (int y = 0; y < img.height; y += 10) {
      color c = img.pixels[y*img.width + x];
      Particle p = new Particle(x+(width/2)-img.width/2, y+(height/2)-img.height/2, particleSize, c);
      particleAmmo.add(p);
    }
  }
  Collections.shuffle(particleAmmo);  // randomize the particle pixels
}

void follow(boolean value) {
  follow = value;
}

void particleSize(float value) {
  particleSize = (int)value;
}

void random(boolean value) {
  randomSize = value;
}

void repulsion(boolean value) {
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

void repulsionStrength(float value) {
  repulsionStrength = -value;
  for (VerletParticle2D p : physics.particles) {
    Particle par = (Particle)p;
    par.getRepulsiveForce().setStrength(repulsionStrength);
  }
}

void reset(int value) {
 for (VerletParticle2D p : physics.particles) {
    Particle par = (Particle)p;
    physics.removeBehavior(par.getRepulsiveForce());
    //physics.removeParticle(par);
  }
  physics.clear();
  particleAmmo.clear();
  loadParticleGun();
}

void mousePressed() {
  if (follow && !controlP5.window(this).isMouseOver()) {
    physics.removeBehavior(mouseAttractor);
  mousePos = new Vec2D(mouseX, mouseY);
  // create a new positive attraction force field around the mouse position (radius=250px)
  mouseAttractor = new AttractionBehavior(mousePos, 1000, 0.5f);
  physics.addBehavior(mouseAttractor);
  }
}
 
void mouseDragged() {
    if (follow && !controlP5.window(this).isMouseOver()) {
  // update mouse attraction focal point
  mousePos.set(mouseX, mouseY);
    }
}
 
void mouseReleased() {
  // remove the mouse attraction when button has been released
  if (!repulsion && !controlP5.window(this).isMouseOver())
  physics.removeBehavior(mouseAttractor);
}

