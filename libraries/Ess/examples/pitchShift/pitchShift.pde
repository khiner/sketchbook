// Pitch Shift
// by Krister Olsson <http://www.tree-axis.com>

// Plays generated sound in two AudioChannels, 
// adjusting pitch over time. Left channel maintains 
// tempo, right does not

// Created 1 May 2005
// Updated 7 May 2006

import krister.Ess.*;

AudioChannel myChannel1, myChannel2;

SineWave mySine;
PinkNoise myPink;
TriangleWave myTriangle;

Envelope myEnvelope;

PitchShift myPitchShift;
RateShift myRateShift;

int shift;

void setup() {
  size(256,200);
  
  // start up Ess
  
  Ess.start(this);

  myChannel1=new AudioChannel();
  myChannel1.initChannel(myChannel1.frames(3000));
  myChannel1.pan(Ess.LEFT);
 
  myChannel2=new AudioChannel();
  myChannel2.initChannel(myChannel2.frames(3000));
  myChannel2.pan(Ess.RIGHT);

  // generate our sound
  
  mySine=new SineWave(480,.5);
  myPink=new PinkNoise(.75);
  myTriangle=new TriangleWave(960,.75);
  
  EPoint[] env=new EPoint[3];
  env[0]=new EPoint(0,0);
  env[1]=new EPoint(.25,1);
  env[2]=new EPoint(2,0);

  myEnvelope=new Envelope(env);
  
  mySine.generate(myChannel1,0,myChannel1.frames(1000));
  mySine.generate(myChannel2,0,myChannel2.frames(1000));
  
  myPink.generate(myChannel1,myChannel1.frames(1000),myChannel1.frames(1000));
  myPink.generate(myChannel2,myChannel2.frames(1000),myChannel2.frames(1000));
  
  myTriangle.generate(myChannel1,myChannel1.frames(2000),myChannel1.frames(1000));
  myTriangle.generate(myChannel2,myChannel2.frames(2000),myChannel2.frames(1000));
 
  myEnvelope.filter(myChannel1);
  myEnvelope.filter(myChannel2);
   
  myChannel1.play();
  myChannel2.play();
  
  // set up our shifting
  
  myPitchShift=new PitchShift(Ess.calcShift(1));
  myRateShift=new RateShift(Ess.calcShift(1));
  
  shift=5;
  
  framerate(30);

  stroke(255);
  fill(255);
}

void draw() {
  background(0,0,255);
  rect(0,200-shift,256,shift);
  
  if (myChannel1.state==Ess.STOPPED) {
    myPitchShift.filter(myChannel1);
    myRateShift.filter(myChannel2);
    
    myChannel1.play();
    myChannel2.play();
    shift+=5;
  }
}

// clean up Ess before exiting

public void stop() {
  Ess.stop();
  super.stop();
}
