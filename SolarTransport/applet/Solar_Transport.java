import processing.core.*; 
import processing.xml.*; 

import toxi.geom.*; 
import controlP5.*; 

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

public class Solar_Transport extends PApplet {

/**
 Solar Transport
 @author Karl Hiner w/ code from John Gilbertson
 */

//Mercury:
//Radius: 2,450 km
//Period: 0.387
//Ellipse e: 0.206
//Mass: 3.30*10^23
//Path Angle: 3.38 degrees
//
//Venus:
//Radius: 6,050 km
//Period: 0.723
//Ellipse e: 0.007
//Mass: 4.87*10^24
//Path Angle: 3.86 degrees
//
//Earth:
//Radius: 6,400 km
//Period: 1
//Ellipse e: 0.017
//Mass: 5.97*10^24
//Path Angle: 7.155 degrees
//
//Mars:
//Radius: 3,400 km
//Period: 1.881
//Ellipse e: 0.093
//Mass: 6.42*10^23
//Path Angle: 5.65 degrees
//
//Jupiter:
//Radius: 71,500 km
//Period: 11.857
//Ellipse e: 0.048
//Mass: 1.90*10^27
//Path Angle: 6.09 degrees
//
//Saturn:
//Radius: 63,500 km
//Period: 29.42
//Ellipse e: 0.056
//Mass: 5.69*10^26
//Path Angle: 5.51 degrees
//
//Uranus:
//Radius: 24,973 km
//Period: 83.75
//Ellipse e: 0.046
//Path Angle: 6.48 degrees
//
//Radius of Sun: 700,000 km
//Mass of Sun: 1.98892 \u00d7 10^30 kg
//Read more: http://wiki.answers.com/Q/What_is_the_distance_of_all_planets_from_the_sun#ixzz1LwdqB0Qt




PGraphics cp5;
ControlP5 controlP5;
MultiList pathList;
MultiListButton s, d;
Textarea helpText;
final int AU = 149598000; // Astronomical Unit, in km
final int SCALE_FACTOR = 1200000000;  // for scale factor, use the distance of farthest planet/1 million + some view room
final int SNAP_DIST = 5;  // used for distance comparisons, ei. when rocket hits destination, or when mouse if over orbit
final int RED = color(255, 0, 0);
int animateStart = 0;  // keep track of time for the balloon effect when planets are reached by the rocket
float SIM_SPEED = .02f;  // controls the speed of all things
float ROCKET_SPEED = 100;
float rotateXVal = 0;
float rotateYVal = 0;
float rotateCamX = 0;
float rotateCamZ = 0;
float camZoom = 20;
float zoom = -200;
boolean showOrbits = true;
boolean showPlanets = true;
boolean showLagrange = false;
Vec3D cameraVec = new Vec3D(0, 0, 0);
BodyGraph bodyGraph = new BodyGraph();
Body followBody = null;
Rocket rocket = null;
Planet[] planets = new Planet[8]; // holds all planets, including the sun

public void setup()
{
  size(800, 500, P3D);
  controlP5 = new ControlP5(this);
  sphereDetail(18); // arelatively low sphere detail for faster rendering
  ellipseMode(RADIUS);
  // mouse Wheel
  addMouseWheelListener(new java.awt.event.MouseWheelListener() {  
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) {
      if (evt.getWheelRotation()<0) {
        if (zoom < 400)
          //zoom in slower the slower the zoom is
        zoom+=evt.getScrollAmount()+Math.abs(zoom*.1f);
        if (camZoom > 10)
          camZoom -= evt.getScrollAmount();
      }  
      else {
        if (zoom > -10000)
          //zoom out faster the farther the zoom is
        zoom-=evt.getScrollAmount() + Math.abs(zoom*.1f);
        if (camZoom < 100)
          camZoom += evt.getScrollAmount();
      }
    }
  }
  ); 

