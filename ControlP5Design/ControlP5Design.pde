import controlP5.*;
import toxi.geom.*;

ControlP5 controlP5;
MyController selected = null;

ArrayList<MyController> controllers = new ArrayList<MyController>();
ArrayList<MyController> displays = new ArrayList<MyController>();

int shortDim = 15, longDim = 100;
float min = 0, max = 1;
float mid = .5*(max - min);

PVector mouseOffset = new PVector(0, 0);
boolean locked = false;

final int NONE = -1;
final int LEFT_SIDE = 0;
final int RIGHT_SIDE = 1;
final int BOTTOM_SIDE = 2;
final int TOP_SIDE = 3;
final int TOP_LEFT = 4;
final int TOP_RIGHT = 5;
final int BOTTOM_RIGHT = 6;
final int BOTTOM_LEFT = 7;

final int BACKGROUND = 0;
final int FOREGROUND = 1;
final int ACTIVE = 2;
final int CAPTION_LABEL = 3;
final int VALUE_LABEL = 4;

int stretch = NONE;

int origW = -1;
int origH = -1;
float origX = -1;
float origY = -1;

ColorWheel cw = new ColorWheel();
Button toolbox, textButton, cwButton;
ControlGroup bank;
DropdownList cwList;
int cwMode = NONE;

void setup() {
  size(700, 500);
  smooth();
  ellipseMode(RADIUS);
  controlP5 = new ControlP5(this);
  controlP5.setColorLabel(0);
  bank = controlP5.addGroup("bank", 0, 0, (int)(.2*width))
                  .setBackgroundHeight(height)
                  .setBackgroundColor(color(255, 0, 0, 100));
  toolbox = controlP5.addButton("toolbox", 0, 10, 10, 30, 30)
                     .setVisible(false);
  toolbox.setImage(loadImage("toolbox_sprite.png"));

  textButton = controlP5.addButton("textButton", 0, 10, 10, 45, 45)
                        .setVisible(false);
  textButton.setImage(loadImage("text_icon.png"));
  cwButton = controlP5.addButton("cwButton", 0, 100, 100, 45, 45)
                      .setVisible(false);
  cwButton.setImage(loadImage("color_wheel_icon.png"));
  cwList = controlP5.addDropdownList("color list", 300, 200, 100, 1000)
                    .setHeight(5000)
                    .setColorLabel(color(255))
                    .setVisible(false);
  cwList.addItem("background", BACKGROUND);
  cwList.addItem("foreground", FOREGROUND);
  cwList.addItem("active", ACTIVE);
  cwList.addItem("caption label", CAPTION_LABEL);
  cwList.addItem("value label", VALUE_LABEL);
  initializeDisplays();
}

void draw() {
  background(255);
  stroke(255, 0, 0);
  strokeWeight(5);
  noFill();
  if (selected != null) {
    Rect rect = selected.rectWithMouse().rect;
    rect(rect.x, rect.y, rect.width - 1, rect.height - 1);
  }
  cw.draw();
  // if we don't manually draw controlP5 elements here,
  // the rectangles and other elements drag behind.
  controlP5.draw();
}

void initializeDisplays() {
  displays.add(new MyController(controlP5.addSlider("slider", min, max, mid, 15, 20, longDim, shortDim)));
  displays.add(new MyController(controlP5.addSlider2D("slider2D", min, max, min, max, mid, mid, 15, 50, longDim, longDim)));
  displays.add(new MyController(controlP5.addButton("button", 0, 15, 200, shortDim*2, shortDim*2)));
  displays.add(new MyController(controlP5.addKnob("knob", min, max, mid, 15 + 50, 200, shortDim*3)));
  ListBox lb = controlP5.addListBox("listBox", 15, 300, 100, 50);
  for (int i = 0; i < 5; ++i)
    lb.addItem("item " + i, i);  
  displays.add(new MyController(lb));

  for (MyController c : displays) {
    c.setGroup(bank);
    c.setLabelVisible(false);
    c.lock();
  }
}

void toggleLock() {
  locked = !locked;
  for (MyController c : controllers) {
    if (locked)
      c.unlock();
    else
      c.lock();
  }
  if (locked) {
    selected = null;
    toolbox.setVisible(false);
    cwButton.setVisible(false);
  }
}

MyController createController(MyController display) {
  MyController controller = null;
  String newLabel = null;
  String displayLabel = display.label();
  int x = (int)display.position().x;
  int y = (int)display.position().y;
  int w = display.getWidth();
  int h = display.getHeight();

  for (int i = 0; i < 100; ++i) {
    if (controlP5.controller(displayLabel + ' ' + i) == null) {
      newLabel = displayLabel + ' ' + i;
      break;
    }
  }
  if (displayLabel.equals("slider"))
    controller = new MyController(controlP5.addSlider(newLabel, min, max, mid, x, y, w, h));
  else if (displayLabel.equals("slider2D"))
    controller = new MyController(controlP5.addSlider2D(newLabel, min, max, 
    min, max, mid, mid, x, y, w, h));
  else if (displayLabel.equals("button"))
    controller = new MyController(controlP5.addButton(newLabel, 0, x, y, w, h));
  else if (displayLabel.equals("knob"))
    controller = new MyController(controlP5.addKnob(newLabel, min, max, mid, x, y, w));
  else if (displayLabel.equals("listBox"))
    controller = new MyController(controlP5.addListBox(newLabel, x, y, w, h));
  if (!locked)
    controller.lock();

  controllers.add(controller);
  return controller;
}

