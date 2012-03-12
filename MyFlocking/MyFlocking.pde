import toxi.geom.*;
/**
 * Flocking 
 * by Daniel Shiffman.  
 * 
 * An implementation of Craig Reynold's Boids program to simulate
 * the flocking behavior of birds. Each boid steers itself based on 
 * rules of avoidance, alignment, and coherence.
 * 
 * Click the mouse to add a new boid.
 */

Flock flock;
Obstacle selected = null;
Obstacle newObst = null;

ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
float SEPARATION = 100.0;
float NEIGHBOR_DIST = 50.0;
PVector mouseTarget = null;

void setup() {
  size(640, 360);
  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 120; i++)
    flock.addBoid(new Boid(new PVector(width/2, height/2), 3.0, 0.05));
  smooth();
}

void draw() {
  background(50);
  //SEPARATION = map(mouseX, 0, width, 5, 500);
  //NEIGHBOR_DIST = map(mouseY, 0, height, 5, 500);
  //mouseTarget = new PVector(mouseX, mouseY);
  flock.run();
  for (Obstacle o : obstacles)
    o.draw();
  if (mousePressed && newObst != null)
    newObst.rad += 1;
}

// Add a new boid into the System
void mousePressed() {
  selected = getObst(new PVector(mouseX, mouseY));
  if (selected == null) {
    newObst = new Obstacle(mouseX, mouseY, 1);
    obstacles.add(newObst);
  }
}

void mouseReleased() {
  newObst = null;
  selected = null;
}

void mouseDragged() {
  if (selected != null)
    selected.set(mouseX, mouseY);
}

Obstacle getObst(PVector vec) {
  for (Obstacle o : obstacles)
    if (PVector.dist(vec, o.origin) < o.rad)
      return o;
  return null;
}

