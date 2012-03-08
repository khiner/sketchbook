/*
  A rough implementation of the idea of statistical, polyphonic granular
  synthesis as visualized and controlled by bouncing particles
  Where the ball hits, the sound is triggered.
  Click to introduce a bouncing ball.
  Mess with the envelope, duration and spread of the grains.
  Ball collision adapted from kfinley2
*/

import controlP5.*;
import krister.Ess.*;

Sample[] samples = new Sample[3];
final int LEFT = 0;
final int BOTTOM = 1;
final int RIGHT = 2;
final float SNAP_DIST = 12;
int lowDuration = 3000;
int highDuration = 6000;
float lowPan = -.5;
float highPan = .5;
float gravity = 0.3;
float friction = -0.9;
float maxV = 20;
ControlP5 controlP5;
Particles particles = new Particles();
Envelope envelope;

void setup()
{
  size(800, 600, P2D);
  textMode(SCREEN);
  textSize(15);
  noSmooth();
  Ess.start(this);
  controlP5 = new ControlP5(this);
  //load the samples for each wall
  samples[LEFT] = new Sample(LEFT, 10, "valiha.aif");
  samples[BOTTOM] = new Sample(BOTTOM, 11, "african_vocal.wav");
  samples[RIGHT] = new Sample(RIGHT, 10, "sitar.aiff");
  envelope = new Envelope(0, .3, 1, .5, .6, .8, 0);  // set up the starting envelope
  controlP5.addToggle("envelopeToggle", true, envelope.x, envelope.y - 22, 20, 20).captionLabel().setVisible(false);
  controlP5.addRange("grainDuration", 100, 15000, lowDuration, highDuration, envelope.x, envelope.y + envelope.myHeight + 30, 100, 10).setLabel("Grain Duration");
  controlP5.addRange("spread", -1, 1, lowPan, highPan, envelope.x, envelope.y + envelope.myHeight + 50, 100, 10);
  controlP5.addToggle("leftToggle", true, envelope.x - 30, envelope.y, 15, 15).setLabel("Left");
  controlP5.addToggle("bottomToggle", true, envelope.x - 30, envelope.y + 35, 15, 15).setLabel("Bottom");
  controlP5.addToggle("rightToggle", true, envelope.x - 30, envelope.y + 70, 15, 15).setLabel("Right");
}

void mousePressed() {
  if (envelope.isMouseOver()) {
    PVector mouseVec = new PVector(mouseX, mouseY); 
    for (int i = 0; i < envelope.controlPoints.length; ++i) {
      if (envelope.controlPoints[i].dist(mouseVec) < SNAP_DIST) {
        envelope.selected = i;
        break;
      }
    }
  } else {
    particles.addParticle(mouseX, mouseY);
  }
}

void keyPressed() {
  if (key == DELETE || keyCode == 8)
    particles.removeParticle();
}

void mouseReleased() {
  envelope.selected = -1;
}

void draw()
{
  background(0);
  envelope.draw();
  particles.draw();
  for (Sample sample : samples)
    sample.draw();
  controlP5.draw();
}

void envelopeToggle(boolean value) {
  envelope.toggle();
}

void leftToggle(boolean value) {
  samples[LEFT].muted = !value;
}

void bottomToggle(boolean value) {
  samples[BOTTOM].muted = !value;
}

void rightToggle(boolean value) {
  samples[RIGHT].muted = !value;
}

void controlEvent(ControlEvent theControlEvent) {
  if(theControlEvent.controller().name().equals("grainDuration")) {
    lowDuration = int(theControlEvent.controller().arrayValue()[0]);
    highDuration = int(theControlEvent.controller().arrayValue()[1]);
  } else if(theControlEvent.controller().name().equals("spread")) {
    lowPan = int(theControlEvent.controller().arrayValue()[0]);
    highPan = int(theControlEvent.controller().arrayValue()[1]);
  }
}
