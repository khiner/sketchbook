/*
 ***Image Inject***
 Author: Karl Hiner
 Visualizing images as a cluster of particles
 Shoot modes are the green buttons on the right.
 Select modes are the yellow buttons on the left.
 Shoot Modes: Free Shoot - shoot particles anywhere on the screen
 Grid - make particles allign to the image
 Cell - particles will gloop together in a group. (not optimized for performance)
 Select Modes: Attract - Hold mouse down to make the particles attract to the mouse
 Rect Select - Click and drag to select particles.
 Once particles are selected, move or scale
 the box to move or scale the particles.
 Select - Click on single particles.
 Hold shift to select multiple particles
 Double Click to select all.
 Click and drag selected particles to move them about.
 Inspired By: http://www.escapemotions.com/experiments/biolab/index.html
 */

import toxi.geom.*;
import toxi.physics2d.behaviors.AttractionBehavior;
import toxi.physics2d.behaviors.ParticleBehavior2D;
import toxi.physics2d.*;
import controlP5.*;

final int SNAP_DIST_SQUARED = 49;
final int DOUBLE_CLICK_TIME = 200;
final int SIZE_MIN = 4;
final int SIZE_MAX = 25;
final Vec2D ORIGIN = new Vec2D(0, 0);
int partitions = 10;
int imgIndex = 0;
int particleSize = 15;
int lastClickTime = 0;
int rectX1, rectX2, rectY1, rectY2;
int controlsWidth = 136;
float repulsionStrength = -1.2;
boolean randomSize = false;
PImage[] imgs = new PImage[4];
ControlP5 controlP5;
ControlGroup controls;
MyButton selectButton, attractButton, rectButton, shootButton, gridButton, cellButton, activeButton;
ListBox displayList;
VerletPhysics2D physics = new VerletPhysics2D();
ArrayList<Particle> particleAmmo = new ArrayList<Particle>();
ArrayList<Particle> selected = new ArrayList<Particle>();
AttractionBehavior mouseAttractor;
Vec2D mousePos;
SelectRect selectRect = null;
Rect scaleRect = null;
DrawPool drawPool;

void setup() {
  size(800, 550, P2D); // P2D is much faster than the default JAVA2D
  controlP5 = new ControlP5(this);
  physics.setWorldBounds(new Rect(140, 10, width - 145, height - 15)); // physics world is constrained by the toolbar
  physics.setDrag(0.05);
  imgs[0] = loadImage("sunset.png");
  imgs[1] = loadImage("linux.png");
  imgs[2] = loadImage("earth.png");
  imgs[3] = loadImage("aphex.png");
  for (PImage img : imgs) {
    img.resize(450, 0); // using 0 for the height param makes the image scale properly.
    img.loadPixels();
  }
  loadParticleGun(imgIndex);
  // by default, repulsion to the center
  mouseAttractor = new AttractionBehavior(new Vec2D(width/2, height/2), 1000, 0.5f);
  controls = controlP5.addGroup("controls", 0, 0)
                      .setBackgroundHeight(height)
                      .setWidth(controlsWidth)
                      .setBarHeight(15);
  controls.captionLabel().setFont(ControlP5.grixel);
  // controlP5 bug: when the font is changed to a larger size, no extra room is allocated
  // for the text until we relabel it.
  controls.setLabel("controls");
  controls.setBackgroundColor(color(190, 128));
  controls.hideBar();
  attractButton = new MyButton("mouseAttract", 5, 5, "attract2.png", "attract.png", "attract3.png");
  rectButton = new MyButton("rectSelect", 5, 70, "rect2.png", "rect.png", "rect3.png");  
  selectButton = new MyButton("select", 5, 135, "select2.png", "select.png", "select3.png");
  shootButton = new MyButton("shoot", 70, 5, "shoot2.png", "shoot.png", "shoot3.png");
  gridButton = new MyButton("grid", 70, 70, "grid2.png", "grid.png", "grid3.png");
  cellButton = new MyButton("cells", 70, 135, "cell2.png", "cell.png", "cell3.png");
  gridButton.activate();
  displayList = controlP5.addListBox("displayList", 5, 215, 120, 40)
                         .setItemHeight(10)
                         .setLabel("Display Mode");
  // the values for the displayList items are their corresponing display modes.
  displayList.addItem("Circle", CIRCLE);
  displayList.addItem("Square", SQUARE);
  displayList.addItem("Confetti", CONFETTI);
  controlP5.addToggle("random", randomSize, 10, 385, 15, 15);
  controlP5.addSlider("particleSize", SIZE_MIN, SIZE_MAX, particleSize, 10, 260, 15, 110)
           .setLabel("Particle Size");
  controlP5.addSlider("repulsionStrength", -2, 2, 1.2, 80, 260, 15, 110)
           .setLabel("repulsion");
  controlP5.addSlider("ammo", 0, 1, 1, 112, 430, 10, 80).valueLabel()
           .setVisible(false);
  controlP5.controller("ammo").lock();
  controlP5.addButton("reset", 0, 30, 520, 50, 20)
           .captionLabel().setFont(ControlP5.grixel);
  // due to a bug in ControlP5, we have to setLabel again after changing the font, or text gets cut off.
  controlP5.controller("reset")
           .setLabel("reset");
  controlP5.addButton("imageButton", 1, 5, 430, 100, 80);
  setButtonImage(imgIndex);
}

