import processing.core.*; 
import processing.xml.*; 

import java.awt.Color; 
import toxi.geom.Rect; 
import toxi.geom.Vec2D; 

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

public class Mandelbrot extends PApplet {

/*
 * Simple Mandelbrot zoom.
 * Click and drag to create a zoom-box.
 * 'r' to reset defaults
 * 'u', DELETE, or BACKSPACE to undo
 */





final float RATIO = 1.336f;        // x::y ratio
final int tMax = 5000;            // max # of iterations    
Stack paramStack = new Stack<Params>();
Params currParams;
Rect selectRect = null;
int[][] buffer;

/*
  Params class is used to hold the four pieces of information we need to remember
 a particular display:  the complex x and y coordinates, and the width and heigh of display.
 (In reality, we only need three values, since the width is fixed to height*RATIO,
 but this having this value is cleaner.
 */
class Params {
  double cx, cy, cw, ch;

  Params() {
    cx = -0.53f - 1.4f*RATIO;
    cy = -1.4f;
    ch = 2.8f;
    cw = ch*RATIO;
  }

  Params(double cx, double cy, double cw, double ch) {
    this.cx = cx;
    this.cy = cy;
    this.cw = cw;
    this.ch = ch;
  }

  Params(Params other) {
    cx = other.cx;
    cy = other.cy;
    cw = other.cw;
    ch = other.ch;
  }
}
public void setup() {
  size(534, 400, P2D);
  noFill();
  stroke(255);
  currParams = new Params();
  paramStack.push(currParams);
  buffer = new int[width][height];
  setBuffer();
  noLoop();
}

public void reset() {
  paramStack.push(new Params(currParams));
  currParams = new Params();
  setBuffer();
  redraw();
}

public void undo() {
  if (paramStack.isEmpty())
    return;
  currParams = (Params)paramStack.pop();
  setBuffer();
  redraw();
}

public double xPixelToComplex(float x) {
  return x*currParams.cw/width + currParams.cx;
}

public double yPixelToComplex(float y) {
  return y*currParams.ch/height + currParams.cy;
}

public void mousePressed() {
  selectRect = new Rect(mouseX, mouseY, 0, 0);
}

public void mouseDragged() {
  if (selectRect != null) {
    selectRect.setDimension(new Vec2D(selectRect.getDimensions().y*RATIO, mouseY - selectRect.getTopLeft().y));
    redraw();
  }
}

public void mouseReleased() {
  if (selectRect != null && selectRect.getDimensions().x != 0 && selectRect.getDimensions().y != 0) {
    double newcx = selectRect.getDimensions().x >= 0 ? xPixelToComplex(selectRect.getTopLeft().x) : xPixelToComplex(selectRect.getTopLeft().x + selectRect.getDimensions().x);
    double newcy = selectRect.getDimensions().y >= 0 ? yPixelToComplex(selectRect.getTopLeft().y) : yPixelToComplex(selectRect.getTopLeft().y + selectRect.getDimensions().y);
    double newch = currParams.ch/(height/Math.abs(selectRect.getDimensions().y));
    double newcw = newch*RATIO;
    paramStack.push(new Params(currParams));
    currParams = new Params(newcx, newcy, newcw, newch);
    setBuffer();
    selectRect = null;
    redraw();
  }
}

public void keyPressed() {
  if (key == 'r')
    reset();
  else if (key == 'u' || key == DELETE || key == BACKSPACE)
    undo();
}

public void setBuffer() {
  double x0, y0, y, x;
  for (int j = 0; j < height; j++)
  {
    y0 = yPixelToComplex(j);
    for (int k = 0; k < width; k++) {
      x0 = xPixelToComplex(k);
      x = 0;
      y = 0;
      double xsqr = 0;
      double ysqr = 0;
      int t = 0;
      while (t < tMax && xsqr + ysqr < 4.0f) {
        y = x*y;
        y += y + y0;
        x = xsqr - ysqr + x0;
        xsqr = x*x;
        ysqr = y*y;
        t++;
      }
      if (t < tMax) {
        double smooth = t - Math.log(xsqr + ysqr);
        buffer[k][j] = Color.HSBtoRGB((float)smooth/500, .8f, .9f);
      } 
      else
        buffer[k][j] = 0;
    }
  }
}

public void draw() {
  for (int i = 0; i < width; ++i)
    for (int j = 0; j < height; ++j)
      set(i, j, buffer[i][j]);
  if (selectRect != null)
    rect(selectRect.getTopLeft().x, selectRect.getTopLeft().y, selectRect.getDimensions().x, selectRect.getDimensions().y);
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--stop-color=#cccccc", "Mandelbrot" });
  }
}
