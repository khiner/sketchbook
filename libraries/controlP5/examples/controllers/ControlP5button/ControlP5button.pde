/**
 * ControlP5 Button
 * this example shows how to create buttons with controlP5.
 * 
 * find a list of public methods available for the Button Controller 
 * at the bottom of this sketch's source code
 *
 * by Andreas Schlegel, 2012
 * www.sojamo.de/libraries/controlp5
 *
 */
 
import controlP5.*;

ControlP5 cp5;

Button b;

// the controlP5 button-controller 'buttonValue' will change the
// value of variable 'buttonValue' when pressed.
int buttonValue = 255;

int myColor = color(255);


void setup() {
  size(700,400);
  noStroke();
  cp5 = new ControlP5(this);
  
  // create a new button with name 'buttonA'
  cp5.addButton("buttonA")
     .setValue(0)
     .setPosition(100,100)
     .setSize(200,19)
     ;
  
  // and add another 2 buttons
  cp5.addButton("buttonB")
     .setValue(255)
     .setPosition(100,120)
     .setSize(200,19)
     ;
     
  cp5.addButton("buttonValue")
     .setPosition(100,140)
     .setSize(200,19)
     ;

}

void draw() {
  background(myColor);
  fill(buttonValue);
  rect(20,20,width-40,height-40);
}

public void controlEvent(ControlEvent theEvent) {
  println(theEvent.controller().name());
}

// function buttonA will receive changes from 
// controller with name buttonA
public void buttonA(int theValue) {
  println("a button event from buttonA: "+theValue);
  myColor = color(0);
}

// function buttonB will receive changes from 
// controller with name buttonB
public void buttonB(int theValue) {
  println("a button event from buttonB: "+theValue);
  myColor = color(128);
}


