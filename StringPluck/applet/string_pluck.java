import processing.core.*; 
import processing.xml.*; 

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

public class string_pluck extends PApplet {

/**********************************************************************
  Pluck the string by holding the mouse down and releasing.
  Adjust the speed, damping, and number of harmonics of the simulation.
  The equation for this simulation is due to:
  http://www.oberlin.edu/faculty/brichard/Apples/StringsPage.html
***********************************************************************/
   


ControlP5 controlP5;
final float PI_SQUARED = PI*PI;
boolean plucked = false;
int t = 0;        // time since pluck
int m_tot = 10;   // harmonics - each harmonic requires more computation
float c = 100;    // speed
float amp = 0;    // amplitude
float d;          // x position of pluck
float damp = 1.1f; // damping constant

public void setup() {
  size(800, 600, P2D);
  strokeWeight(3);
  smooth();
  controlP5 = new ControlP5(this);
  controlP5.setColorLabel(0);
  controlP5.addSlider("damp", 1, 1.35f, 1.1f, 5, 10, 80, 15);
  controlP5.addSlider("c", 20, 300, 100, 5, 30, 80, 15).setLabel("speed");
  controlP5.addSlider("m_tot", 1, 15, 10, 5, 50, 80, 15).setLabel("harmonics");
}

public void draw() {
  noFill();
  stroke(0);
  background(255);
  if (plucked) {
    t++;
    amp/= damp;
  }
  float w = PI*(c/width);
  beginShape();
  if (plucked) {
    for (int x = 0; x < width; x += 5) {
      float sum = 0;
      for (int m = 1; m <= m_tot; ++m)
        sum += (1.0f/(m*m)*sin((m*PI_SQUARED*d)/width)*sin((m*PI*x)/width)*cos(m*w*t));
      float y = (1.5f*amp*width*width)/(PI_SQUARED*d*(width - d))*sum;
      y += height/2;
      vertex(x, y);
    }
  } 
  else {
    vertex(0, height/2);
    vertex(d, height/2 + amp);
    vertex(width - 5, height/2);
  }
  endShape();
  controlP5.draw();  // we need to manually draw controlP5 when using P2D
}

public void mousePressed() {
  if (!controlP5.window().isMouseOver()) {
    plucked = false;
    t = 0;
    amp = mouseY - height/2;
    d = mouseX;
  }
}

public void mouseDragged() {
  if (!controlP5.window().isMouseOver()) {
    d = mouseX;
    amp = mouseY - height/2;
  }
}

public void mouseReleased() {
  plucked = true;
}

public void damp(float value) { damp = value; }
public void c(float value) { c = value; }
public void m_tot(float value) { m_tot = (int)value; }
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#DFDFDF", "string_pluck" });
  }
}