  planets[0] = new Planet("sun", 700000, 0, 0, 0, 0, color(255, 255, 10));
  planets[1] = new Planet("mercury", 2450, 0.386f, 0.206f, 0, 3.38f, color(180, 180, 180));
  planets[2] = new Planet("venus", 6050, 0.723f, 0.007f, 0, 3.86f, color(100, 100, 255));
  planets[3] = new Planet("earth", 6400, 1, 0.017f, 0, 7.155f, color(128, 255, 128));
  planets[4] = new Planet("mars", (float)3400, 1.881f, 0.093f, (float)0, 5.65f, color(255, 100, 100));
  planets[5] = new Planet("jupiter", 71500, 11.857f, 0.048f, 0, 6.09f, color(200, 150, 00));
  planets[6] = new Planet("saturn", 63500, 29.42f, 0.056f, 0, 5.51f, color(200, 200, 50));
  planets[7] = new Planet("uranus", 24973, 83.75f, 0.046f, 0, 6.48f, color(150, 140, 140));
  controlP5.addSlider("sunSize", 1, 50, 20, 5, 5, 50, 10).setLabel("Sun Size");
  controlP5.addSlider("planetSize", 1, 2000, 1000, 5, 20, 50, 10).setLabel("Planet Size");
  controlP5.addSlider("rocketSize", 0, 1, .5f, 5, 35, 50, 10).setLabel("Rocket Size");
  controlP5.addSlider("speed", 0, .05f, SIM_SPEED, 5, 50, 50, 10);
  controlP5.addToggle("orbits", true, 5, 65, 10, 10);
  controlP5.addToggle("planets", true, 40, 65, 10, 10);
  controlP5.addToggle("lagrange", false, 75, 65, 10, 10);
  //controlP5.addToggle("help", true, 75, 65, 10, 10);
  controlP5.addButton("ITN", 0, 20, height - 70, 50, 25).setLabel("   ITN");
  controlP5.addButton("hohmann", 1, 20, height - 40, 50, 25);
  controlP5.addTextarea("helpText", "Hold and drag mouse to change view.\n" + 
    "Mouse Scroll to zoom in/out.\n" + 
    "Click an orbit to follow path.", 
  width - 150, 10, 150, 40);
  controlP5.addSlider("itnProgress", 0, 1, 0, 5, height - 70, 10, 60).setLabelVisible(false);
  pathList = controlP5.addMultiList("pathList", 5, height - 100, 70, 10);
  s = pathList.add("source", 0);
  d = pathList.add("destination", 1);
  for (int i = 1; i < planets.length; ++i) {
    s.add("source", i).setLabel(planets[i].name);
    d.add("dest", i).setLabel(planets[i].name);
  }
  pathList.subelements().get(0).setLabel("from: mercury");
  pathList.subelements().get(1).setLabel("to: jupiter");
  // set up the graph by letting each planet know which planet is next after it
  for (int i = 1; i < planets.length - 1; ++i)
    planets[i].setupGraph(planets[i+1]);
  // uranus has no planet past it
  planets[planets.length - 1].setupGraph(null);
  rocket = new Rocket(planets[3], planets[5]); // create rocket set with path earth-jupiter
  source(3);
  dest(5);
  // we use this graphics object to hack around the blurry look of ControlP5 in PD3
  cp5 = createGraphics(width, height, P2D);
  // start with a pleasing point of view :)
  rotateXVal = .5f;
  rotateYVal = .5f;
  zoom = -10;
  controlP5.controller("sunSize").trigger();
  controlP5.controller("planetSize").trigger();
  controlP5.controller("rocketSize").trigger();
}

