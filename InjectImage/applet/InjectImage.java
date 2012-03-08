import processing.core.*; 
import processing.xml.*; 

import toxi.geom.*; 
import toxi.physics2d.behaviors.AttractionBehavior; 
import toxi.physics2d.behaviors.ParticleBehavior2D; 
import toxi.physics2d.*; 
import controlP5.*; 
import java.util.concurrent.*; 
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
float repulsionStrength = -1.2f;
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

public void setup() {
  size(800, 550, P2D); // P2D is much faster than the default JAVA2D
  controlP5 = new ControlP5(this);
  physics.setWorldBounds(new Rect(140, 10, width - 145, height - 15)); // physics world is constrained by the toolbar
  physics.setDrag(0.05f);
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
  controls = controlP5.addGroup("controls", 0, 0);
  controls.setBackgroundHeight(height);
  controls.setWidth(controlsWidth);
  controls.setBarHeight(15);
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
  displayList = controlP5.addListBox("displayList", 5, 215, 120, 40);
  displayList.setItemHeight(10);
  displayList.setLabel("Display Mode");
  // the values for the displayList items are their corresponing display modes.
  displayList.addItem("Circle", CIRCLE);
  displayList.addItem("Square", SQUARE);
  displayList.addItem("Confetti", CONFETTI);
  controlP5.addToggle("random", randomSize, 10, 385, 15, 15);
  controlP5.addSlider("particleSize", SIZE_MIN, SIZE_MAX, particleSize, 10, 260, 15, 110).setLabel("Particle Size");
  controlP5.addSlider("repulsionStrength", -2, 2, 1.2f, 80, 260, 15, 110).setLabel("repulsion");
  controlP5.addSlider("ammo", 0, 1, 1, 112, 430, 10, 80).valueLabel().setVisible(false);
  controlP5.controller("ammo").lock();
  controlP5.addButton("reset", 0, 30, 520, 50, 20).captionLabel().setFont(ControlP5.grixel);
  // due to a bug in ControlP5, we have to setLabel again after changing the font, or text gets cut off.
  controlP5.controller("reset").setLabel("reset");
  controlP5.addButton("imageButton", 1, 5, 430, 100, 80);
  setButtonImage(imgIndex);
}

