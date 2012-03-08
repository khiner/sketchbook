import processing.core.*; 
import processing.xml.*; 

import toxi.physics.*; 
import toxi.physics.behaviors.*; 
import toxi.geom.*; 
import controlP5.*; 
import processing.opengl.*; 

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

public class Solar_System extends PApplet {

//Mercury:
//Radius: 2,450 km
//Period: 0.387
//Ellipse e: 0.206
//Mass: 3.30*10^23
//
//Venus:
//Radius: 6,050 km
//Period: 0.723
//Ellipse e: 0.007
//Mass: 4.87*10^24
//
//Earth:
//Radius: 6,400 km
//Period: 1
//Ellipse e: 0.017
//Mass: 5.97*10^24
//
//Mars:
//Radius: 3,400 km
//Period: 1.881
//Ellipse e: 0.093
//Mass: 6.42*10^23
//
//Jupiter:
//Radius: 71,500 km
//Period: 11.857
//Ellipse e: 0.048
//Mass: 1.90*10^27
//
//Saturn:
//Radius: 63,500 km
//Period: 29.42
//Ellipse e: 0.056
//Mass: 5.69*10^26
//
//Uranus:
//Radius: 24,973 km
//Period: 83.75
//Ellipse e: 0.046
//
//Radius of Sun: 700,000 km
//Mass of Sun: 1.98892 \u00d7 10^30 kg
//Read more: http://wiki.answers.com/Q/What_is_the_distance_of_all_planets_from_the_sun#ixzz1LwdqB0Qt








// Solar System
// By: Karl Hiner, with code from John Gilbertson

ControlP5 controlP5;
Body sun;
Body followBody = null;
final int AU = 149598000; // Astronomical Unit, in km
final int SCALE_FACTOR = 1200000000;  // for scale factor, use the distance of farthest planet/1 million + some view room
float SIM_SPEED = .05f;
float rotateXVal = 0;
float rotateYVal = 0;
float rotateCamX = 0;
float rotateCamZ = 0;
float camZoom = .5f;
Vec3D cameraVec = new Vec3D(0,0,0);
float zoom = -200;
boolean showOrbits = true;
boolean showPlanets = true;
boolean showLagrange = false;
VerletPhysics physics;

public void setup()
{
  controlP5 = new ControlP5(this);
  physics = new VerletPhysics();
  noSmooth();
  sphereDetail(18);
  //physics.addBehavior(new GravityBehavior(new Vec3D(0,0,0)));
  physics.setWorldBounds(new AABB(200));
  size((int)(screenWidth*.75f), (int)(screenHeight*.75f), OPENGL);
  ellipseMode(RADIUS);
  frameRate(14);
  textFont(createFont("Arial", 5));
  // mouse Wheel
  addMouseWheelListener(new java.awt.event.MouseWheelListener() {  
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) {
      if (evt.getWheelRotation()<0) {
        zoom+=evt.getScrollAmount()+Math.abs(zoom*.1f);
        if (camZoom > .1f)
          camZoom -= evt.getScrollAmount()*.01f;
      }  
      else {
        zoom-=evt.getScrollAmount()+Math.abs(zoom*.1f);
        if (camZoom < 1)
        camZoom += evt.getScrollAmount()*.01f;
      }
      redraw();
    }
  }
  ); 

  BodyArray temp=new BodyArray();