public void draw()
{ 
  // record the controlP5 elements to draw later, since they look blurry otherwise w/ PD3
  beginRecord(cp5);
  controlP5.draw();
  endRecord();
  lights();
  background(0);
  if (followBody != null) {
    if (mousePressed) {
      rotateCamX = map(width/2 - mouseX, -width/2, width/2, -PI*.8f, PI*.8f);
      rotateCamZ = (height/2 - mouseY)*.1f;
    }
    cameraVec = followBody.getRotated(rotateCamX).normalize().scale(camZoom).to3DXY();
    camera(followBody.x() + cameraVec.x(), followBody.y() + cameraVec.y(), rotateCamZ, followBody.x(), followBody.y(), 0, 0, 0, -1);
    mainDisplay();
    camera();
  } 
  else {
    pushMatrix();
    translate(width/2, height/2, zoom);
    if (mousePressed) {
      rotateYVal = ((float)mouseX/width+0.5f)*PI;
      rotateXVal = ((float)mouseY/height+0.5f)*PI;
    }
    rotateX(rotateXVal);
    rotateY(rotateYVal);
    mainDisplay();
    popMatrix();
  }
  image(cp5, 0, 0); // draw ControlP5 stuff.
  ++frameCount;
}

public void mainDisplay() {
  for (Planet p : planets) {
    p.tick();
    p.display();
  }
  if (controlP5.controller("ITN").isMouseOver() || rocket.waitingITN)
    rocket.previewITN();
  else if (controlP5.controller("hohmann").isMouseOver() || rocket.waitingHohmann)
    rocket.previewHohmann();
  rocket.update();
}

public void mouseClicked() {
  if (!controlP5.window(this).isMouseOver())
    followBody = getFollowBody();

  if (rocket.follow) {
    followBody = rocket;
    camZoom = 50;
    rotateCamZ = 50;
  }
}

public Body getFollowBody() {
  for (Planet p : planets)
    if (!p.equals(planets[0]) && p.follow)
      return p;
  return null;
}

public void sunSize(float value) {
  planets[0].setSizeFactor(value);
}

public void planetSize(float value) {
  for (Planet p : planets) {
    if (p != planets[0])
      p.setSizeFactor(value);
  }
}

public void rocketSize(float value) {
  rocket.setSize(value);
}

public void speed(float value) {
  SIM_SPEED = value;
}

public void orbits(boolean value) {
  showOrbits = value;
}

//void help(boolean value) {
//	controlP5.controller("helpText").setVisible(value);
//}

public void planets(boolean value) {
  showPlanets = value;
}

public void lagrange(boolean value) {
  showLagrange = value;
}

public void ITN(int value) {
  resetProgress();
  rocket.waitITN();
}

public void hohmann(int value) {
  resetProgress();
  rocket.waitHohmann();
}

public void source(int value) {
  s.setLabel("from: " + planets[value].name);
  rocket.setSource(planets[value]);
}

public void dest(int value) {
  d.setLabel("to: " + planets[value].name);
  rocket.setDest(planets[value]);
}

public void setProgress(float value) {
  if (value > controlP5.controller("itnProgress").getValue())
    controlP5.controller("itnProgress").setValue(value);
}

public void resetProgress() {
  controlP5.controller("itnProgress").setValue(0);
}

public Stack<Body> getPath(Body source, Body dest) {
  return bodyGraph.dijkstra(source, dest);
}

public Body getSmallestDist(ArrayList<Body> vertices) {
  Body smallest = vertices.get(0);
  for (Body b : vertices) {
    if (b.distance < smallest.distance)
      smallest = b;
  }
  return smallest;
}

class Body extends Vec2D {
  float distance = 0; // used to hold distance from source for Dijstra's Path Algorithm
  Body prev = null; // used to hold previous Body for Dijstra's Path Algorithm
  Planet parent = null;
  float mySize;
  float displaySize;
  int lNum = 0;
  String name;
  boolean animate = false;
  boolean follow = false;
  int animateStart = 0;
  int myColor;
  float ellipseE;
  float ellipseA;
  float ellipseB;
  float ellipseCenter;
  float orbit_speed;
  float pathAngle;

  Body() { 
    super(0, 0);
  } // the compiler needs this for default.  never used explicitly

  Body(String name, float sz) {
    super(0, 0);
    this.name = name;
    mySize = map(sz, 0, SCALE_FACTOR, 0, width/2);
    displaySize = mySize;
  }

  Body(Planet parent, String name, float sz, int lNum) {
    this(name, sz);
    this.parent = parent;
    this.lNum = lNum;
    myColor = RED;  // Lagrange points are displayed as red spheres
  }

