import processing.core.*; 
import processing.xml.*; 

import controlP5.*; 
import krister.Ess.*; 

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

public class GrainBounce extends PApplet {

/*
  A rough implementation of the idea of statistical, polyphonic granular
  synthesis as visualized and controlled by bouncing particles
  Where the ball hits, the sound is triggered.
  Click to introduce a bouncing ball.
  Mess with the envelope, duration and spread of the grains.
  Ball collision adapted from kfinley2
*/




Sample[] samples = new Sample[3];
final int LEFT = 0;
final int BOTTOM = 1;
final int RIGHT = 2;
final float SNAP_DIST = 12;
int lowDuration = 3000;
int highDuration = 6000;
float lowPan = -.5f;
float highPan = .5f;
float gravity = 0.3f;
float friction = -0.9f;
float maxV = 20;
ControlP5 controlP5;
Particles particles = new Particles();
Envelope envelope;

public void setup()
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
  envelope = new Envelope(0, .3f, 1, .5f, .6f, .8f, 0);  // set up the starting envelope
  controlP5.addToggle("envelopeToggle", true, envelope.x, envelope.y - 22, 20, 20).captionLabel().setVisible(false);
  controlP5.addRange("grainDuration", 100, 15000, lowDuration, highDuration, envelope.x, envelope.y + envelope.myHeight + 30, 100, 10).setLabel("Grain Duration");
  controlP5.addRange("spread", -1, 1, lowPan, highPan, envelope.x, envelope.y + envelope.myHeight + 50, 100, 10);
  controlP5.addToggle("leftToggle", true, envelope.x - 30, envelope.y, 15, 15).setLabel("Left");
  controlP5.addToggle("bottomToggle", true, envelope.x - 30, envelope.y + 35, 15, 15).setLabel("Bottom");
  controlP5.addToggle("rightToggle", true, envelope.x - 30, envelope.y + 70, 15, 15).setLabel("Right");
}

