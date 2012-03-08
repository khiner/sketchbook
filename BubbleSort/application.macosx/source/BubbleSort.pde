/* Visualizing Bubble Sort Algorithm
 * CS350, Winter 2012
 * Author: Karl Hiner
 */

import controlP5.*;
import java.util.Random;

int[] list;
Random random = new Random();
ControlP5 controlP5;
int n;
int total;
boolean swapped;
boolean showChange = false;
boolean showOpt = true;


void setup() {
  size(700, 500);
  noStroke();
  strokeWeight(2);
  fill(0);
  frameRate(10);
  controlP5 = new ControlP5(this);
  reset();
  controlP5.setColorLabel(0);
  controlP5.addButton("reset", 1, width - 100, height - 105, 80, 15).setColorLabel(color(255,255,255));
  controlP5.controller("reset").setLabel("     reset");
  controlP5.addSlider("FPS", 3, 50, 10, width - 100, height - 80, 80, 15).setColorLabel(0);
  controlP5.addToggle("showChange", showChange, width - 100, height - 55, 10, 10).setLabel("change");
  controlP5.addToggle("showOpt", showOpt, width - 50, height - 55, 10, 10).setLabel("optimized");
}

void reset() {
  list = new int[width/2];
  n = width/2;
  total = n;
  randomize();
}

void draw() {
  background(255);
  if (showChange) {
    fill(color(255, 0, 0, 200));
    for (int i = 0; i < total; ++i)
      rect(i*2, list[i] + 1, 2, 2);
  }
  swapped = false;
  for (int i = 1; i < n; ++i) {
    if (list[i] > list[i-1]) {
      int temp = list[i-1];
      list[i-1] = list[i];
      list[i] = temp;
      swapped = true;
    }
  }
  if (swapped)
    --n;
  if (showOpt) {
    fill(color(0, 255, 0, 100));
    rect(n*2, 0, width - n*2, height);
    drawArrow(0, 20, n*2, 0);
    drawArrow(width, height - 20, width - n*2, PI);
    fill(color(255,0,0));
    if (n*2 < width - 70)
    text("% Complete", n*2 + (width - n*2)/2 - 30, height - 5);    
    if (n > 60) {
      text("Index, Optimized", n - 60, 15);
    }
  }    
  fill(0);
  for (int i = 0; i < total; ++i)
    rect(i*2 + 1, list[i] + 1, 2, 2);
}

public void randomize() {
  for (int i = 0; i < total; ++i)
    list[i] = random.nextInt(height);
}

public void printList() {
  for (float f : list)
    System.out.println(f);
}

public void spin(int time) {
  long start = System.currentTimeMillis();
  while (System.currentTimeMillis () - start < time) {
  }
}

public void FPS(float val) {
  frameRate((int)val);
}

public void showChange(boolean flag) {
  showChange = flag;
}

public void showOpt(boolean flag) {
  showOpt = flag;
}

public void reset(int val) {
  reset();
}

void drawArrow(int cx, int cy, int len, float angle) {
  stroke(0);
  pushMatrix();
  translate(cx, cy);
  rotate(angle);
  line(0, 0, len, 0);
  line(len, 0, len - 8, -8);
  line(len, 0, len - 8, 8);
  popMatrix();
  noStroke();
}

