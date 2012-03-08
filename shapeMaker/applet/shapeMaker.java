import processing.core.*; 
import processing.xml.*; 

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

public class shapeMaker extends PApplet {

ArrayList<Line> lines = new ArrayList<Line>();

public void setup() {
  size(800, 500, P2D);
  strokeWeight(2);
  stroke(0);
  noFill();
  for (int i = 0; i < 20; ++i)
    lines.add(new Line(new PVector(random(width - 1), random(height - 1)), random(TWO_PI), random(1, 1.5f)));
}

public void draw() {
  background(255);
  for (Line l : lines) {
    //for (Line otherl : lines)
      //if (!l.intersecting(otherl))
    l.stretch();
    l.draw();
  }
}

class Line {
  PVector centerPoint;
  float angle;
  float mySize;
  float stretchRate;
  
  Line(PVector cp, float a, float sr) {
    centerPoint = cp;
    angle = a;
    stretchRate = sr;
  }
  
  public void draw() {
    line(centerPoint.x - mySize*cos(angle), centerPoint.y - mySize*sin(angle),
         centerPoint.x + mySize*cos(angle), centerPoint.y + mySize*sin(angle));
  }
  
  public void stretch() {
    mySize *= stretchRate;
  }
  
  
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#DFDFDF", "shapeMaker" });
  }
}
