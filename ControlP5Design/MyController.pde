class MyController {
  ControllerInterface controller;
  boolean movable = true;

  MyController(ControllerInterface controller) {
    this.controller = controller;
  }

  PVector position() { 
    return controller.getPosition();
  }

  int getWidth() { 
    return controller.getWidth();
  }

  int getHeight() { 
    return controller.getHeight();
  }

  void setPosition(float x, float y) {
    controller.setPosition(x, y);
  }

  void setWidth(int w) {
    if (controller instanceof ListBox) {
      ListBox l = (ListBox)controller;
      l.setWidth(w);
    } 
    else if (controller instanceof Controller) {
      Controller c = (Controller)controller;
      c.setWidth(w);
    }
  }

  void setHeight(int h) {
    if (controller instanceof ListBox) {
      ListBox l = (ListBox)controller;
      l.setHeight(h);
    } 
    else if (controller instanceof Controller) {
      Controller c = (Controller)controller;
      c.setHeight(h);
    }
  }

  void setGroup(ControllerGroup theGroup) {
    if (controller instanceof ControllerGroup) {
      ControllerGroup cg = (ControllerGroup)controller;
      cg.setGroup(theGroup);
    } 
    else if (controller instanceof Controller) {
      Controller c = (Controller)controller;
      c.setGroup(theGroup);
    }
  }

  void setLabelVisible(boolean flag) {
    if (controller instanceof ControllerGroup) {
      ControllerGroup cg = (ControllerGroup)controller;
      cg.captionLabel().setVisible(flag);
    } 
    else if (controller instanceof Controller) {
      Controller c = (Controller)controller;
      c.setLabelVisible(flag);
    }
  }

  void setColor(color c) {
    switch (cwMode) {
    case BACKGROUND:
      controller.setColorBackground(c);
      break;
    case FOREGROUND:
      controller.setColorForeground(c);
      break;
    case ACTIVE:
      controller.setColorActive(c);
      break;
    case CAPTION_LABEL:
      controller.setColorLabel(c);
      break;
    case VALUE_LABEL:
      controller.setColorValue(c);
      break;
    }
  }

  void lock() { 
    if (controller instanceof Controller) {
      Controller c = (Controller)controller;
      c.lock();
    }
  }

  void unlock() { 
    if (controller instanceof Controller) {
      Controller c = (Controller)controller;
      c.unlock();
    }
  }

  String label() {
    if (controller instanceof Controller) {
      Controller c = (Controller)controller;
      return c.getLabel();
    } 
    else if (controller instanceof ControllerGroup) {
      ControllerGroup g = (ControllerGroup)controller;
      return g.getCaptionLabel().toString();
    } 
    else
      return "";
  }

  boolean isMouseOver() {
    if (new Vec2D(mouseX, mouseY).isInRectangle(new Rect(position().x, position().y, 
    getWidth(), getHeight())))
      return true;
    else
      return false;
  }

  Rectangle rectWithMouse() {
    Vec2D mouseVec = new Vec2D(mouseX, mouseY);
    Rect rect = new Rect(position().x, position().y, getWidth()/5, getHeight()/5);
    if (mouseVec.isInRectangle(rect))
      return new Rectangle(rect, TOP_LEFT);
    rect = new Rect(position().x + .8*getWidth(), position().y, getWidth()/5, getHeight()/5);
    if (mouseVec.isInRectangle(rect))
      return new Rectangle(rect, TOP_RIGHT);
    rect = new Rect(position().x, position().y + .8*getHeight(), getWidth()/5, getHeight()/5);
    if (mouseVec.isInRectangle(rect))
      return new Rectangle(rect, BOTTOM_LEFT);
    rect = new Rect(position().x + .8*getWidth(), position().y + .8*getHeight(), getWidth()/5, getHeight()/5);
    if (mouseVec.isInRectangle(rect))
      return new Rectangle(rect, BOTTOM_RIGHT);
    rect = new Rect(position().x, position().y, getWidth()/5, getHeight());
    if (mouseVec.isInRectangle(rect))
      return new Rectangle(rect, LEFT_SIDE);
    rect = new Rect(position().x, position().y, getWidth(), getHeight()/5);
    if (mouseVec.isInRectangle(rect))
      return new Rectangle(rect, TOP_SIDE);
    rect = new Rect(position().x, position().y + .8*getHeight(), getWidth(), getHeight()/5);
    if (mouseVec.isInRectangle(rect))
      return new Rectangle(rect, BOTTOM_SIDE);
    rect = new Rect(position().x + .8*getWidth(), position().y, getWidth()/5, getHeight());
    if (mouseVec.isInRectangle(rect))
      return new Rectangle(rect, RIGHT_SIDE);
    rect = new Rect(position().x, position().y, getWidth() - 1, getHeight() - 1);
    return new Rectangle(rect, NONE);
  }

  boolean testAndSetPosition(float x, float y) {
    if (!movable)
      return false;
    boolean ret = true;
    if (x < bank.getWidth() + 2) {
      setPosition(bank.getWidth() + 2, position().y);
      ret = false;
    }
    else if ((stretch == RIGHT_SIDE || stretch == TOP_RIGHT ||
              stretch == BOTTOM_RIGHT) && x > width - getWidth()) {
      setPosition(width - getWidth() - 2, position().y);
      ret = false;
    } // if we are dragging the left side of a controller,
      // we can only drag to just before its right side
    else if ((stretch == BOTTOM_LEFT || stretch == LEFT_SIDE ||
              stretch == TOP_LEFT) && x > origX + origW - 5)
      setPosition(origX + origW - 5, position().y);
    else
      setPosition(x, position().y);
    if (y < 2) {
      setPosition(position().x, 2);
      ret = false;
    }
    else if ((stretch == BOTTOM_SIDE || stretch == BOTTOM_LEFT ||
              stretch == BOTTOM_RIGHT) && y > height - getHeight()) {
      setPosition(position().x, height - getHeight() - 2);
      ret = false;
    } // if we are dragging the top side of a controller,
      // we can only drag to just before its right side
    else if ((stretch == TOP_SIDE || stretch == TOP_LEFT ||
              stretch == TOP_RIGHT) && y > origY + origH - 5)
      setPosition(position().x, origY + origH - 5);
    else
      setPosition(position().x, y);
    return ret;
  }

  void testAndSetDimensions(int w, int h) {
    if (position().x + w > width)
      setWidth((int)(width - position().x - 2));
    else if (w < 5)
      setWidth(5);
    else
      setWidth(w);
    if (position().y + h > height)
      setHeight((int)(height - position().y - 2));
    else if (h < 5)
      setHeight(5);
    else
      setHeight(h);
  }

  void stretchLeft() {
    if (testAndSetPosition(mouseX - mouseOffset.x, position().y))
      testAndSetDimensions((int)(origX + origW - mouseX + mouseOffset.x), getHeight());
  }

  void stretchRight() {
    testAndSetDimensions((int)(origW - mouseOffset.x + mouseX - position().x), getHeight());
  }

  void stretchBottom() {
    testAndSetDimensions(getWidth(), (int)(origH - mouseOffset.y + mouseY - position().y));
  }

  void stretchTop() {
    if (testAndSetPosition(position().x, mouseY - mouseOffset.y))
      testAndSetDimensions(getWidth(), (int)(origY + origH - mouseY + mouseOffset.y));
  }

  boolean isMovable() { return movable; }
  
  void setMovable(boolean flag) { movable = flag; }
  
  void moveRight() {
    testAndSetPosition(position().x + 1, position().y);
  }

  void moveDown() {
    testAndSetPosition(position().x, position().y + 1);
  }

  void moveUp() {
    testAndSetPosition(position().x, position().y - 1);
  }

  void moveLeft() {
    testAndSetPosition(position().x - 1, position().y);
  }
}

