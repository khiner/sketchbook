/* All Mode constants are held here. */

final int NONE = -1;
// select modes
final int SELECT = 0;
final int MOUSE_ATTRACT = 1;
final int RECT_SELECT = 2;
// shoot modes
final int SHOOT = 3;
final int GRID = 4;
final int CELLS = 5;
// display modes
final int CIRCLE = 6;
final int SQUARE = 7;
final int CONFETTI = 8;
// rect modes
final int TRANSPOSE = 9;
final int DRAG = 10;
int selectMode = NONE;
int shootMode = GRID;
int displayMode = CONFETTI;
int rectMode = NONE;
