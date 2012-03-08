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

public class Tetris extends PApplet {

/*
  Tetris
  Author: Karl Hiner
  Controls:
  LEFT/RIGHT/DOWN to move
  UP - flip
  SPACE - hard drop (drop immediately)
*/



final int CYAN = color(0,255,255);
final int ORANGE = color(255,165,0);
final int YELLOW = color(255,255,0);
final int PURPLE = color(160,32,240);
final int BLUE = color(0,0,255);
final int RED = color(255,0,0);
final int GREEN = color(0,255,0);

ControlP5 controlP5;
Grid board, preview;
Tetromino curr;
Shape next;
Shape[] shapes = new Shape[7];
int timer = 20;
int currTime = 0;
int score = 0;
int lines = 0;
int level = 1;
final int SPEED_DECREASE = 2;
boolean game_over = false;

public void setup() {
  size(500, 690, P2D);
  textSize(25);
  controlP5 = new ControlP5(this);
  controlP5.addButton("play", 1, width/2 - 35, height/2, 70, 20).setLabel("play again");
  shapes[0] = new Shape(4, new int[] {8,9,10,11}, CYAN);  // I
  shapes[1] = new Shape(3, new int[] {0,3,4,5}, BLUE);  // J
  shapes[2] = new Shape(3, new int[] {2,3,4,5}, ORANGE);  // L
  shapes[3] = new Shape(2, new int[] {0,1,2,3}, YELLOW);  // O
  shapes[4] = new Shape(4, new int[] {5,6,8,9}, GREEN);  // S
  shapes[5] = new Shape(3, new int[] {1,3,4,5,}, PURPLE);  // T
  shapes[6] = new Shape(4, new int[] {4,5,9,10}, RED);  // Z
  board = new Grid(20, 20, 321, 642, 20, 10);
  preview = new Grid(355, 20, 116, 58, 2, 4);
  next = shapes[(int)random(7)];
  loadNext();
}

public void draw() {
  background(0);
  if (game_over) {
    text("GAME OVER\nSCORE: " + score, width/2 - 70, height/2 - 50);
    controlP5.draw(); // show the play again button
    return;
  }
  currTime++;
  if (currTime >= timer && board.animateCount == -1)
    curr.stepDown();
  preview.draw();
  board.draw();
  if (curr != null)
    curr.draw();
  next.preview();
  fill(255);
  text("LEVEL\n" + level, width - 150, 120);
  text("LINES\n" + lines, width - 150, 200);
  text("SCORE\n" + score, width - 150, 280);
}

public void loadNext() {
  curr = new Tetromino(next);
  next = shapes[(int)random(7)];
  currTime = 0;
}

public void keyPressed() {
  if (curr == null || game_over)
    return;
  switch(keyCode) {
    case LEFT : curr.left(); break;
    case RIGHT : curr.right(); break;
    case UP : curr.rotate(); break;
    case DOWN : curr.down(); break;
    case ' ' : curr.hardDown(); break;
  }
}

public void play(int value) {
  board.clear();
  loadNext();
}
class Grid {
  int x, y;
  int myWidth, myHeight;
  int rows, cols;
  int[][] colors;
  ArrayList<Integer> clearedRows = new ArrayList<Integer>();
  int animateCount = -1;
  
  Grid(int x, int y, int w, int h, int rows, int cols) {
    this.x = x;
    this.y = y;
    myWidth = w;
    myHeight = h;
    this.rows = rows;
    this.cols = cols;
    colors = new int[cols][rows];
    for (int i = 0; i < cols; ++i)
      for (int j = 0; j < rows; ++j)
        colors[i][j] = 0;
  }
  
  public void clear() {
    for (int i = 0; i < cols; ++i)
      for (int j = 0; j < rows; ++j)
        colors[i][j] = 0;
  }
  
  public void draw() {
    stroke(255);
    strokeWeight(2);
    rect(x, y, myWidth, myHeight);
    for (int i = 0; i < cols; ++i)
      for (int j = 0; j < rows; ++j)
        fillSquare(i, j, colors[i][j]);
    // line clear animation
    if (animateCount >= 0) {
      //calculate a background that smoothly oscillates between black and white
      int c = (animateCount < 255) ? animateCount : 255 - animateCount%255;
      if (clearedRows.size() == 4)
        c = color(0, c, c); // cyan animation for a Tetris
      for (int row : clearedRows)
        for (int i = 0; i < cols; ++i)
          fillSquare(i, row, color(c, 200));
      animateCount += 10;
      if (animateCount > 2*255) {
        // stop animation, clear the lines, and load the next Tetromino
        animateCount = -1;
        eraseCleared();
        loadNext();
      }
    }
  }
  
  public void fillSquare(int col, int row, int c) {
    if (col < 0 || col >= cols || row < 0 || row >= rows)
      return;
    noStroke();
    fill(c);
    rect(x + col*(myWidth/cols), y + row*(myHeight/rows), myWidth/cols, myHeight/rows);
  }
  
  public void outlineSquare(int col, int row) {
    if (col < 0 || col >= cols || row < 0 || row >= rows)
      return;
    noFill();
    stroke(255);
    strokeWeight(2);
    rect(x + col*(myWidth/cols), y + row*(myHeight/rows), myWidth/cols, myHeight/rows);
  }
  
  public void endTurn() {
    for (int i = 0; i < curr.shape.matrix.length; ++i)
      for (int j = 0; j < curr.shape.matrix.length; ++j)
        if (curr.shape.matrix[i][j] && j + curr.y >= 0) 
          colors[i + curr.x][j + curr.y] = curr.getColor();
    if (checkLines()) {
      curr = null;
      animateCount = 0;
    } else
      loadNext();
  }
  