  //Body phobos=new Body(3,0,10,10,0.25,0,0,color(80,80,80));
  //Body demios=new Body(3,0,10,15,0.18,0.1,0,color(100,100,100));
  //temp.add(phobos);
  //temp.add(demios);
  Body mars=new Body(3400, (float)(6.42f*Math.pow(10, 23)), 1.881f, 0.093f, 0, 0, color(255, 100, 100));
  //temp=new BodyArray();
  //Body moon=new Body(1738,(float)(7.35*Math.pow(10,22)),362600,405400,1.0/12, 0.3,0.6,color(128,128,128));
  //temp.add(moon);
  Body earth=new Body(6400, (float)(5.97f*Math.pow(10, 24)), 1, 0.017f, 0, 0, color(128, 255, 128));
  Body mercury=new Body(2450, (float)(3.30f*Math.pow(10, 23)), 0.386f, 0.206f, 0, 0, color(180, 180, 180));
  Body venus=new Body(6050, (float)(4.87f*Math.pow(10, 24)), 0.723f, 0.007f, 0, 0, color(100, 100, 255));
  Body jupiter = new Body(71500, (float)(1.90f*Math.pow(10, 27)), 11.857f, 0.048f, 0, 0, color(200, 150, 00));
  Body saturn = new Body(63500, (float)(5.69f*Math.pow(10, 26)), 29.42f, 0.056f, 0, 0, color(200,200,50));
  Body uranus = new Body(24973, (float)(8.681f*Math.pow(10, 25)), 83.75f, 0.046f, 0, 0, color(150, 140, 140));
  temp = new BodyArray();
  temp.add(earth);
  temp.add(mercury);
  temp.add(venus);
  temp.add(mars);
  temp.add(jupiter);
  temp.add(saturn);
  temp.add(uranus);
  sun=new Body(700000, (float)(1.99f*Math.pow(10, 30)), 0, 0, 0, 0, color(255, 255, 10), temp);
  sun.display();
  controlP5.addSlider("sunSize", 1, 50, 20, 5, 5, 50, 10);
  controlP5.controller("sunSize").setLabel("Sun Size");
  controlP5.controller("sunSize").trigger();
  controlP5.addSlider("planetSize", 1, 800, 450, 5, 20, 50, 10);
  controlP5.controller("planetSize").setLabel("Planet Size");
  controlP5.controller("planetSize").trigger();
  controlP5.addSlider("speed", 0, .1f, .05f, 5, 35, 50, 10);
  controlP5.addToggle("orbits", true, 5, 50, 10, 10);
  controlP5.addToggle("planets", true, 40, 50, 10, 10);
  controlP5.addToggle("lagrange", false, 5, 75, 10, 10);
  controlP5.addToggle("help", true, 75, 50, 10, 10);
  controlP5.addTextarea("helpText", "Hold SHIFT to change view.\n" + 
                                   "Mouse Scroll to zoom in/out.\n" + 
                                   "Click an orbit to follow path.",
                                   width - 150, 10, 150, 30);
}

public void draw()
{
  //physics.update();
  lights();
  background(0);
  sun.tick();
  if (followBody != null) {
      if (keyPressed && key == CODED && keyCode == SHIFT) {
        rotateCamX = map(width/2 - mouseX, -width/2, width/2, -PI*.8f, PI*.8f);
        rotateCamZ = (height/2 - mouseY)*.1f;
      }
      cameraVec = followBody.planet.getRotatedZ(rotateCamX).scale(camZoom);
      camera(followBody.x() + cameraVec.x(), followBody.y() + cameraVec.y(), followBody.z() + rotateCamZ, followBody.x(), followBody.y(), followBody.z(), 0, 0, -1);
      sun.display();
      camera();
  } else {
    pushMatrix();
    translate(width/2, height/2, zoom);
    if (keyPressed && key == CODED && keyCode == SHIFT) {
      rotateYVal = (((float)mouseX/(float)width)-0.5f)*PI;
      rotateXVal = (-((float)mouseY/(float)height)+0.5f)*PI;
    }
    rotateX(rotateXVal);
    rotateY(rotateYVal);
    sun.display();
    popMatrix();
  }
}

public void mouseClicked() {
  if (!controlP5.window(this).isMouseOver())
    followBody = sun.children.getSelected();
}

public void sunSize(float value) {
  sun.setSizeFactor(value);
}

public void planetSize(float value) {
  for (int i = 0; i < sun.children.length(); ++i)
    sun.children.get(i).setSizeFactor(value);
}

public void speed(float value) {
  SIM_SPEED = value;
}

public void orbits(boolean value) {
  showOrbits = value;
}

public void help(boolean value) {
  controlP5.controller("helpText").setVisible(value);
}

public void planets(boolean value) {
  showPlanets = value;
}

public void lagrange(boolean value) {
  showLagrange = value;
}

class BodyArray
{
  Body[] ours;
  int oursize;

  BodyArray() { 
    oursize=0;
  }

  public void add(Body x) {
    oursize++;
    Body[] newbodies=new Body[oursize];
    for (int i=0;i<oursize-1;i++) {
      newbodies[i]=ours[i];
    }
    newbodies[oursize-1]=x;
    ours=newbodies;
  }

  public int length() { 
    return oursize;
  }

  public void display() {
    for (int i=0;i<oursize;i++) {
      ours[i].display();
    }
  }

  public void tick() {
    for (int i=0;i<oursize;i++) {
      ours[i].tick();
    }
  }

  public Body get(int index) {
    return ours[index];
  }

  public Body getSelected() {
    for (int i = 0; i < oursize; ++i)
      if (ours[i].follow)
        return ours[i];
    return null;
  }
}