public void mousePressed() {
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

public void keyPressed() {
  if (key == DELETE || keyCode == 8)
    particles.removeParticle();
}

public void mouseReleased() {
  envelope.selected = -1;
}

public void draw()
{
  background(0);
  envelope.draw();
  particles.draw();
  for (Sample sample : samples)
    sample.draw();
  controlP5.draw();
}

public void envelopeToggle(boolean value) {
  envelope.toggle();
}

public void leftToggle(boolean value) {
  samples[LEFT].muted = !value;
}

public void bottomToggle(boolean value) {
  samples[BOTTOM].muted = !value;
}

public void rightToggle(boolean value) {
  samples[RIGHT].muted = !value;
}

public void controlEvent(ControlEvent theControlEvent) {
  if(theControlEvent.controller().name().equals("grainDuration")) {
    lowDuration = PApplet.parseInt(theControlEvent.controller().arrayValue()[0]);
    highDuration = PApplet.parseInt(theControlEvent.controller().arrayValue()[1]);
  } else if(theControlEvent.controller().name().equals("spread")) {
    lowPan = PApplet.parseInt(theControlEvent.controller().arrayValue()[0]);
    highPan = PApplet.parseInt(theControlEvent.controller().arrayValue()[1]);
  }
}
class Envelope extends AudioFilter {
  
  //display settings
  int myWidth = 200;
  int myHeight = 100;
  int x = width - 250;
  int y = 30;
  float controlDiameter = 8; //diameter of control circles
  boolean enabled = true;
  
  PVector[] controlPoints = new PVector[5];
  EPoint[] ePoints = new EPoint[5];
  krister.Ess.Envelope essEnvelope;
  
  private int selected = -1;
  
  Envelope(float startAmp, float attackTime, float attackAmp, float decayTime, float decayAmp, float susTime, float endAmp) {
    ePoints[0] = new EPoint(0, startAmp);
    ePoints[1] = new EPoint(attackTime, attackAmp);
    ePoints[2] = new EPoint(decayTime, decayAmp);
    ePoints[3] = new EPoint(susTime, decayAmp);
    ePoints[4] = new EPoint(1, endAmp);
    essEnvelope = new krister.Ess.Envelope(ePoints);
    controlPoints[0] = new PVector(x, y + myHeight - startAmp*myHeight);
    controlPoints[1] = new PVector(x + myWidth*attackTime, y + myHeight - attackAmp*myHeight);
    controlPoints[2] = new PVector(x + myWidth*decayTime, y + myHeight - decayAmp*myHeight);
    controlPoints[3] = new PVector(x + myWidth*susTime, controlPoints[2].y);
    controlPoints[4] = new PVector(x + myWidth, y + myHeight - endAmp*myHeight);
  }
  
  /*
   The following methods translate an x and y position to an the amp and time percentages for
   attack, decay, sustain, and release, as well as limiting the dragging
   to the envelope window.
  */
  
  public void setStartAmp(PVector start) {
    start.y = bound(start.y, y, y + myHeight);
    controlPoints[0].set(x, start.y, 0);
    ePoints[0] = new EPoint(0, map(controlPoints[0].y, y, y + myHeight, 1, 0));
  }
  
  public void setAttack(PVector attack) {
    attack.x = bound(attack.x, x, controlPoints[2].x);
    attack.y = bound(attack.y, y, y + myHeight);
    controlPoints[1].set(attack.x, attack.y, 0);
    ePoints[1] = new EPoint(map(controlPoints[1].x, x, x + myWidth, 0, 1), map(controlPoints[1].y, y, y + myHeight, 1, 0));
  }
  
  public void setDecay(PVector decay) {
    decay.x = bound(decay.x, controlPoints[1].x, controlPoints[3].x);
    decay.y = bound(decay.y, y, y + myHeight);
    controlPoints[2].set(decay.x, decay.y, 0);
    controlPoints[3].y = controlPoints[2].y;
    float time = map(controlPoints[2].x, x, x + myWidth, 0, 1);
    float amp = map(controlPoints[2].y, y, y + myHeight, 1, 0);
    ePoints[2] = new EPoint(time, amp);
    ePoints[3] = new EPoint(ePoints[3].t, amp);
  }
  
  public void setSustain(PVector sustain) {
    sustain.x = bound(sustain.x, controlPoints[2].x, x + myWidth);
    sustain.y = bound(sustain.y, y, y + myHeight);
    controlPoints[3].set(sustain.x, sustain.y, 0);
    controlPoints[2].y = controlPoints[3].y;
    float time = map(controlPoints[3].x, x, x + myWidth, 0, 1);
    float amp = map(controlPoints[3].y, y, y + myHeight, 1, 0);
    ePoints[3] = new EPoint(time, amp);
    ePoints[2] = new EPoint(ePoints[2].t, amp);
  }
  
  public void setEndAmp(PVector end) {
    end.y = bound(end.y, y, y + myHeight);
    controlPoints[4].set(x + myWidth, end.y, 0);
    ePoints[4] = new EPoint(1, map(controlPoints[4].y, y, y + myHeight, 1, 0));
  }
  
  /*
     Called for every draw event, to check which, if any, control points are
     being moved, and to update the envlope accordingly
  */
  public void update() {
    if (selected != -1 && mousePressed) {
      PVector mouseVec = new PVector(mouseX, mouseY);
      switch(selected) {
        case 0: setStartAmp(mouseVec); break;
        case 1: setAttack(mouseVec); break;
        case 2: setDecay(mouseVec); break;
        case 3: setSustain(mouseVec); break;
        case 4: setEndAmp(mouseVec); break;
      }
      essEnvelope = new krister.Ess.Envelope(ePoints);
    }
  }
  
  public void draw() {
    //check if control points are being dragged
    update();
    fill(255);
    text("Grain Envelope", x + 22, y - 7);
    // draw display rectangle
    stroke(255);
    fill(0,0, 80, 180);
    rect(x, y, myWidth, myHeight);
    
    // draw lines between control points
    noFill();
    beginShape();
    for (PVector vec : controlPoints) {
      vertex(vec.x, vec.y);
    }
    endShape();
    // fill the ADSR sections with different colors
    noStroke();
    fillADSR(0, color(0,255,0,120), "A");
    fillADSR(1, color(255,165,0,200), "D");
    fillADSR(2, color(0, 0, 255, 180), "S");
    fillADSR(3, color(160, 32, 240, 220), "R");
    // draw control points
    for (PVector vec : controlPoints) {
      if (selected != -1 && controlPoints[selected].equals(vec))
        fill(255,0,0);
      else
        fill(255);
      ellipse(vec.x, vec.y, controlDiameter, controlDiameter);
    }
  }

  public void fillADSR(int cp, int c, String t) {
    fill(c);
    beginShape();
    vertex(controlPoints[cp].x, y + myHeight);
    vertex(controlPoints[cp].x, controlPoints[cp].y);
    vertex(controlPoints[cp+1].x, controlPoints[cp+1].y);
    vertex(controlPoints[cp+1].x, y + myHeight);
    endShape();
    text(t, (controlPoints[cp].x + controlPoints[cp+1].x)/2, y + myHeight + 20);
  }
 
  /* Check if the mouse is over the envelope window, or the surrounding buttons */
  public boolean isMouseOver() {
    if (mouseX > x - 40 && mouseX < x + myWidth + 5 && mouseY > 0 && mouseY < y + myHeight + 65)
      return true;
    else
      return false;
  } 
  
  public void toggle() { enabled = !enabled; }
  
  public krister.Ess.Envelope getEnvelope() {
    return essEnvelope;
  }
}

/* Basic mathematical bound of num to a min and max */
public float bound(float num, float min, float max) {
  if (num < min)
    return min;
  else if (num > max)
    return max;
  else
    return num;
}
class Particle {
  float x, y,z;
  float diameter;
  float vx = 0;
  float vy = 0;
  float vz = 0;
  int id;
  ArrayList<Particle> particles;
 
  Particle(float vx, float vy, float x, float y, float d, ArrayList<Particle> particles) {
    this.vx = vx;
    this.vy = vy;
    this.x = x;
    this.y = y;
    this.z = z;
    diameter = d;
    this.particles = particles;
    id = particles.size();
  }
 
  public void collide() {
    for (int i = id + 1; i < particles.size(); ++i) {
      Particle other = particles.get(i);
      float dx = other.x - x;
      float dy = other.y - y;
      float distance = sqrt(dx*dx + dy*dy);
      //float minDist = particles.get(i).diameter/2 + diameter/2;
      // using fixed diameter = this.radius + other.radius
      if (distance < diameter) {
        float angle = atan2(dy, dx);
        float targetX = x + cos(angle)*diameter;//minDist;
        float targetY = y + sin(angle)*diameter;//minDist;
        float ax = (targetX - other.x);
        float ay = (targetY - other.y);
        vx -= ax;
        vy -= ay;
        other.vx += ax;
        other.vy += ay;
        break;
      }
    }
    if (vx > maxV)
      vx = maxV;
    if (vy > maxV)
      vy = maxV;
  }

   public void move() {
    vy += gravity;
    x += vx;
    y += vy;
    if (x + diameter/2 > width) {
      x = width - diameter/2;
      //vx *= friction;
      vx = -vx;
      if (!samples[RIGHT].muted)
        samples[RIGHT].play(y);
    }
    else if (x - diameter/2 < 0) {
      x = diameter/2;
      //vx *= friction;
      vx = -vx;
      if (!samples[LEFT].muted)
        samples[LEFT].play(y);
    }
    if (y + diameter/2 > height) { //>height = 400
      y = height - diameter/2;
      //vy *= friction;
      vy = -vy;
      if (!samples[BOTTOM].muted)
        samples[BOTTOM].play(x);
    }
    else if (y - diameter/2 < 0) {
      y = diameter/2;
      //vy *= friction;
      vy = -vy;
    }
  }
 
  public void draw() {
    fill(255, 200);
    noStroke();
    ellipse(x, y, diameter, diameter);
  }
}
class Particles {
  ArrayList<Particle> particles;
  
  Particles() {
    particles = new ArrayList<Particle>();
  }
  
  public void addParticle(float x, float y) {
    particles.add(new Particle(0, random(10,20), mouseX, mouseY, 20, particles));
  }
  
  public void removeParticle() {
    particles.remove(particles.size() - 1);
  }
  
  public void draw() {
    for (Particle p : particles) {
      p.collide();
      p.move();
      p.draw(); 
    }
  }
}
class Sample {
  AudioChannel[] channels;
  int side;
  int sideLength;
  boolean muted = false;
  
  Sample(int side, int numChannels, String fileName) {
    this.side = side;
    sideLength = (side == BOTTOM) ? width : height;
    channels = new AudioChannel[numChannels];
    for (int i = 0; i < numChannels; ++i)
      channels[i] = new AudioChannel(fileName);
  }
  
  //Translate the location (loc) on the wall or floor that the ball hit to the corresponding sample start time
  //Use the diameter of the ball (diam) to help determine the grain duration.
  public void play(float loc) {
    int startTime = PApplet.parseInt(map(loc, 0, sideLength, 0, channels[0].samples.length));
    int duration = PApplet.parseInt(random(lowDuration, highDuration));
    float pan = random(lowPan, highPan);
    AudioChannel channel = getAvailableChannel();
    if (channel != null) {
    channel.out(startTime + duration);
    channel.cue(startTime);
    channel.pan(pan);
    if (envelope.enabled)
      envelope.getEnvelope().filter(channel, channel.cue, duration);
    channel.play();
    }
  }
  
  public AudioChannel getAvailableChannel() {
    for (AudioChannel channel : channels)
      if (channel.state != Ess.PLAYING)
        return channel;
    return null;
  }
  
  public void draw() {
    noFill();
    if (muted)
      stroke(255, 0, 0);
    else if (channels[0].state == Ess.PLAYING)
      stroke(0, 255, 0);
    else
      stroke(255);
    strokeWeight(1.2f);
    
    pushMatrix();
    switch (side) {
      case LEFT: translate(25, 0);
              rotate(PI/2);
              break;
      case RIGHT: translate(width - 25, 0);
              rotate(PI/2);
              break;
      case BOTTOM: translate(0, height - 25);
              break;
      default: break;
    }
    beginShape();
    for (int i=0; i < sideLength ;++i)
      vertex(i,(int)(channels[0].samples[(int)map(i, 0, sideLength, 0, channels[0].samples.length)]*100));
    endShape();
    popMatrix();
  }
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#DFDFDF", "GrainBounce" });
  }
}