  public void display() {
    if (animate) {
      if (frameCount - animateStart < 10)
        ++displaySize;
      else if (frameCount - animateStart < 20)
        --displaySize;
      else
        animate = false;
    }
    fill(myColor);
    translate(x, y, 0);
    sphere(displaySize);
    translate(-x, -y, 0);
  }
  public Vec2D getProjectedDest(Body dest) {
    for (int t = 1; t < 10000; ++t) {
      Vec2D projectedDest = dest.locationAtTime(t);
      Vec2D projectedVelocity = projectedDest.sub(this).normalize().scale(ROCKET_SPEED);
      if (add(projectedVelocity.scale(t).scale(SIM_SPEED)).distanceTo(projectedDest) < 5)
        return projectedDest;
    }
    return null;
  }

  public void setSize(float sz) { 
    displaySize = sz;
  }
  // Get the time that the rocket would take to arrive at dest, starting
  // from this body, taking into account where these two bodies will
  // actually be at startTime, and the movement of the destination body
  public int getArrivalTimeITN(Body dest, int startTime) {
    Vec2D realLoc = locationAtTime(startTime);  // Where is this body at startTime?
    for (int t = startTime; t < startTime + 10000; ++t) {
      Vec2D projectedDest = dest.locationAtTime(t);  // Where will dest be at time t?
      // Get the direction of travel for the rocket to get there:
      Vec2D projectedVelocity = projectedDest.sub(realLoc).normalize().scale(ROCKET_SPEED);
      // Simulate travelling for (t - startTime), and see if the rocket ends up at the destination:
      if (realLoc.add(projectedVelocity.scale(t - startTime).scale(SIM_SPEED)).distanceTo(projectedDest) < 5)
        return t;  // Return the total time.
    }
    return Integer.MAX_VALUE;
  }

  public boolean mouseOver() {
    return dist(screenX(x, y, 0), screenY(x, y, 0), mouseX, mouseY) < SNAP_DIST*2;
  }

  public void animate() {
    animate = true;
    animateStart = frameCount;
  }

  public Vec2D locationAtTime(int steps) {
    switch(lNum) {
    case 0: 
      return new Vec2D(ellipseCenter + ellipseA*sin(angleAtTime(steps)), ellipseB*cos(angleAtTime(steps)));
    case 1: 
      return parent.locationAtTime(steps).scale(.95f);
    case 2: 
      return parent.locationAtTime(steps).scale(1.15f);
    case 3: 
      return parent.locationAtTime(steps).getRotated(PI);
    case 4: 
      return parent.locationAtTime(steps).getRotated(PI/3);
    case 5: 
      return parent.locationAtTime(steps).getRotated(-PI/3);
    default: 
      return null;
    }
  }

  public float angleAtTime(int steps) {
    return pathAngle + steps*orbit_speed*SIM_SPEED;
  }

  public Vec2D locationAtAngle(float angle) {
    return new Vec2D(ellipseCenter + ellipseA*cos(angle), ellipseB*sin(angle));
  }
}

class BodyGraph implements Iterable<Body>, Iterator<Body>
{
  private ArrayList<Body> vertices = new ArrayList<Body>();
  private ArrayList<Edge> edges = new ArrayList<Edge>();

  class Edge
  {
    public final Body node1, node2;
    // no weight, since the distances are dynamic

    public Edge(Body node1, Body node2) {
      this.node1 = node1;
      this.node2 = node2;
    }

    public Body getNeighbor(Body body) {
      if (body.equals(node1))
        return node2;
      else if (body.equals(node2))
        return node1;
      else
        return null;
    }
  }

  public void addVertex(Body node) {
    vertices.add(node);
  }

  public void addEdge(Body node1, Body node2) {
    edges.add(new Edge(node1, node2));
  }

  public ArrayList<Body> getNeighbors(Body body) {
    ArrayList<Body> neighbors = new ArrayList<Body>();
    for (Edge edge : edges) {
      Body neighbor = edge.getNeighbor(body);
      if (neighbor != null)
        neighbors.add(neighbor);
    }
    return neighbors;
  }