class Body
{
  float mySize;
  float displaySize;
  float ellipseE;
  float ellipseA;
  float ellipseB;
  float ellipseCenter;
  float orbit_speed;
  float angle_to_ecliptic;
  float path_angle;
  int myColor;
  boolean follow = false;
  BodyArray children;
  VerletParticle planet;

  Body(float sz, float mass, float ellipseA, float ellipseE, float _a, float _p, int _c) {
    mySize = map(sz, 0, SCALE_FACTOR, 0, width/2);
    displaySize = mySize;
    this.ellipseA = map(ellipseA*AU, 0, SCALE_FACTOR, 0, width/2);
    this.ellipseE = ellipseE;
    ellipseCenter = this.ellipseA*ellipseE;
    ellipseB = (float)(this.ellipseA*Math.sqrt(1-ellipseE*ellipseE));
    orbit_speed= (ellipseA == 0) ? 0 : 1.0f/ellipseA;
    angle_to_ecliptic=_a;
    path_angle=_p;
    myColor=_c;
    planet = new VerletParticle(new Vec3D(ellipseCenter + this.ellipseA*sin(path_angle), ellipseB*cos(path_angle), 0));
//    planet.setWeight(mass);
//    physics.addParticle(planet);
//    physics.addBehavior(new AttractionBehavior(planet, 1000, -.0001*mass, 0.0));
    children=new BodyArray();
  }

  Body(float sz, float mass, float ellipseA, float ellipseE, float _a, float _p, int _c, BodyArray _children) {
    this(sz, mass, ellipseA, ellipseE, _a, _p, _c);
    children=_children;
  }

  public float x() { return planet.x(); }
  public float y() { return planet.y(); }
  public float z() { return planet.z(); }
  
  public void display() {
    //rotateY(angle_to_ecliptic);
    if (isMouseOverOrbit()) {
      strokeWeight(3);
      follow = true;
    } else {
      strokeWeight(1);
      follow = false;
    }
    stroke(myColor);
    if (showOrbits) {
      noFill();
      ellipse(ellipseCenter, 0, ellipseA, ellipseB);
    }
    noStroke();
    if (showLagrange && !this.equals(sun))
      showLagrange();
    if (showPlanets) {
      translate(planet.x(), planet.y(), planet.z());
      fill(myColor);
      sphere(displaySize);
      translate(-planet.x(), -planet.y(), -planet.z());
    }
    children.display();
  }

  public void tick() {
    path_angle=path_angle+orbit_speed*SIM_SPEED;
    planet.set(new Vec3D(ellipseCenter + ellipseA*sin(path_angle), ellipseB*cos(path_angle), 0));
    children.tick();
  }

  public boolean isMouseOverOrbit() {
    for (float i = 0; i < 2*PI; i += PI/(ellipseA)) {
      if (dist(screenX(ellipseCenter + ellipseA*sin(i), ellipseB*cos(i), 0), screenY(ellipseCenter + ellipseA*sin(i), ellipseB*cos(i), 0), mouseX, mouseY) < 5)
        return true;
    }
    return false;
  }

  public void setSizeFactor(float sizeFactor) {
    displaySize = mySize*sizeFactor;
  }
  
  public void showLagrange() {
    Vec3D l1 = planet.scale(.95f);  // L1 is just in front of the planet
    Vec3D l2 = planet.scale(1.15f); // L2 is just behind the planet
    Vec3D l3 = planet.getRotatedZ(PI);  // L3 is almost exactly on the opposite side of the sun
    Vec3D l4 = planet.getRotatedZ(PI/3);  // L4 and L5 both form an equilateral
    Vec3D l5 = planet.getRotatedZ(-PI/3); // triangle with the planet and the sun.
    fill(color(255,0,0));  // Lagrange points are displayed as red spheres
    // display all L-Points
    translate(l1.x(), l1.y(), l1.z());
    sphere(displaySize);
    translate(l2.x() - l1.x(), l2.y() - l1.y(), l2.z() - l1.z());
    sphere(displaySize);
    translate(l3.x() - l2.x(), l3.y() - l2.y(), l3.z() - l2.z());
    sphere(displaySize);
    translate(l4.x() - l3.x(), l4.y() - l3.y(), l4.z() - l3.z());
    sphere(displaySize);
    translate(l5.x() - l4.x(), l5.y() - l4.y(), l5.z() - l4.z());
    sphere(displaySize);
    translate(-l5.x(), -l5.y(), -l5.z());
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#DFDFDF", "Solar_System" });
  }
}
