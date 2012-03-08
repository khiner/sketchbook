/**
 * ControlP5 Accordion
 * arrange controller groups in an accordion like style.
 *
 * find a list of public methods available for the Accordion Controller 
 * at the bottom of this sketch.
 *
 * by Andreas Schlegel, 2012
 * www.sojamo.de/libraries/controlp5
 *
 */

import controlP5.*;

ControlP5 cp5;

Accordion accordion;

void setup() {
  size(700, 400);

  cp5 = new ControlP5(this);

  // group number 1, contains 2 bangs
  Group g1 = cp5.addGroup("myGroup1")
                .setBackgroundColor(color(255, 30))
                .setBackgroundHeight(150)
                ;
  
  cp5.addBang("A-1")
     .setPosition(10,20)
     .setSize(20,20)
     .moveTo(g1)
     ;
     
  cp5.addBang("A-2")
     .setPosition(40,20)
     .setSize(20,20)
     .moveTo(g1)
     ;

  // group number 2, contains a radiobutton
  Group g2 = cp5.addGroup("myGroup2")
                .setBackgroundColor(color(255, 30))
                .setBackgroundHeight(150)
                ;
  
  cp5.addRadioButton("radio")
     .setPosition(10,20)
     .setItemWidth(20)
     .setItemHeight(20)
     .addItem("black", 0)
     .addItem("red", 1)
     .addItem("green", 2)
     .addItem("blue", 3)
     .addItem("grey", 4)
     .setColorLabel(color(255))
     .activate(1)
     .moveTo(g2)
     ;

  // group number 3, contains a bang and a slider
  Group g3 = cp5.addGroup("myGroup3")
                .setBackgroundColor(color(255, 30))
                .setBackgroundHeight(50)
                ;
  
  cp5.addBang("B-1")
     .setPosition(10,20)
     .setSize(20,20)
     .moveTo(g3)
     ;
     
  cp5.addSlider("hello")
     .setPosition(100,20)
     .setSize(100,20)
     .setMin(0)
     .setMax(200)
     .setValue(50)
     .moveTo(g3)
     ;

  // create a new accordion
  // add g1, g2, and g3 to the accordion.
  accordion = cp5.addAccordion("acc")
                 .setPosition(100,50)
                 .setWidth(500)
                 .addItem(g1)
                 .addItem(g2)
                 .addItem(g3)
                 ;
}



void keyPressed() {
  // make some changes to the accordion
  if (key=='1') {
    cp5.remove("myGroup1");
  } 
  else if (key=='2') {
    accordion.setWidth(300);
  } 
  else if (key=='3') {
    accordion.setItemHeight(100);
  }
}

void draw() {
  background(0);
}



