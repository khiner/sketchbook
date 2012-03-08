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
//Mass of Sun: 1.98892 × 10^30 kg
//Read more: http://wiki.answers.com/Q/What_is_the_distance_of_all_planets_from_the_sun#ixzz1LwdqB0Qt

import toxi.geom.*;
import controlP5.*;

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
float SIM_SPEED = .02;  // controls the speed of all things
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

void setup()
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
        zoom+=evt.getScrollAmount()+abs(zoom*.1);
        if (camZoom > 10)
          camZoom -= evt.getScrollAmount();
      }  
      else {
        if (zoom > -10000)
          //zoom out faster the farther the zoom is
        zoom-=evt.getScrollAmount() + Math.abs(zoom*.1);
        if (camZoom < 100)
          camZoom += evt.getScrollAmount();
      }
    }
  }
  ); 

  planets[0] = new Planet("sun", 700000, 0, 0, 0, 0, color(255, 255, 10));
  planets[1] = new Planet("mercury", 2450, 0.386, 0.206, 0, 3.38, color(180, 180, 180));
  planets[2] = new Planet("venus", 6050, 0.723, 0.007, 0, 3.86, color(100, 100, 255));
  planets[3] = new Planet("earth", 6400, 1, 0.017, 0, 7.155, color(128, 255, 128));
  planets[4] = new Planet("mars", (float)3400, 1.881, 0.093, (float)0, 5.65, color(255, 100, 100));
  planets[5] = new Planet("jupiter", 71500, 11.857, 0.048, 0, 6.09, color(200, 150, 00));
  planets[6] = new Planet("saturn", 63500, 29.42, 0.056, 0, 5.51, color(200, 200, 50));
  planets[7] = new Planet("uranus", 24973, 83.75, 0.046, 0, 6.48, color(150, 140, 140));
  controlP5.addSlider("sunSize", 1, 50, 20, 5, 5, 50, 10)
           .setLabel("Sun Size");
  controlP5.addSlider("planetSize", 1, 2000, 1000, 5, 20, 50, 10)
           .setLabel("Planet Size");
  controlP5.addSlider("rocketSize", 0, 1, .5, 5, 35, 50, 10)
           .setLabel("Rocket Size");
  controlP5.addSlider("speed", 0, .05, SIM_SPEED, 5, 50, 50, 10);
  controlP5.addToggle("orbits", true, 5, 65, 10, 10);
  controlP5.addToggle("planets", true, 40, 65, 10, 10);
  controlP5.addToggle("lagrange", false, 75, 65, 10, 10);
  //controlP5.addToggle("help", true, 75, 65, 10, 10);
  controlP5.addButton("ITN", 0, 20, height - 70, 50, 25)
           .setLabel("   ITN");
  controlP5.addButton("hohmann", 1, 20, height - 40, 50, 25);
  controlP5.addTextarea("helpText", "Hold and drag mouse to change view.\n" + 
    "Mouse Scroll to zoom in/out.\n" + 
    "Click an orbit to follow path.", 
  width - 150, 10, 150, 40);
  controlP5.addSlider("itnProgress", 0, 1, 0, 5, height - 70, 10, 60)
           .setLabelVisible(false);
  pathList = controlP5.addMultiList("pathList", 5, height - 100, 70, 10);
  s = pathList.add("source", 0);
  d = pathList.add("destination", 1);
  for (int i = 1; i < planets.length; ++i) {
    s.add("source", i).setLabel(planets[i].name);
    d.add("dest", i).setLabel(planets[i].name);
  }
  pathList.subelements().get(0)
                        .setLabel("from: mercury");
  pathList.subelements().get(1)
                        .setLabel("to: jupiter");
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
  rotateXVal = .5;
  rotateYVal = .5;
  zoom = -10;
  controlP5.controller("sunSize").update();
  controlP5.controller("planetSize").update();
  controlP5.controller("rocketSize").update();
}

void draw()
{ 
  // record the controlP5 elements to draw later, since they look blurry otherwise w/ PD3
  beginRecord(cp5);
  controlP5.draw();
  endRecord();
  lights();
  background(0);
  if (followBody != null) {
    if (mousePressed) {
      rotateCamX = map(width/2 - mouseX, -width/2, width/2, -PI*.8, PI*.8);
      rotateCamZ = (height/2 - mouseY)*.1;
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
      rotateYVal = ((float)mouseX/width+0.5)*PI;
      rotateXVal = ((float)mouseY/height+0.5)*PI;
    }
    rotateX(rotateXVal);
    rotateY(rotateYVal);
    mainDisplay();
    popMatrix();
  }
  image(cp5, 0, 0); // draw ControlP5 stuff.
  ++frameCount;
}

void mainDisplay() {
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

void mouseClicked() {
  if (!controlP5.window(this).isMouseOver())
    followBody = getFollowBody();

  if (rocket.follow) {
    followBody = rocket;
    camZoom = 50;
    rotateCamZ = 50;
  }
}

Body getFollowBody() {
  for (Planet p : planets)
    if (!p.equals(planets[0]) && p.follow)
      return p;
  return null;
}

void sunSize(float value) {
  planets[0].setSizeFactor(value);
}

void planetSize(float value) {
  for (Planet p : planets) {
    if (p != planets[0])
      p.setSizeFactor(value);
  }
}

void rocketSize(float value) {
  rocket.setSize(value);
}

void speed(float value) {
  SIM_SPEED = value;
}

void orbits(boolean value) {
  showOrbits = value;
}

//void help(boolean value) {
//	controlP5.controller("helpText").setVisible(value);
//}

void planets(boolean value) {
  showPlanets = value;
}

void lagrange(boolean value) {
  showLagrange = value;
}

void ITN(int value) {
  resetProgress();
  rocket.waitITN();
}

void hohmann(int value) {
  resetProgress();
  rocket.waitHohmann();
}

void source(int value) {
  s.setLabel("from: " + planets[value].name);
  rocket.setSource(planets[value]);
}

void dest(int value) {
  d.setLabel("to: " + planets[value].name);
  rocket.setDest(planets[value]);
}

void setProgress(float value) {
  if (value > controlP5.controller("itnProgress").getValue())
    controlP5.controller("itnProgress").setValue(value);
}

void resetProgress() {
  controlP5.controller("itnProgress").setValue(0);
}

Stack<Body> getPath(Body source, Body dest) {
  return bodyGraph.dijkstra(source, dest);
}

Body getSmallestDist(ArrayList<Body> vertices) {
  Body smallest = vertices.get(0);
  for (Body b : vertices) {
    if (b.distance < smallest.distance)
      smallest = b;
  }
  return smallest;
}