  public Body get(String name) {
    for (Body b : vertices)
      if (b.name.equals(name))
        return b;
    return null;
  }

  public ArrayList<Body> vertices() { 
    return (ArrayList)vertices;
  }

  public Iterator iterator() {
    return vertices.iterator();
  }

  public Body next() {
    return vertices.iterator().next();
  }

  public boolean hasNext() {
    return vertices.iterator().hasNext();
  }

  public void remove() {
    throw new UnsupportedOperationException();
  }

  public boolean isEmpty() {
    return vertices.isEmpty();
  }

  // Dijkstra's Algorithm finds a shortest path from point a to point b.
  public Stack<Body> dijkstra(Body a, Body b) {
    ArrayList<Body> vertices = (ArrayList)bodyGraph.vertices().clone();
    for (Body ver : vertices) {
      ver.distance = Float.MAX_VALUE;
      ver.prev = null;
    }
    a.distance = 0;
    while (!vertices.isEmpty ()) {
      Body body = getSmallestDist(vertices);
      if (body.distance == Float.MAX_VALUE)
        break;
      vertices.remove(body);
      for (Body neighbor : bodyGraph.getNeighbors(body)) {
        if (vertices.contains(neighbor)) {
          float altDist = body.distance + body.distanceTo(neighbor);//body.getArrivalTimeITN(neighbor, body.time);
          if (altDist < neighbor.distance) {
            neighbor.distance = altDist;
            neighbor.prev = body;
          }
        }
      }
    }
    // Hold the path in a stack.
    Stack<Body> path = new Stack<Body>();
    while (b.prev != null) {
      path.push(b);
      b = b.prev;
    }
    path.push(a); // Add the starting location.
    return (Stack)path.clone();
  }
}

class Planet extends Body
{
  float angle_to_ecliptic;

  Body[] lagranges = new Body[5];

  Planet(String name, float sz, float ellipseA, float ellipseE, float pathAngle, float angle_to_ecliptic, int theColor) {
    super(name, sz);
    for (int i = 0; i < lagranges.length; ++i) {
      lagranges[i] = new Body(this, name + "l" + (i + 1), sz, i + 1);
      lagranges[i].setSize(mySize);
      bodyGraph.addVertex(lagranges[i]);
    }
    this.ellipseA = map(ellipseA*AU, 0, SCALE_FACTOR, 0, width/2);
    this.ellipseE = ellipseE;
    ellipseCenter = this.ellipseA*ellipseE;
    ellipseB = (float)(this.ellipseA*Math.sqrt(1-ellipseE*ellipseE));
    orbit_speed= (ellipseA == 0) ? 0 : 1.0f/ellipseA;
    this.angle_to_ecliptic = radians(angle_to_ecliptic);
    this.pathAngle = radians(pathAngle);
    myColor = theColor;
    update();
    bodyGraph.addVertex(this);
  }

  public void setupGraph(Planet next) {
    bodyGraph.addEdge(this, lagranges[0]);
    bodyGraph.addEdge(this, lagranges[1]);
    //            bodyGraph.addEdge(lagranges[0], lagranges[3]);
    //            bodyGraph.addEdge(lagranges[0], lagranges[4]);
    bodyGraph.addEdge(lagranges[1], lagranges[3]);
    bodyGraph.addEdge(lagranges[1], lagranges[4]);
    if (next != null)
      for (int i = 1; i < lagranges.length; ++i)
        for (int j = 0; j < lagranges.length; ++j)
          if (j != 1)
            bodyGraph.addEdge(lagranges[i], next.lagranges[j]);
  }

  public void display() {
    if (isMouseOverOrbit()) {
      strokeWeight(3);
      follow = true;
    } 
    else {
      strokeWeight(1);
      follow = false;
    }
    stroke(myColor);
    if (showOrbits) {
      noFill();
      ellipse(ellipseCenter, 0, ellipseA, ellipseB);
    }
    noStroke();
    if (showLagrange && !this.equals(planets[0]))
      showLagrange();
    if (showPlanets) {
      super.display();
    }
  }

