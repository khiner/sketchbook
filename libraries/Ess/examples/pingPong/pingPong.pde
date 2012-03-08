// Ping Pong
// by Krister Olsson <http://tree-axis.com>

// Loads a sound from the Web. Uses the  
// audioOutputPan event to pan back and forth

// Created 1 May 2005
// Updated 18 May 2006

import krister.Ess.*;

AudioChannel mySound;

void setup() {
  size(256,200);
  
  // start up Ess
  
  Ess.start(this);

  mySound=new AudioChannel("http://www.tree-axis.com/Ess/_examples/_sounds/counting.aiff");
  
  mySound.smoothPan=true;
  mySound.pan(Ess.LEFT);
  mySound.play(Ess.FOREVER);

  mySound.panTo(1,2000);

  framerate(30);

  noStroke();
  fill(255);
}

void draw() {
  background(0,0,255);

  // paddles

  rect(5,80,10,40);
  rect(241,80,10,40);

  // pong

  float interp=lerp(15,236,(mySound.pan+1)/2.0);

  rect(interp,98,5,5);
}

// clean up Ess before exiting

public void stop() {
  Ess.stop();
  super.stop();
}

void audioOutputPan(AudioOutput c) {
  // reverse pan direction

  c.panTo(-c.pan,2000);
}
