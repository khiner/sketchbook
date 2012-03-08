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

public class bubble_wrap extends PApplet {

/*****************************************************************
 A simple sketch with for trippy, colorful bubble patterns.
 Size of the bubbles depends on X-Position of the mouse.
 Speed depends on Y-position of the mouse.
 Click anywhere on the screen to change the amount of rows along the
 X-axis and Y-axis
 ******************************************************************/

float numX = 20;
float numY = 20;

public void setup() {
  size(800, 700, P2D);
  frameRate(24);
  noStroke();
}

public void draw() {
  //calculate a background that smoothly oscillates between black and white
  float back = ((int)frameCount/255)%2 == 0 ? frameCount%255 : 255 - frameCount%255;
  background(back);
  for (int x = 0; x < width + 10; x += numX) {
    for (int y = 0; y < height + 10; y += numY) {
      fill(255*cos(x+y+frameCount*.01f), 255*sin(y+x+frameCount*.01f), 255*tan(x+y+frameCount*.01f));
      ellipse(x, y, circleSize()*sin(x+y+frameCount*speed()) + 8, circleSize()*cos(x+y+frameCount*speed()) + 8);
    }
  }
}

public float circleSize() { 
  return map(mouseX, 0, width, width/500, width/12);
}
public float speed() { 
  return map(mouseY, 0, height, .06f, .2f);
}

public void mouseClicked() {
  numX = map(mouseX, 0, width, width/230, width/4);
  numY = map(mouseY, 0, height, height/230, height/4);
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--stop-color=#cccccc", "bubble_wrap" });
  }
}
