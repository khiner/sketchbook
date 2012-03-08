// Pan and Volume
// by Krister Olsson <http://www.tree-axis.com>

// Generates a looping sine wave and pink noise. 
// Pan and volume are controlled by mouse position

// Created 1 May 2005
// Updated 3 May 2006

import krister.Ess.*;

AudioChannel myChannel1,myChannel2;
SineWave myWave;
PinkNoise myNoise;

void setup() {
  size(256,200);
  
  // start up Ess
  
  Ess.start(this);

  myChannel1=new AudioChannel();
  myChannel2=new AudioChannel();

  myChannel1.initChannel(myChannel1.frames(2000));
  myChannel2.initChannel(myChannel2.frames(2000));

  myWave=new SineWave(480,.5);
  myNoise=new PinkNoise(.5);

  myWave.generate(myChannel1);
  myNoise.generate(myChannel2);

  myChannel1.volume(0);
  myChannel2.volume(0);

  // pan only at zero crossings

  myChannel1.smoothPan=true;

  myChannel1.play(Ess.FOREVER);
  myChannel2.play(Ess.FOREVER);

  // small fade in

  myChannel1.fadeTo(.5,500);
  myChannel2.fadeTo(.5,500);

  framerate(30);

  noFill();
  smooth();
  ellipseMode(CENTER);
}

void draw() {
  background(0,0,255);

  strokeWeight(1);
  stroke(255);

  int tx=mouseX;
  int ty=mouseY;

  float newPan=1-(tx/float(width))*2;
  float newVolume=1-ty/float(height);

  if (!myChannel1.panning) myChannel1.panTo(newPan,500);
  if (!myChannel2.panning) myChannel2.panTo(-newPan,500);
  
  line(tx,0,tx,height);
  line(width-tx,0,width-tx,height);

  if (!myChannel1.fading) myChannel1.fadeTo(newVolume,500);
  if (!myChannel2.fading) myChannel2.fadeTo(1-newVolume,500);

  line(0,ty,width,ty);
  line(0,height-ty,width,height-ty);

  int d=((millis()/75) % 20)+4;

  strokeWeight(3);
  stroke(255,255-d*(255/20));

  ellipse(tx,ty,d,d);
  ellipse(width-tx,height-ty,d,d);
}

// clean up Ess before exiting

public void stop() {
  Ess.stop();
  super.stop();
}
