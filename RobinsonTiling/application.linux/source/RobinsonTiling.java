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

public class RobinsonTiling extends PApplet {

/*
 * Generate the Robinson Tiling
 * Author: Karl Hiner
 * CS350, Winter 2012
 * see http://en.wikipedia.org/wiki/Aperiodic_tiling for an explanation
 * 
 * This implementation emulates the Wolfram Demo Project at http://demonstrations.wolfram.com/RobinsonTiling/
 * The code is very different from the implementation above, but the tile shape/color declarations are the same.
 */
 


/*
 * Holds Tile info, and contains a draw method
 */
class Tile {
  int[][] vertices;
  int c;
  public Tile(int[][] vertices, int c) {
    this.vertices = vertices;
    this.c = c;
  }
  public void draw() {
    fill(c);
    beginShape();
    for (int[] pos : vertices) {
      vertex(pos[0]*8/dim, pos[1]*8/dim);
    }
    endShape(CLOSE);
  }
}

Tile tile0 = new Tile(new int[][]{{-1, -6}, {0, -8}, {1, -6}, {5, -6}, {6, -5}, {6, -1}, {4, 0}, {6, 1}, {6, 5}, {5, 6}, {1, 6}, {0, 4}, {-1, 6}, {-5, 6}, {-6, 5}, {-6, 1}, {-4, 0}, {-6, -1}, {-6, -5}, {-5, -6}},
                      color(255, 120, 0));
Tile tile1 = new Tile(new int[][]{{-1, -6}, {0, -8}, {1, -6}, {5, -6}, {6, -5}, {6, -1}, {4, -1}, {6, 1}, {6, 5}, {5, 6}, {1, 6}, {0, 4}, {-1, 6}, {-5, 6}, {-6, 5}, {-6, 1}, {-4, -1}, {-6, -1}, {-6, -5}, {-5, -6}},
                      color(84, 153, 179));
Tile tile2 = new Tile(new int[][]{{-1, -6}, {-1, -8}, {1, -6}, {5, -6}, {6, -5}, {6, -1}, {4, 0}, {6, 1}, {6, 5}, {5, 6}, {1, 6}, {-1, 4}, {-1, 6}, {-5, 6}, {-6, 5}, {-6, 1}, {-4, 0}, {-6, -1}, {-6, -5}, {-5, -6}},
                      color(201, 181, 66));
Tile tile3 = new Tile(new int[][]{{-1, -6}, {-1, -8}, {1, -6}, {5, -6}, {6, -5}, {6, -1}, {4, -1}, {6, 1}, {6, 5}, {5, 6}, {1, 6}, {-1, 4}, {-1, 6}, {-5, 6}, {-6, 5}, {-6, 1}, {-4, -1}, {-6, -1}, {-6, -5}, {-5, -6}},
                      color(153, 186, 92));
Tile tile4 = new Tile(new int[][]{{-1, -6}, {1, -8}, {1, -6}, {5, -6}, {6, -5}, {6, -1}, {4, 0}, {6, 1}, {6, 5}, {5, 6}, {1, 6}, {1, 4}, {-1, 6}, {-5, 6}, {-6, 5}, {-6, 1}, {-4, 0}, {-6, -1}, {-6, -5}, {-5, -6}},
                      color(201, 181, 66));
Tile tile5 = new Tile(new int[][]{{-1, -6}, {1, -8}, {1, -6}, {5, -6}, {6, -5}, {6, -1}, {4,-1}, {6, 1}, {6, 5}, {5, 6}, {1, 6}, {1, 4}, {-1, 6}, {-5, 6}, {-6, 5}, {-6, 1}, {-4, -1}, {-6, -1}, {-6, -5}, {-5, -6}},
                      color(153, 186, 92));
Tile startTile = new Tile(new int[][]{{-1, -6}, {0, -8}, {1, -6}, {5, -6}, {6, -5}, {6, -1}, {8, -1}, {6, 1}, {6, 5}, {5, 6}, {1, 6}, {-1, 8}, {-1, 6}, {-5, 6}, {-6, 5}, {-6, 1}, {-8, 0}, {-6, -1}, {-6, -5}, {-5, -6}},
                          color(122, 28, 143));
Tile endTile = new Tile(new int[][]{{-1, -6}, {0, -8}, {1, -6}, {5, -6}, {6, -7}, {7, -6}, {6, -5}, {6, -1}, {8, -1}, {6, 1}, {6, 5}, {7, 6}, {6, 7}, {5, 6}, {1, 6}, {-1, 8}, {-1, 6}, {-5, 6}, {-6, 7}, {-7, 6}, {-6, 5}, {-6, 1}, {-8, 0}, {-6, -1}, {-6, -5}, {-7, -6}, {-6, -7}, {-5, -6}},
                        color(200));
                        
ControlP5 controlP5;
DropdownList sizeList;
List<Tile> tiles = new ArrayList<Tile>();
int sz = 512;
int dim, stepLength;
int[][] corners = {{-1,1}, {1,1}, {1,-1}, {-1,-1}};
int[][] sides = {{-1,0}, {0,1},{1,0},{0,-1}};
float[] rotates = {-HALF_PI, PI, HALF_PI, 0};
int[] tileIndices = {1,5,3,1};

public void setup() {
  size(sz, sz);
  tiles.add(tile0);
  tiles.add(tile1);
  tiles.add(tile2);
  tiles.add(tile3);
  tiles.add(tile4);
  tiles.add(tile5);
  tiles.add(startTile);
  tiles.add(endTile);
  controlP5 = new ControlP5(this);
  setupSizeList();
  setLengthVars(3);
}  

public void draw() {
  background(255);
  stroke(0);
  strokeWeight(2);
  fill(0); // fill black for text
  text("size", 5, 20);
  pushMatrix();
  translate(sz/2, sz/2);
  rotate(-HALF_PI);
  drawTiles(dim);
  popMatrix();
}

public void setLengthVars(int o) {
  dim = 1 << o;
  stepLength = 3*(1 << 5 - o);
}

public void setupSizeList() {
  sizeList = controlP5.addDropdownList("sizeList", 30, 25, 30, 15*6)
                      .setBarHeight(15)
                      .setItemHeight(15)
                      .setLabel("31");
  sizeList.addItem("3", 0);
  sizeList.addItem("7", 1);
  sizeList.addItem("15", 2);
  sizeList.addItem("31", 3);
  sizeList.addItem("63", 4);
  sizeList.captionLabel().style().marginTop = 3;
  sizeList.captionLabel().style().marginLeft = 5;
}

public void drawTiles(int n) {
  startTile.draw();
  if (n == 1) {
    for (int j = 0; j < corners.length; ++j) {
      pushMatrix();
      translate(stepLength*corners[j][0], stepLength*corners[j][1]);
      rotate(rotates[j]);
      endTile.draw();
      popMatrix();
    }
    for (int j = 0; j < sides.length; ++j) {
      pushMatrix();
      translate(stepLength*sides[j][0], stepLength*sides[j][1]);
      rotate(rotates[j]);
      tiles.get(tileIndices[j]).draw();
      popMatrix();
    }
  } else {
    for (int j = 0; j < corners.length; ++j) {
      pushMatrix();
      translate(stepLength*n*corners[j][0], stepLength*n*corners[j][1]);
      rotate(rotates[j]);
      drawTiles(n/2);
      popMatrix();
    }
    for (int j = 0; j < sides.length; ++j) {
      for (int k = 1; k < n*2; ++k) {
        pushMatrix();
        translate(stepLength*sides[j][0]*k, stepLength*sides[j][1]*k);
        rotate(rotates[j]);
        if (k == n) {
          if (j == 0 || j == 3)
            tiles.get(1).draw();
          else if (j == 2)
            tiles.get(3).draw();
          else
            tiles.get(5).draw();
        } else {
          if (j == 0 || j == 3)
            tiles.get(0).draw();
          else if (j == 2)
            tiles.get(2).draw();
          else
            tiles.get(4).draw();
        }
        popMatrix();
      }
    }
  } 
}

/*
 * This method is needed to recognize events from the
 * 'sizeList' DropdownList
 */
public void controlEvent(ControlEvent e) {
  // if we don't use this check, ControlP5 throws an exception
  if (e.isGroup()) {
    // set the new size
    setLengthVars((int)e.group().getValue());
  }
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--stop-color=#cccccc", "RobinsonTiling" });
  }
}