/*
a list of all methods available for the Accordion Controller
use ControlP5.printPublicMethodsFor(Accordion.class);
to print the following list into the console.

You can find further details about class Accordion in the javadoc.

Format:
ClassName : returnType methodName(parameter type)


controlP5.Accordion : Accordion addItem(ControlGroup) 
controlP5.Accordion : Accordion remove(ControllerInterface) 
controlP5.Accordion : Accordion removeItem(ControlGroup) 
controlP5.Accordion : Accordion setItemHeight(int) 
controlP5.Accordion : Accordion setMinItemHeight(int) 
controlP5.Accordion : Accordion setWidth(int) 
controlP5.Accordion : Accordion updateItems() 
controlP5.Accordion : int getItemHeight() 
controlP5.Accordion : int getMinItemHeight() 
controlP5.ControlGroup : Accordion activateEvent(boolean) 
controlP5.ControlGroup : Accordion addListener(ControlListener) 
controlP5.ControlGroup : Accordion hideBar() 
controlP5.ControlGroup : Accordion removeListener(ControlListener) 
controlP5.ControlGroup : Accordion setBackgroundColor(int) 
controlP5.ControlGroup : Accordion setBackgroundHeight(int) 
controlP5.ControlGroup : Accordion setBarHeight(int) 
controlP5.ControlGroup : Accordion showBar() 
controlP5.ControlGroup : Accordion updateInternalEvents(PApplet) 
controlP5.ControlGroup : String getInfo() 
controlP5.ControlGroup : String toString() 
controlP5.ControlGroup : boolean isBarVisible() 
controlP5.ControlGroup : int getBackgroundHeight() 
controlP5.ControlGroup : int getBarHeight() 
controlP5.ControlGroup : int listenerSize() 
controlP5.ControllerGroup : Accordion add(ControllerInterface) 
controlP5.ControllerGroup : Accordion bringToFront() 
controlP5.ControllerGroup : Accordion bringToFront(ControllerInterface) 
controlP5.ControllerGroup : Accordion close() 
controlP5.ControllerGroup : Accordion disableCollapse() 
controlP5.ControllerGroup : Accordion enableCollapse() 
controlP5.ControllerGroup : Accordion hide() 
controlP5.ControllerGroup : Accordion moveTo(ControlWindow) 
controlP5.ControllerGroup : Accordion moveTo(PApplet) 
controlP5.ControllerGroup : Accordion open() 
controlP5.ControllerGroup : Accordion registerProperty(String) 
controlP5.ControllerGroup : Accordion registerProperty(String, String) 
controlP5.ControllerGroup : Accordion remove(CDrawable) 
controlP5.ControllerGroup : Accordion remove(ControllerInterface) 
controlP5.ControllerGroup : Accordion removeCanvas(ControlWindowCanvas) 
controlP5.ControllerGroup : Accordion removeProperty(String) 
controlP5.ControllerGroup : Accordion removeProperty(String, String) 
controlP5.ControllerGroup : Accordion setAddress(String) 
controlP5.ControllerGroup : Accordion setArrayValue(float[]) 
controlP5.ControllerGroup : Accordion setColor(CColor) 
controlP5.ControllerGroup : Accordion setColorActive(int) 
controlP5.ControllerGroup : Accordion setColorBackground(int) 
controlP5.ControllerGroup : Accordion setColorForeground(int) 
controlP5.ControllerGroup : Accordion setColorLabel(int) 
controlP5.ControllerGroup : Accordion setColorValue(int) 
controlP5.ControllerGroup : Accordion setHeight(int) 
controlP5.ControllerGroup : Accordion setId(int) 
controlP5.ControllerGroup : Accordion setLabel(String) 
controlP5.ControllerGroup : Accordion setMouseOver(boolean) 
controlP5.ControllerGroup : Accordion setMoveable(boolean) 
controlP5.ControllerGroup : Accordion setOpen(boolean) 
controlP5.ControllerGroup : Accordion setPosition(PVector) 
controlP5.ControllerGroup : Accordion setPosition(float, float) 
controlP5.ControllerGroup : Accordion setStringValue(String) 
controlP5.ControllerGroup : Accordion setUpdate(boolean) 
controlP5.ControllerGroup : Accordion setValue(float) 
controlP5.ControllerGroup : Accordion setVisible(boolean) 
controlP5.ControllerGroup : Accordion setWidth(int) 
controlP5.ControllerGroup : Accordion show() 
controlP5.ControllerGroup : Accordion update() 
controlP5.ControllerGroup : Accordion updateAbsolutePosition() 
controlP5.ControllerGroup : CColor getColor() 
controlP5.ControllerGroup : ControlWindow getWindow() 
controlP5.ControllerGroup : ControlWindowCanvas addCanvas(ControlWindowCanvas) 
controlP5.ControllerGroup : Controller getController(String) 
controlP5.ControllerGroup : ControllerProperty getProperty(String) 
controlP5.ControllerGroup : ControllerProperty getProperty(String, String) 
controlP5.ControllerGroup : Label getCaptionLabel() 
controlP5.ControllerGroup : Label getValueLabel() 
controlP5.ControllerGroup : PVector getPosition() 
controlP5.ControllerGroup : String getAddress() 
controlP5.ControllerGroup : String getInfo() 
controlP5.ControllerGroup : String getName() 
controlP5.ControllerGroup : String getStringValue() 
controlP5.ControllerGroup : String toString() 
controlP5.ControllerGroup : Tab getTab() 
controlP5.ControllerGroup : boolean isCollapse() 
controlP5.ControllerGroup : boolean isMouseOver() 
controlP5.ControllerGroup : boolean isMoveable() 
controlP5.ControllerGroup : boolean isOpen() 
controlP5.ControllerGroup : boolean isUpdate() 
controlP5.ControllerGroup : boolean isVisible() 
controlP5.ControllerGroup : boolean setMousePressed(boolean) 
controlP5.ControllerGroup : float getValue() 
controlP5.ControllerGroup : float[] getArrayValue() 
controlP5.ControllerGroup : int getHeight() 
controlP5.ControllerGroup : int getId() 
controlP5.ControllerGroup : int getWidth() 
controlP5.ControllerGroup : void remove() 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 


*/