void draw() {
  background(0);
  physics.update();
  // handle the creation and placement of particles being injected
  if (selectMode == NONE && mousePressed && !particleAmmo.isEmpty() && mouseX > controlsWidth) {
    Particle p = particleAmmo.remove(particleAmmo.size() - 1);
    // add a random distance, so the particle wiggles around its attraction point
    p.set(new Vec2D(mouseX + random(10), mouseY + random(10)));
    if (shootMode == SHOOT)
      p.place(new Vec2D(mouseX, mouseY));
    else if (shootMode == CELLS)
      physics.addBehavior(p.getRepulsiveForce());
    if (randomSize)
      p.setSize(SIZE_MIN + (int)random(SIZE_MAX));
    else
      p.setSize(particleSize);
    p.unlock();  // don't know why, but if we don't use this, the particle gets shot out from the mouse to the edge
    physics.addParticle(p);
    updateAmmoDisplay();
  } 
  else if (selectMode == RECT_SELECT && selectRect != null)
    selectRect.display(); // draw selection rectangle

//  for (VerletParticle2D p : physics.particles) {
//    Particle par = (Particle)p;
//    par.draw();
//  }
  drawParticles();
  for (Particle p : selected)
    p.drawSelected();

  controlP5.draw();
}

void loadParticleGun(int index) {
  particleAmmo.clear();
  PImage img = imgs[index%imgs.length];
  for (int x = 0; x < img.width; x += 10) {
    for (int y = 0; y < img.height; y += 10) {
      color c = img.pixels[y*img.width + x];
      // if it's close to the background color of black, it won't be seen anyway, so don't include it!
      if (c != 0 && abs(c + 33554432) > 15) { 
        Particle p = new Particle(x+ controlsWidth + ((width - controlsWidth)/2)-img.width/2, y+(height/2)-img.height/2, particleSize, c);
        particleAmmo.add(p);
      }
    }
  }
  Collections.shuffle(particleAmmo);  // randomize the pixel particles
}

/* Set the image display button to the image corresponding to the provided index */
void setButtonImage(int index) {
  PImage img = (PImage)imgs[index].get();
  Button imageButton = (Button)controlP5.controller("imageButton");
  img.resize(imageButton.getWidth(), imageButton.getHeight());
  controlP5.controller("imageButton").setImage(img);
}

/* This method is for the Display ListBox. Sets displayMode */
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup())
    displayMode = (int)theEvent.group().value();
}

void particleSize(float value) {
  particleSize = (int)value;
}

void random(boolean value) {
  randomSize = value;
}

void select(int value) {
  selectMode = SELECT;
  selectButton.activate();
}

void rectSelect(int value) {
  selectMode = RECT_SELECT;
  selectRect = null;
  rectButton.activate();
}

void mouseAttract(int value) {
  selectMode = MOUSE_ATTRACT;
  attractButton.activate();
}

void shoot(int value) {
  if (shootMode == CELLS)
    setCell(false);
  if (shootMode != SHOOT)
    setFreeShoot(true);
  selectMode = NONE;
  shootMode = SHOOT;
  shootButton.activate();
}

void grid(int value) {
  if (shootMode == CELLS)
    setCell(false);
  if (shootMode != GRID)
    setGrid(true);
  selectMode = NONE;
  shootMode = GRID;
  gridButton.activate();
}

void cells(int value) {
  setGrid(true);
  if (shootMode != CELLS)
    setCell(true);
  selectMode = NONE;
  shootMode = CELLS;
  cellButton.activate();
}

/* Toggle the mode for particle placement to Free Shoot Mode.
 * Setting this to true will move all particles to their location saved previously in this mode.
 */
void setFreeShoot(boolean value) {
  for (VerletParticle2D p : physics.particles)
    ((Particle)p).togglePlacementForce(value);
  for (Particle p : particleAmmo)
    p.togglePlacementForce(value);
}

/* Toggle the mode for particle placement to Grid Mode.
 * Setting this to true will move all particles to their location saved previously in this mode.
 */
void setGrid(boolean value) {
  for (VerletParticle2D p : physics.particles)
    ((Particle)p).toggleGridForce(value);
  for (Particle p : particleAmmo)
    p.toggleGridForce(value);
}

/* Toggle the repulsion force of all displayed particles.
 * Used for Cell Mode.
 */
void setCell(boolean value) {  
  if (value) {
    for (VerletParticle2D p : physics.particles)
      physics.addBehavior(((Particle)p).getRepulsiveForce());
    physics.addBehavior(mouseAttractor);
  } 
  else {
    for (VerletParticle2D p : physics.particles)
      physics.removeBehavior(((Particle)p).getRepulsiveForce());
    if (mouseAttractor != null)
      physics.removeBehavior(mouseAttractor);
  }
}

/* Set the repulsion strength of all particles.
 * Only has an effect if in Cell Mode.
 */