public void draw() {
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

public void loadParticleGun(int index) {
  particleAmmo.clear();
  PImage img = imgs[index%imgs.length];
  for (int x = 0; x < img.width; x += 10) {
    for (int y = 0; y < img.height; y += 10) {
      int c = img.pixels[y*img.width + x];
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
public void setButtonImage(int index) {
  PImage img = (PImage)imgs[index].get();
  Button imageButton = (Button)controlP5.controller("imageButton");
  img.resize(imageButton.getWidth(), imageButton.getHeight());
  controlP5.controller("imageButton").setImage(img);
}

/* This method is for the Display ListBox. Sets displayMode */
public void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup())
    displayMode = (int)theEvent.group().value();
}

public void particleSize(float value) {
  particleSize = (int)value;
}

public void random(boolean value) {
  randomSize = value;
}

public void select(int value) {
  selectMode = SELECT;
  selectButton.activate();
}

public void rectSelect(int value) {
  selectMode = RECT_SELECT;
  selectRect = null;
  rectButton.activate();
}

public void mouseAttract(int value) {
  selectMode = MOUSE_ATTRACT;
  attractButton.activate();
}

public void shoot(int value) {
  if (shootMode == CELLS)
    setCell(false);
  if (shootMode != SHOOT)
    setFreeShoot(true);
  selectMode = NONE;
  shootMode = SHOOT;
  shootButton.activate();
}

public void grid(int value) {
  if (shootMode == CELLS)
    setCell(false);
  if (shootMode != GRID)
    setGrid(true);
  selectMode = NONE;
  shootMode = GRID;
  gridButton.activate();
}

public void cells(int value) {
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
public void setFreeShoot(boolean value) {
  for (VerletParticle2D p : physics.particles)
    ((Particle)p).togglePlacementForce(value);
  for (Particle p : particleAmmo)
    p.togglePlacementForce(value);
}

/* Toggle the mode for particle placement to Grid Mode.
 * Setting this to true will move all particles to their location saved previously in this mode.
 */
public void setGrid(boolean value) {
  for (VerletParticle2D p : physics.particles)
    ((Particle)p).toggleGridForce(value);
  for (Particle p : particleAmmo)
    p.toggleGridForce(value);
}

/* Toggle the repulsion force of all displayed particles.
 * Used for Cell Mode.
 */
public void setCell(boolean value) {  
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
public void repulsionStrength(float value) {
  repulsionStrength = -value;
  for (VerletParticle2D p : physics.particles)
    ((Particle)p).getRepulsiveForce().setStrength(repulsionStrength);
  for (Particle p : particleAmmo)
    p.getRepulsiveForce().setStrength(repulsionStrength);
}

public void imageButton(int value) {
  setButtonImage(++imgIndex%imgs.length);
  reset(0);
}

/* Resets the canvas by removing all particles, reloading the ammo,
 * resetting the shoot mode to grid, and doing some housekeeping
 */
public void reset(int value) {
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

public void mousePressed() {
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

public void mouseDragged() {
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

public void mouseReleased() {
  // remove the mouse attraction when button has been released
  if (shootMode != CELLS && !controlP5.window(this).isMouseOver())
    physics.removeBehavior(mouseAttractor);
  for (Particle p : selected)
    p.setVecToMouse(ORIGIN);
  rectMode = NONE;
}

public void keyPressed() {
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
public boolean isDoubleClick() {
  if (millis() - lastClickTime < DOUBLE_CLICK_TIME)
    return true;
  return false;
}

/*
* Updates the ammo progress bar to show how many particles are
 * still in stock to shoot onto the canvas
 */
public void updateAmmoDisplay() {
  controlP5.controller("ammo").setValue((float)particleAmmo.size()/(particleAmmo.size() + physics.particles.size()));
}

public Particle particleClicked() {
  for (VerletParticle2D p : physics.particles)
    if (p.distanceToSquared(mousePos) < SNAP_DIST_SQUARED)
      return (Particle)p;
  return null;
}


DrawThread[] drawThreads = new DrawThread[partitions];

class DrawThread extends Thread {
  int myPartition;

  DrawThread(int partition) { 
    myPartition = partition;
  }

  public void run() {
    // draw particles
    for (int i = myPartition*physics.particles.size()/partitions;
         i < (myPartition + 1)*physics.particles.size()/partitions; ++i) {
        Particle p = (Particle)physics.particles.get(i);
      p.draw();
      println("Drawing " + i);
    }
  }
}

public void drawParticles() {
//  for (int i = 0; i < drawThreads.length; ++i) {
//    drawThreads[i] = new DrawThread(i);
//    drawThreads[i].start();
//  }
//  for (int i = 0; i < drawThreads.length; i++) {
//    try {
//      drawThreads[i].join();
//    } 
//    catch (InterruptedException ignore) {
//    }
//  }
  for (VerletParticle2D vp : physics.particles) {
    Particle p = (Particle)vp;
    p.draw();
  }
}

class DrawPool extends Thread {
  ExecutorService threadPool;

  DrawPool(int partitions) {
    threadPool = Executors.newFixedThreadPool(partitions);
  }

  public void run() {
    for (int i = 0; i < partitions; ++i) {
      threadPool.execute(new DrawThread(i));
    }
  }
}

/* All Mode constants are held here. */

final int NONE = -1;
// select modes
final int SELECT = 0;
final int MOUSE_ATTRACT = 1;
final int RECT_SELECT = 2;
// shoot modes
final int SHOOT = 3;
final int GRID = 4;
final int CELLS = 5;
// display modes
final int CIRCLE = 6;
final int SQUARE = 7;
final int CONFETTI = 8;
// rect modes
final int TRANSPOSE = 9;
final int DRAG = 10;
int selectMode = NONE;
int shootMode = GRID;
int displayMode = CONFETTI;
int rectMode = NONE;
/* A wrapper around the ControlP5.Button class.
 * Conveniently holds the three images for default, mouseOver, and mouseClicked
 * Contains activate() and deactivate() functions
 */
class MyButton {
  PImage image1, image2, image3;
  Button button;
  
  MyButton(String name, int x, int y, String image1, String image2, String image3) {
    button = controlP5.addButton(name, 0, x, y, 59, 59);
    this.image1 = loadImage(image1);
    this.image2 = loadImage(image2);
    this.image3 = loadImage(image3);
    deactivate(); // deactivating sets the images to the default, unselected image set
  }
  
  /* Called when the button is clicked.
   * Sets the image to a grayed default, and cleared the selected particles.
   */
  public void activate() {
    if (activeButton != null)
      activeButton.deactivate();
    selected.clear();
    activeButton = this;
    button.setImages(image3, image2, image3);
  }
  
  /* Deactivate the button by returning its images to default */
  public void deactivate() {
    button.setImages(image1, image2, image3);
  }
}




class Particle extends VerletParticle2D {
  int myColor;
  int mySize;
  Vec2D unscaled;// the proper location of the particle in grid mode
  AttractionBehavior repulsiveForce, placementForce, gridForce;
  private Vec2D vecToMouse = ORIGIN; // used for dragging of multiple particles to keep the relative vector to mouse


  Particle(float x, float y, int sz, int c) {
    super(width/2, height/2);
    unscaled = new Vec2D(x, y);
    gridForce = new AttractionBehavior(unscaled.copy(), 1000, .2f);
    // by defauly, this particle "wants" to be in its grid location.
    placementForce = new AttractionBehavior(unscaled.copy(), 1000, .2f);
    setRepulsiveForce(20, repulsionStrength, .01f);
    addBehavior(gridForce);
    myColor = c;
    mySize = sz;
    setWeight(2);
  }

  public void place(Vec2D loc) {
    placementForce.setAttractor(loc.add(vecToMouse));
  }

  public void setGridLoc(Vec2D loc) {
    gridForce.setAttractor(loc.add(vecToMouse));
  }

  public void setVecToMouse(Vec2D mouseVec) {
    vecToMouse = this.sub(mouseVec);
  }

  public int getColor() { 
    return myColor;
  }
  public void setColor(int c) { 
    myColor = c;
  }
  public int getSize() { 
    return mySize;
  }
  public void setSize(int newSize) { 
    mySize = newSize;
  }

  public void togglePlacementForce(boolean value) {
    removeBehavior(gridForce);
    removeBehavior(placementForce);
    if (value)
      addBehavior(placementForce);
  }

  public void toggleGridForce(boolean value) {
    removeBehavior(gridForce);
    removeBehavior(placementForce);
    if (value)
      addBehavior(gridForce);
  }

  public void scale() {
    float newX = map(unscaled.x(), scaleRect.x, scaleRect.x + scaleRect.width, selectRect.x, selectRect.x + selectRect.width);
    float newY = map(unscaled.y(), scaleRect.y, scaleRect.y + scaleRect.height, selectRect.y, selectRect.y + selectRect.height);
    Vec2D newAttractor = new Vec2D(newX, newY);
    if (shootMode == SHOOT)
      placementForce.setAttractor(newAttractor);
    else if (shootMode == GRID)
      gridForce.setAttractor(newAttractor);
  }

  public void setUnscaled() {
    if (shootMode == SHOOT)
      unscaled = placementForce.getAttractor().copy();
    else if (shootMode == GRID)
      unscaled = gridForce.getAttractor().copy();
  }

  public void setRepulsiveForce(float range, float strength, float jitter) {
    repulsiveForce = new AttractionBehavior(this, range, strength, jitter);
  }

  public AttractionBehavior getRepulsiveForce() { 
    return repulsiveForce;
  }

  public void draw() {
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

  public void drawSelected() {
    noFill();
    stroke(255);
    strokeWeight(2);
    if (displayMode == SQUARE) // if the particle is square, draw a square around it
      rect(x - mySize/2, y - mySize/2, mySize + 2, mySize + 2);
    else // otherwise, for circles and confetti, draw a circle around it
    ellipse(x, y, mySize + 2, mySize + 2);
  }
}

/* The Selection Rectangle object */

class SelectRect extends Rect {
  Rect[] corners = new Rect[4];
  private Vec2D vecToMouse = ORIGIN;
  
  public int getRectMode() {
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
  public void display() {
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
  public void update() {
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
  public void updateCorners() {
    float dim = min(width/8, height/8);
    corners[0] = new Rect(getLeft(), getTop(), dim, dim); // top left
    corners[1] = new Rect(getRight() - dim, getTop(), dim, dim); // top right
    corners[2] = new Rect(getRight() - dim, getBottom() - dim, dim, dim); // bottom right
    corners[3] = new Rect(getLeft(), getBottom() - dim, dim, dim); // bottom left
  }
  
  /* If the mouse is within any corner, it is returned.
   * Otherwise, null is returned.
   */
  public int getCornerWithMouse() {
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
  public int getCornerCloseToMouse() {
    Vec2D mouseVec = new Vec2D(mouseX, mouseY);
    for (int i = 0; i < 4; ++i)
      if (corners[i] != null &&
          mouseVec.isInRectangle(new Rect(corners[i].x - 10, corners[i].y - 10,
                                          corners[i].width + 20, corners[i].height + 20)))
        return i;
    return -1;
  }     
  
  /* Returns a list of all the particles within the selection rect */
  public ArrayList<Particle> particlesInside() {
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
  public void anchorMouse(Vec2D mouseVec) {
    vecToMouse = getTopLeft().sub(mouseVec);
  } 
  
  public Vec2D getBottomLeft() {
    return new Vec2D(getLeft(), getBottom());
  }
  
  public Vec2D getTopRight() {
    return new Vec2D(getRight(), getTop());
  }
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--stop-color=#cccccc", "InjectImage" });
  }
}
