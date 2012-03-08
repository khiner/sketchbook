/* Visualizing Bubble Sort Algorithm
 * CS350, Winter 2012
 * Author: Karl Hiner
 */

import controlP5.*;

int[] bubbleList;
int[] mergeList, tmpList;
ControlP5 controlP5;
int n; // for bubbleSort
int step, startL, startR; // for mergeSort
boolean swapped;
boolean showInfo = true;
int bubbleCompareCount = 0;
int mergeCompareCount = 0;
int listLength = 256;
int scale; // for scaling drawing
boolean bubbleDone = false, mergeDone = false;

void setup() {
  size(1024, 600, P2D);
  noStroke();
  strokeWeight(2);
  fill(0);
  textMode(SCREEN);
  //textFont(loadFont("CourierNew36.vlw"));
  textSize(20);
  frameRate(10);
  controlP5 = new ControlP5(this);
  controlP5.addButton("reset", 1, width - 100, height - 35, 40, 15)
           .captionLabel().style().marginLeft = 4;
  controlP5.addSlider("FPS", 3, 50, 10, width - 140, height - 60, 80, 15)
           .captionLabel().style().marginLeft = -20;
  controlP5.addToggle("showInfo", showInfo, width - 50, height - 35, 10, 10)
           .setLabel("info");
  
  DropdownList lenList = controlP5.addDropdownList("lenList", width - 140, height - 19, 35, 15)
                                  .setBarHeight(15);
  lenList.captionLabel().style().marginTop = 3;
  lenList.addItem("8", 3);
  lenList.addItem("16", 4);
  lenList.addItem("32", 5);
  lenList.addItem("64", 6);
  lenList.addItem("128", 7);
  lenList.addItem("256", 8);
  lenList.addItem("512", 9);
  lenList.addItem("1024", 10);
  lenList.setLabel(String.valueOf(listLength));
  reset();
}

void reset() {
  bubbleCompareCount = 0;
  mergeCompareCount = 0;
  bubbleDone = false;
  mergeDone = false;
  bubbleList = new int[listLength];
  randomize(bubbleList);
  mergeList = copy(bubbleList);
  tmpList = new int[listLength];
  scale = width/listLength;
  n = listLength;
  step = 1;
  startL = 0;
  startR = step;
}

int[] copy(int[] list) {
  int[] copy = new int[list.length];
  for (int i = 0; i < list.length; ++i)
    copy[i] = list[i];
  return copy;
}

void draw() {
  background(255);
  pushMatrix();
  scale(scale, 1);
  if (showInfo) {
    fill(color(255, 0, 0, 200));
    for (int i = 0; i < n; ++i)
      rect(i, bubbleList[i] + 20, 1, height/2 - 20 - bubbleList[i]);
    for (int i = 0; i < mergeList.length; ++i)
      rect(i, height/2  + mergeList[i] + 20, 1, height/2-mergeList[i] - 20);
  }
  if (!bubbleDone)
    bubbleSort();
  if (!mergeDone);
    mergeSort();
  fill(0);
  for (int i = 0; i < listLength; ++i) {
    rect(i, bubbleList[i] + 20, 1, height/2-bubbleList[i] - 20);
    rect(i, height/2 + mergeList[i] + 20, 1, height/2-20-mergeList[i]);
  }
  if (showInfo) {
    fill(color(0, 255, 0, 100));
    if (!bubbleDone)
    rect(n, 0, width - n, height/2);
    else
    rect(0, 0, width, height/2);
    if (!mergeDone)
    rect(startL, height/2, (startR - startL), height/2);
    else
    rect(0, height/2, width, height/2);
    if (n < width - 70) {
      fill(255);
      text("% Complete", n + (width - n)/2 - 30, height/2 - 5);
    }    
    fill(color(0,0,255,200));
    String indexString = n > 1 ? " Indices " : " Index ";
    text("Bubble Sort: Comparing " + n + indexString + "Per Loop. Total Compares: " + bubbleCompareCount, 5, 20);
    int index = startR - startL;
    indexString = index > 1 ? " Indices " : " Index ";
    text("Merge Sort: Comparing " + index + indexString + "Per Loop. Total Merge Compares: "+ mergeCompareCount, 5, height/2 + 20);
  }
  popMatrix();
  controlP5.draw();
}

void bubbleSort() {
  swapped = false;
  for (int i = 1; i < n; ++i) {
    if (bubbleList[i] > bubbleList[i-1]) {
      bubbleCompareCount++;
      int temp = bubbleList[i-1];
      bubbleList[i-1] = bubbleList[i];
      bubbleList[i] = temp;
      swapped = true;
    }
  }
  if (swapped)
    --n;
  else
    bubbleDone = true;
}

// Bottom-up merge sort
public void mergeSort() {
  if (mergeList.length < 2) {
    // We consider the list already sorted, no change is done
    return;
  }
  // startL - start index for left sub-list
  // startR - start index for the right sub-list

  if (step < mergeList.length) {
    if (startR + step > mergeList.length) {
      startL = 0;
      startR = step;
    }
    if (startR + step <= mergeList.length) {
      mergeLists(startL, startL + step, startR, startR + step);
      startL = startR + step;
      startR = startL + step;
    }
    if (startR + step > mergeList.length) {
      if (startR < mergeList.length)
        mergeLists(startL, startL + step, startR, mergeList.length);
      step *= 2;
    }
  } else
    mergeDone = true;
}

public void mergeLists(int startL, int stopL, 
int startR, int stopR) {
  int[] right = new int[stopR - startR + 1];
  int[] left = new int[stopL - startL + 1];

  for (int i = 0, k = startR; i < (right.length - 1); ++i, ++k)
    right[i] = mergeList[k];
  for (int i = 0, k = startL; i < (left.length - 1); ++i, ++k)
    left[i] = mergeList[k];

  right[right.length-1] = Integer.MIN_VALUE;
  left[left.length-1] = Integer.MIN_VALUE;

  // Merging the two sorted mergeLists into the initial one
  for (int k = startL, m = 0, n = 0; k < stopR; ++k) {
    if (left[m] > right[n]) {
      mergeCompareCount++;
      mergeList[k] = left[m];
      m++;
    }
    else {
      mergeList[k] = right[n];
      n++;
    }
  }
}

public void randomize(int[] list) {
  for (int i = 0; i < list.length; ++i)
    list[i] = (int)random(height/2 - 20);
}

public void printList() {
  for (float f : bubbleList)
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

public void showInfo(boolean flag) {
  showInfo = flag;
}

public void reset(int val) {
  reset();
}

void controlEvent(ControlEvent e) {
  if (e.isGroup()) {
    listLength=2<<(int)e.group().getValue() - 1;
    reset();
  }
}