void repulsionStrength(float value) {
  repulsionStrength = -value;
  for (VerletParticle2D p : physics.particles)
    ((Particle)p).getRepulsiveForce().setStrength(repulsionStrength);
  for (Particle p : particleAmmo)
    p.getRepulsiveForce().setStrength(repulsionStrength);
}

void imageButton(int value) {
  setButtonImage(++imgIndex%imgs.length);
  reset(0);
}

/* Resets the canvas by removing all particles, reloading the ammo,
 * resetting the shoot mode to grid, and doing some housekeeping
 */
void reset(int value) {
  for (VerletParticle2D p : physics.particles)
    physics.removeBehavior(((Particle)p).getRepulsiveForce());
  physics.clear();
  selected.clear();
  // by default, the shoot mode is grid, and there is no selection mode.
  grid(0);
  selectMode = NONE;
  mouseAttractor.setAttractor(new Vec2D(width/2, height/2));
  loadParticleGun(imgIndex);
  updateAmmoDisplay();
}

void mousePressed() {
  // if the mouse is pressed outside of the world, do nothing.
  if (mouseX <= controlsWidth)
    return;
    
  mousePos = new Vec2D(mouseX, mouseY);
  switch(selectMode) {
  case MOUSE_ATTRACT :
    physics.removeBehavior(mouseAttractor);
    // create a new positive attraction force field around the mouse position (radius=250px)
    mouseAttractor.setAttractor(mousePos);
    physics.addBehavior(mouseAttractor);
    break;

  case SELECT :
    Particle clicked = particleClicked();
    if (clicked != null) {
      if (isDoubleClick()) { // double click selects all particles
        for (VerletParticle2D inP : physics.particles)
          selected.add((Particle)inP);
      } 
      else { // if it's not a double click, just select the clicked particle
        // only deselect all particles if the shift button is not held, or if the clicked particle is not already selected
        if (!(keyPressed && key == CODED && keyCode == SHIFT || selected.contains(clicked)))
          selected.clear();
        selected.add(clicked);
      }
    } 
    else
      selected.clear(); // no particles close enough to select. clear selected.
    for (Particle p : selected)
      p.setVecToMouse(mousePos); // for dragging multiple particles.  remember location relative to the mouse click
    break;

  case RECT_SELECT :
    rectMode = selectRect == null ? NONE : selectRect.getRectMode();
    if (rectMode == NONE) {
      selectRect = new SelectRect();
      selected.clear();
    } 
    else {
      scaleRect = selectRect.copy();
      for (Particle p : selected)
        p.setUnscaled();
      if (rectMode == TRANSPOSE)
        selectRect.anchorMouse(mousePos);
    }
  } // end switch
  lastClickTime = millis();
}

void mouseDragged() {
  if (controlP5.window(this).isMouseOver())
    return;
  switch(selectMode) {
  case MOUSE_ATTRACT :
    // update mouse attraction focal point
    mousePos.set(mouseX, mouseY);
    break;

  case SELECT :
    if (shootMode == GRID)
      for (Particle p : selected)
        p.setGridLoc(new Vec2D(mouseX, mouseY));
    else if (shootMode == SHOOT)
      for (Particle p : selected)
        p.place(new Vec2D(mouseX, mouseY));
    break;

  case RECT_SELECT :
    selectRect.update();
    if (rectMode == TRANSPOSE || rectMode == DRAG) {
      for (Particle p : selected)
        p.scale();
    } 
    else {
      selected.clear();
      selected.addAll(selectRect.particlesInside());
    }
  }
}

void mouseReleased() {
  // remove the mouse attraction when button has been released
  if (shootMode != CELLS && !controlP5.window(this).isMouseOver())
    physics.removeBehavior(mouseAttractor);
  for (Particle p : selected)
    p.setVecToMouse(ORIGIN);
  rectMode = NONE;
}

void keyPressed() {
  if (key == DELETE || keyCode == 8) {
    for (Particle p : selected) {
      // reset the vector used for dragging so that the particle doesn't go to a wierd place in free shoot mode
      p.setVecToMouse(p);
      particleAmmo.add(p); // put the particle back into the ammo
      Collections.shuffle(particleAmmo); // reshuffle the ammo
      physics.removeParticle(p); // remove it from the screen
      updateAmmoDisplay(); //reflect the new ammo in the display bar
    }
    selected.clear();
  }
}
/*
* Returns true if the time between the last click and the current time
 * is less than the global DOUBLE_CLICK_TIME
 */
boolean isDoubleClick() {
  if (millis() - lastClickTime < DOUBLE_CLICK_TIME)
    return true;
  return false;
}

/*
* Updates the ammo progress bar to show how many particles are
 * still in stock to shoot onto the canvas
 */
void updateAmmoDisplay() {
  controlP5.controller("ammo").setValue((float)particleAmmo.size()/(particleAmmo.size() + physics.particles.size()));
}

Particle particleClicked() {
  for (VerletParticle2D p : physics.particles)
    if (p.distanceToSquared(mousePos) < SNAP_DIST_SQUARED)
      return (Particle)p;
  return null;
}