  public void tick() {
    pathAngle += orbit_speed*SIM_SPEED;
    set(ellipseCenter + ellipseA*sin(pathAngle), ellipseB*cos(pathAngle));
    update();
  }

  public void update() {
    lagranges[0].set(scale(.95f));  // L1 is just in front of the planet
    lagranges[1].set(scale(1.15f)); // L2 is just behind the planet
    lagranges[2].set(getRotated(PI));  // L3 is almost exactly on the opposite side of the sun
    lagranges[3].set(getRotated(PI/3));  // L4 and L5 both form an equilateral
    lagranges[4].set(getRotated(-PI/3)); // triangle with the planet and the sun.
  }

  public boolean isMouseOverOrbit() {
    for (float i = 0; i < 2*PI; i += PI/(ellipseA)) {
      if (dist(screenX(ellipseCenter + ellipseA*sin(i), ellipseB*cos(i), 0), screenY(ellipseCenter + ellipseA*sin(i), ellipseB*cos(i), 0), mouseX, mouseY) < SNAP_DIST)
        return true;
    }
    return false;
  }

  public void setSizeFactor(float sizeFactor) {
    displaySize = mySize*sizeFactor;
    for (int i = 0; i < lagranges.length; ++i)
      lagranges[i].setSize(displaySize);
  }

  public void showLagrange() {
    // display all L-Points
    for (Body l : lagranges) {
      l.display();
    }
  }

  public Vec2D locationAtAngle(float angle) {
    return new Vec2D(ellipseCenter + ellipseA*sin(angle), ellipseB*cos(angle));
  }

  public float angle() {
    float angle = getNormalized().angleBetween(new Vec2D(1, 0));
    return y < 0 ? -(angle + PI) : (angle + PI);
  }
}

class Rocket extends Body
{
  Stack<Body> myPath;
  Vec2D prevLoc = null;
  Vec2D myVelocity;
  float currBest = Float.MAX_VALUE;
  boolean waitingITN = false;
  boolean launchITN = false;
  boolean waitingHohmann = false;
  boolean launchHohmann = false;
  float ellipseAngle = 0;

  Planet source, dest;

  Rocket(Planet source, Planet dest) {
    name = "rocket";
    myColor = color(130);
    this.source = source;
    this.dest = dest;
    displaySize = .5f;
    updateHohmann();
  }

  public void display() {
    if (mouseOver()) {
      myColor = color(200);
      follow = true;
    } 
    else {
      myColor = color(130);
      follow = false;
    }
    noStroke();
    translate(x(), y(), 0);
    if (myVelocity != null)
      rotateZ(tan(myVelocity.y()/myVelocity.x()) - HALF_PI);
    fill(255, 160, 0);
    cylinder(1*displaySize, 1*displaySize, 15);
    translate(0, 1*displaySize, 0);
    fill(RED);
    cylinder(2*displaySize, 2*displaySize, 15);
    fin(displaySize, -PI/6);
    fin(displaySize, -5*PI/6);
    fin(displaySize, HALF_PI);
    translate(0, 8*displaySize, 0);
    fill(myColor);
    cylinder(3*displaySize, 16*displaySize, 15);
    translate(0, 8*displaySize, 0);
    rotateX(-PI/2);
    cone(0, 0, 3*displaySize, 3*displaySize);
  } 

  public void update() {
    if (!(launchHohmann || launchITN))
      set(source);
    if (waitingITN) {
      if (frameCount % 3 == 0 && itnLaunchWindow()) {
        waitingITN = false;
        launchITN = true;
      }
    } 
    else if (waitingHohmann) {
      if (hohmannLaunchWindow()) {
        waitingHohmann = false;
        prevLoc = source;
        launchHohmann = true;
        pathAngle = -HALF_PI;
      }
    } 
    else if (launchITN)
      tickITN();
    else if (launchHohmann)
      tickHohmann();
  }