MyController controllerWithMouse() {
  for (MyController c : displays)
    if (c.isMouseOver())
      return c;
  for (MyController c : controllers)
    if (c.isMouseOver())
      return c;
  return null;
}

void updateTools() {
  if (selected == null)
    return;
  float x = selected.position().x + selected.getWidth() + 5;
  float y = selected.position().y;
  float setX = x;
  if (x + toolbox.getWidth() >= width)
    setX = selected.position().x - toolbox.getWidth() - 5;
  toolbox.setPosition(setX, y);
  setX = x;
  if (x + cwButton.getWidth() >= width)
    setX = selected.position().x - cwButton.getWidth() - 5;
  cwButton.setPosition(setX, y);
  textButton.setPosition(setX, y + cwButton.getHeight() + 5);
  setX = x;
  if (x + cw.getWidth() >= width)
    setX = selected.position().x - cw.getWidth() - 5;
  cw.setPosition(setX, y);
  setX = x;
  if (x + cwList.getWidth() >= width)
    setX = selected.position().x - cwList.getWidth() - 5;
  cwList.setPosition(setX, y);
}

boolean mouseOverCwList() {
  return new Vec2D(mouseX, mouseY).isInRectangle(
  new Rect(cwList.getPosition().x, cwList.getPosition().y - 20, cwList.getWidth(), 20));
}

void mousePressed() {
  if (cw.isVisible() && cw.isMouseOver() && selected != null) {
    selected.setMovable(false);
    selected.setColor(cw.getSelectedColor());
    return;
  } 
  else
    cwMode = NONE;
  if (toolbox.isMousePressed() || cwButton.isMousePressed() || mouseOverCwList()) {
    return;
  }
  MyController controller = controllerWithMouse();

  if (controller != null) {
    if (displays.contains(controller))
      selected = createController(controller);
    else if (!locked) {
      stretch = controller.rectWithMouse().num;
      origW = controller.getWidth();
      origH = controller.getHeight();
      origX = controller.position().x;
      origY = controller.position().y;
      selected = controller;
    } 
    else
      selected = null;
  }
  else
    selected = null;

  cwButton.setVisible(false);
  textButton.setVisible(false);
  cw.setVisible(false);
  cwList.setVisible(false);
  if (selected != null) {
    mouseOffset = new PVector(mouseX - selected.position().x, mouseY - selected.position().y);
    updateTools();
    toolbox.setVisible(true);
  }
}

void mouseDragged() {
  if (selected != null) {
    if (cw.isVisible() && cw.isMouseOver()) {
      selected.setColor(cw.getSelectedColor());  
      return;
    }
    if (stretch == NONE)
      selected.testAndSetPosition(mouseX - mouseOffset.x, mouseY - mouseOffset.y);
    else switch (stretch) {
    case RIGHT_SIDE : 
      selected.stretchRight(); 
      break;
    case BOTTOM_SIDE : 
      selected.stretchBottom(); 
      break;
    case LEFT_SIDE : 
      selected.stretchLeft(); 
      break;
    case TOP_SIDE : 
      selected.stretchTop(); 
      break;
    case TOP_LEFT :
      selected.stretchTop();
      selected.stretchLeft();
      break;
    case TOP_RIGHT :
      selected.stretchTop();
      selected.stretchRight();
      break;
    case BOTTOM_LEFT :
      selected.stretchBottom();
      selected.stretchLeft();
      break;
    case BOTTOM_RIGHT :
      selected.stretchBottom();
      selected.stretchRight();
      break;
    }
    updateTools();
  }
}

void mouseReleased() {
  stretch = NONE;
  if (selected != null)
    selected.setMovable(true);
}

void keyPressed() {
  switch(key) {
  case 'u': 
    toggleLock(); 
    break;
  }
  switch(keyCode) {
  case UP :
    selected.moveUp();
    break;
  case DOWN :
    selected.moveDown();
    break;
  case RIGHT :
    selected.moveRight();
    break;
  case LEFT :
    selected.moveLeft();
    break;
  }
  updateTools();
}

void toolbox(int value) {
  toolbox.setVisible(false);
  cwButton.setVisible(true);
  textButton.setVisible(true);
}

void cwButton(int value) {
  cwButton.setVisible(false);
  textButton.setVisible(false);
  cwList.setVisible(true);
  cwList.setOpen(true);
  cw.setVisible(true);
}

void controlEvent(ControlEvent ce) {
  if (ce.isGroup()) {
    if (ce.group().name().equals("color list")) {
      cwMode = (int)ce.group().getValue();
      cw.setVisible(true);
    }
  }
}