  public boolean checkLines() {
    clearedRows.clear();
    for (int j = 0; j < rows; ++j) {
      int count = 0;
      for (int i = 0; i < cols; ++i)
        if (isOccupied(i, j))
          count++;
      if (count >= cols)
        clearedRows.add(j);
    }
    if (clearedRows.isEmpty())
      return false;
      
    if (lines/10 < (lines + clearedRows.size())/10) {
      level++;
      timer -= SPEED_DECREASE;
    }
    lines += clearedRows.size();
    score += (1 << clearedRows.size() - 1)*100;
    return true;
  }
  
  public void eraseCleared() {
    for (int row : clearedRows) {
      for (int j = row - 1; j > 0; --j) {
        int[] rowCopy = new int[cols];
        for (int i = 0; i < cols; ++i)
          rowCopy[i] = colors[i][j];
        for (int i = 0; i < cols; ++i)
          colors[i][j + 1] = rowCopy[i];
      } 
    }
  }
  
  public boolean isOccupied(int x, int y) {
    if (y < 0 && x < cols && x >= 0) // allow movement/flipping to spaces above the board
      return false;
    return (x >= cols || x < 0 || y >= rows || colors[x][y] != 0);
  }
}
class Shape {
  boolean[][] matrix;
  int c;
  
  Shape(int n, int[] blockNums, int c) {
    matrix = new boolean[n][n];
    for (int x = 0; x < n; ++x)
      for (int y = 0; y < n; ++y) 
        matrix[x][y] = false;
    for (int i = 0; i < blockNums.length; ++i)
      matrix[blockNums[i]%n][blockNums[i]/n] = true;
    this.c = c;
  }
  
  Shape(Shape other) {
    matrix = new boolean[other.matrix.length][other.matrix.length];
    for (int x = 0; x < matrix.length; ++x)
      for (int y = 0; y < matrix.length; ++y)
        matrix[x][y] = other.matrix[x][y];
    this.c = other.c;
  }
  
  public void preview() {
    int startJ = 1;  // the preview grid is only 4X2, so we need to find where the block start
    for (int i = 0; i < matrix.length; ++i)
      if (matrix[i][0])
        startJ = 0;
    for (int i = 0; i < matrix.length; ++i)
      for (int j = startJ; j < matrix.length; ++j)
        if (matrix[i][j])
          preview.fillSquare(i, j - startJ, c);
  }
}
class Tetromino {
  Shape shape;
  int x, y;
  int final_row;
  
  Tetromino(Shape shape) {
    this.shape = new Shape(shape);
    x = 3;
    y = -2;
    final_row = getFinalRow();
    game_over = !isLegal(this.shape.matrix, 3, -1);
  }
  
  public int getColor() { return shape.c; }
  
  public void left() {
    if (isLegal(shape.matrix, x - 1, y))
      x--;
    else if (isLegal(shape.matrix, x - 2, y))
      x -= 2;
    update();
  }
  
  public void right() {
    if (isLegal(shape.matrix, x + 1, y))
      x++;
    else if (isLegal(shape.matrix, x + 2, y))
      x += 2;
    update();
  }
  
  public void update() {
    final_row = getFinalRow();
    // reset the timer if player is at the bottom, for wiggle room before it locks
    if (y == final_row)
      currTime = -20;
  }
  
  // used when player presses down.
  public void down() {
    if (y >= final_row) {
      // if already at the bottom, down shortcuts to lock current and load next block
      board.endTurn();
    } else {
      stepDown();
      score += 1;  // get a point for manual down
    }
  }
  
  // used when automatically moving the block down.
  public void stepDown() {
    if (y >= final_row) {
      board.endTurn();
    } else {
      y++;
      currTime = 0;
    }
  }
  
  // move block all the way to the bottom
  public void hardDown() {
    score += (board.rows - y);
    y = final_row;
    board.endTurn();
  }
  
  public void rotate() {
    boolean[][] ret = new boolean[shape.matrix.length][shape.matrix.length];
    for (int x = 0; x < ret.length; ++x)
        for (int y = 0; y < ret.length; ++y)
            ret[x][y] = shape.matrix[y][ret.length - 1 - x];
    if (isLegal(ret, x, y)) {
      shape.matrix = ret;
      update();
    } else if (isLegal(ret, x + 1, y) || isLegal(ret, x + 2, y)) {
      shape.matrix = ret;
      right();
    } else if (isLegal(ret, x - 1, y) || isLegal(ret, x - 2, y)) {
      shape.matrix = ret;
      left();
    }
  }
  
  public int getFinalRow() {
    int start = max (0, y);
    for (int row = start; row <= board.rows; ++row)
      if (!isLegal(shape.matrix, x, row))
        return row - 1;
    return -1;
  }
  
  public boolean isLegal(boolean[][] matrix, int col, int row) {
    for (int i = 0; i < matrix.length; ++i)
      for (int j = 0; j < matrix.length; ++j)
        if (matrix[i][j] && board.isOccupied(col + i, row + j))
          return false;
    return true;
  }
  
  public void draw() {
    for (int i = 0; i < shape.matrix.length; ++i) {
      for (int j = 0; j < shape.matrix.length; ++j) {
        if (shape.matrix[i][j]) {
          board.fillSquare(x + i, y + j, shape.c);
          board.outlineSquare(x + i, final_row + j);
        }
      }
    }
  }
  
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#DFDFDF", "Tetris" });
  }
}