/*
a list of all methods available for the Button Controller
use ControlP5.printPublicMethodsFor(Button.class);
to print the following list into the console.

You can find further details about class Button in the javadoc.

Format:
ClassName : returnType methodName(parameter type)


controlP5.Button : Button activateBy(int) 
controlP5.Button : Button setOff() 
controlP5.Button : Button setOn() 
controlP5.Button : Button setSwitch(boolean) 
controlP5.Button : Button setValue(float) 
controlP5.Button : Button update() 
controlP5.Button : String getInfo() 
controlP5.Button : String toString() 
controlP5.Button : boolean getBooleanValue() 
controlP5.Button : boolean isOn() 
controlP5.Button : boolean isPressed() 
controlP5.Controller : Button addCallback(CallbackListener) 
controlP5.Controller : Button addListener(ControlListener) 
controlP5.Controller : Button bringToFront() 
controlP5.Controller : Button bringToFront(ControllerInterface) 
controlP5.Controller : Button hide() 
controlP5.Controller : Button linebreak() 
controlP5.Controller : Button listen(boolean) 
controlP5.Controller : Button lock() 
controlP5.Controller : Button plugTo(Object) 
controlP5.Controller : Button plugTo(Object, String) 
controlP5.Controller : Button plugTo(Object[]) 
controlP5.Controller : Button plugTo(Object[], String) 
controlP5.Controller : Button registerProperty(String) 
controlP5.Controller : Button registerProperty(String, String) 
controlP5.Controller : Button registerTooltip(String) 
controlP5.Controller : Button removeBehavior() 
controlP5.Controller : Button removeCallback() 
controlP5.Controller : Button removeCallback(CallbackListener) 
controlP5.Controller : Button removeListener(ControlListener) 
controlP5.Controller : Button removeProperty(String) 
controlP5.Controller : Button removeProperty(String, String) 
controlP5.Controller : Button setArrayValue(float[]) 
controlP5.Controller : Button setArrayValue(int, float) 
controlP5.Controller : Button setBehavior(ControlBehavior) 
controlP5.Controller : Button setBroadcast(boolean) 
controlP5.Controller : Button setCaptionLabel(String) 
controlP5.Controller : Button setColor(CColor) 
controlP5.Controller : Button setColorActive(int) 
controlP5.Controller : Button setColorBackground(int) 
controlP5.Controller : Button setColorCaptionLabel(int) 
controlP5.Controller : Button setColorForeground(int) 
controlP5.Controller : Button setColorValueLabel(int) 
controlP5.Controller : Button setDecimalPrecision(int) 
controlP5.Controller : Button setDefaultValue(float) 
controlP5.Controller : Button setHeight(int) 
controlP5.Controller : Button setId(int) 
controlP5.Controller : Button setImages(PImage, PImage, PImage) 
controlP5.Controller : Button setImages(PImage, PImage, PImage, PImage) 
controlP5.Controller : Button setLabelVisible(boolean) 
controlP5.Controller : Button setLock(boolean) 
controlP5.Controller : Button setMax(float) 
controlP5.Controller : Button setMin(float) 
controlP5.Controller : Button setMouseOver(boolean) 
controlP5.Controller : Button setMoveable(boolean) 
controlP5.Controller : Button setPosition(PVector) 
controlP5.Controller : Button setPosition(float, float) 
controlP5.Controller : Button setSize(PImage) 
controlP5.Controller : Button setSize(int, int) 
controlP5.Controller : Button setStringValue(String) 
controlP5.Controller : Button setUpdate(boolean) 
controlP5.Controller : Button setValueLabel(String) 
controlP5.Controller : Button setView(ControllerView) 
controlP5.Controller : Button setVisible(boolean) 
controlP5.Controller : Button setWidth(int) 
controlP5.Controller : Button show() 
controlP5.Controller : Button unlock() 
controlP5.Controller : Button unplugFrom(Object) 
controlP5.Controller : Button unplugFrom(Object[]) 
controlP5.Controller : Button unregisterTooltip() 
controlP5.Controller : Button update() 
controlP5.Controller : Button updateSize() 
controlP5.Controller : CColor getColor() 
controlP5.Controller : ControlBehavior getBehavior() 
controlP5.Controller : ControlWindow getControlWindow() 
controlP5.Controller : ControlWindow getWindow() 
controlP5.Controller : ControllerProperty getProperty(String) 
controlP5.Controller : ControllerProperty getProperty(String, String) 
controlP5.Controller : Label getCaptionLabel() 
controlP5.Controller : Label getValueLabel() 
controlP5.Controller : List getControllerPlugList() 
controlP5.Controller : PImage setImage(PImage) 
controlP5.Controller : PImage setImage(PImage, int) 
controlP5.Controller : PVector getAbsolutePosition() 
controlP5.Controller : PVector getPosition() 
controlP5.Controller : String getAddress() 
controlP5.Controller : String getInfo() 
controlP5.Controller : String getName() 
controlP5.Controller : String getStringValue() 
controlP5.Controller : String toString() 
controlP5.Controller : Tab getTab() 
controlP5.Controller : boolean isActive() 
controlP5.Controller : boolean isBroadcast() 
controlP5.Controller : boolean isInside() 
controlP5.Controller : boolean isLabelVisible() 
controlP5.Controller : boolean isListening() 
controlP5.Controller : boolean isLock() 
controlP5.Controller : boolean isMouseOver() 
controlP5.Controller : boolean isMousePressed() 
controlP5.Controller : boolean isMoveable() 
controlP5.Controller : boolean isUpdate() 
controlP5.Controller : boolean isVisible() 
controlP5.Controller : float getArrayValue(int) 
controlP5.Controller : float getDefaultValue() 
controlP5.Controller : float getMax() 
controlP5.Controller : float getMin() 
controlP5.Controller : float getValue() 
controlP5.Controller : float[] getArrayValue() 
controlP5.Controller : int getDecimalPrecision() 
controlP5.Controller : int getHeight() 
controlP5.Controller : int getId() 
controlP5.Controller : int getWidth() 
controlP5.Controller : int listenerSize() 
controlP5.Controller : void remove() 
controlP5.Controller : void setView(ControllerView, int) 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 


*/