  public Vec2D getITNVelocity(Body dest) {
    for (int t = 1; t < 10000; ++t) {
      Vec2D projectedDest = dest.locationAtTime(t);
      Vec2D projectedVelocity = projectedDest.sub(this).normalize().scale(ROCKET_SPEED);
      if (add(projectedVelocity.scale(t).scale(SIM_SPEED)).distanceTo(projectedDest) < 5)
        return projectedVelocity;
    }
    return null;
  }

  public void waitITN() {
    waitingITN = true;
    launchITN = false;
    launchHohmann = false;
    waitingHohmann = false;
    myPath = getPath(source, dest);
    currBest = dest.distance;
  }

  public void waitHohmann() {
    waitingHohmann = true;
    launchHohmann = false;
    launchITN = false;
    waitingITN = false;
  }

  public void setSize(float newSize) { 
    displaySize = newSize;
  }

  public void setSource(Planet source) {
    this.source = source;
    if (waitingITN)
      ITN(0);
  }

  public void setDest(Planet dest) {
    this.dest = dest;
    if (waitingITN)
      ITN(0);
  }

  public void previewITN() {
    if (!launchITN && !waitingITN)
      myPath = getPath(source, dest);
    Body[] pathList = myPath.toArray(new Body[myPath.size()]);
    if (pathList.length == 0)
      return;
    noFill();
    stroke(color(255, 0, 0));
    beginShape();
    vertex(pathList[pathList.length - 1].x(), pathList[pathList.length - 1].y());
    for (int i = pathList.length - 1; i > 0; --i) {
      Vec2D between = pathList[i - 1].sub(pathList[i]).scale(.5f);
      float angleC1 = i % 2 == 0 ? PI/4 : -PI/4;
      Vec2D c1 = pathList[i].add(between.rotate(angleC1));
      Vec2D c2 = pathList[i-1].add(between.rotate(angleC1*2));
      bezierVertex(c1.x(), c1.y(), c2.x(), c2.y(), pathList[i-1].x(), pathList[i-1].y());
    }
    endShape();
  }

  public void previewHohmann() {
    if (!(launchHohmann))
      updateHohmann();
    noFill();
    stroke(color(255, 0, 0));
    strokeWeight(2);
    rotateZ(ellipseAngle);
    // For preview, draw a dashed ellipse:
    beginShape(LINES);
    for (float i = 0; i < TWO_PI; i += PI/25)
      vertex(ellipseCenter + ellipseA*sin(i), ellipseB*cos(i));
    endShape();
    rotateZ(-ellipseAngle);
  }

  public void updateHohmann() {
    float angle = getNormalized().angleBetween(new Vec2D(1, 0));//source.angle();
    angle = (y < 0) ? angle - HALF_PI : -angle - HALF_PI;
    ellipseA = source.distanceTo(dest.locationAtAngle(angle))/2;
    ellipseE = 1 - source.distanceTo(planets[0])/ellipseA;
    ellipseB = (float)(ellipseA*Math.sqrt(1-ellipseE*ellipseE));
    orbit_speed = 1/map(ellipseA/AU, 0, width/2, 0, SCALE_FACTOR);
    ellipseCenter = ellipseA*ellipseE;
    pathAngle = source.angle();
    ellipseAngle = pathAngle;
  }

  public void tickITN() {
    //if (myVelocity == null)
    myVelocity = getITNVelocity(myPath.peek());
    set(add(myVelocity.scale(SIM_SPEED)));
    if (distanceTo(myPath.peek()) < SNAP_DIST) {
      myPath.pop().animate();
      if (!myPath.isEmpty())
        myVelocity = getITNVelocity(myPath.peek());
      else {
        launchITN = false;
        if (followBody == this)
          followBody = dest;
        resetProgress();
      }
    }
    display();
  }

  public void tickHohmann() {
    pathAngle += orbit_speed*SIM_SPEED;
    Vec2D nextLoc = new Vec2D(ellipseCenter + ellipseA*sin(pathAngle), ellipseB*cos(pathAngle)).getRotated(ellipseAngle);
    Vec2D projected = locationAtAngle(0).rotate(ellipseAngle);
    myVelocity = projected.y > 0 ? projected.rotate(PI/2) : projected;
    prevLoc = new Vec2D(this);
    set(nextLoc);
    if (distanceTo(dest) < SNAP_DIST*2) {
      dest.animate();
      launchHohmann = false;
      if (followBody == this)
        followBody = dest;
      resetProgress();
    }
    display();
  }

  public boolean itnLaunchWindow() {
    float goal = source.distanceTo(dest);
    myPath = getPath(source, dest);
    if (dest.distance < currBest)
      currBest = dest.distance;
    setProgress(map(goal/currBest, .8f, 1, 0, 1));
    return (currBest <= goal);
  }

  public boolean hohmannLaunchWindow() {
    Vec2D destProject = dest.locationAtTime((int)(PI/(orbit_speed*SIM_SPEED)));
    float distance = locationAtAngle(0).getRotated(pathAngle).distanceTo(destProject);
    float goal = SNAP_DIST*2;
    setProgress(goal/distance);
    return distance <= goal;
  }
}

/**
 cone taken from http://wiki.processing.org/index.php/Cone
 @author Tom Carden
 */

/**
 cylinder taken from http://wiki.processing.org/index.php/Cylinder
 @author matt ditton
 */

public void cylinder(float w, float h, int sides)
{
  float angle;
  float[] x = new float[sides+1];
  float[] z = new float[sides+1];

  //get the x and z position on a circle for all the sides
  for (int i=0; i < x.length; i++) {
    angle = TWO_PI / (sides) * i;
    x[i] = sin(angle) * w;
    z[i] = cos(angle) * w;
  }

  //draw the top of the cylinder
  beginShape(TRIANGLE_FAN);

  vertex(0, -h/2, 0);

  for (int i=0; i < x.length; i++) {
    vertex(x[i], -h/2, z[i]);
  }

  endShape();

  //draw the center of the cylinder
  beginShape(QUAD_STRIP); 

  for (int i=0; i < x.length; i++) {
    vertex(x[i], -h/2, z[i]);
    vertex(x[i], h/2, z[i]);
  }

  endShape();

  //draw the bottom of the cylinder
  beginShape(TRIANGLE_FAN); 

  vertex(0, h/2, 0);

  for (int i=0; i < x.length; i++) {
    vertex(x[i], h/2, z[i]);
  }

  endShape();
}

static float unitConeX[];
static float unitConeY[];
static int coneDetail;

static {
  coneDetail(24);
}

// just inits the points of a circle, 
// if you're doing lots of cones the same size 
// then you'll want to cache height and radius too
public static void coneDetail(int det) {
  coneDetail = det;
  unitConeX = new float[det+1];
  unitConeY = new float[det+1];
  for (int i = 0; i <= det; i++) {
    float a1 = TWO_PI * i / det;
    unitConeX[i] = (float)Math.cos(a1);
    unitConeY[i] = (float)Math.sin(a1);
  }
}

// places a cone with it's base centred at (x,y),
// height h in positive z, radius r.
public void cone(float x, float y, float r, float h) {
  pushMatrix();
  translate(x, y);
  scale(r, r);
  beginShape(TRIANGLES);
  for (int i = 0; i < coneDetail; i++) {
    vertex(unitConeX[i], unitConeY[i], 0.0f);
    vertex(unitConeX[i+1], unitConeY[i+1], 0.0f);
    vertex(0, 0, h);
  }
  endShape();
  popMatrix();
}

// Draw a rocket fin with size sz, and given angle relative to Y Axis
public void fin(float sz, float angle) {
  pushMatrix();
  scale(sz);
  rotateY(angle);
  beginShape();
  vertex(0, 6);
  vertex(4.2f, 0);
  vertex(9, 0);
  vertex(5, 6);
  endShape(CLOSE);
  popMatrix();
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--stop-color=#cccccc", "Solar_Transport" });
  }
}
