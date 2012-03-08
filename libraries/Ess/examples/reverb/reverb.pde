// Pitch Shift
// by Krister Olsson <http://www.tree-axis.com>

// Applies reverb 10 times to the first sentence of Alvin
// Lucier's seminal electroacoustic piece "I am Sitting in
// a Room."

// Created 1 May 2005
// Updated 18 May 2006

import krister.Ess.*;

AudioChannel myChannel;
Reverb myReverb;
Normalize myNormalize;

int rTimes;

void setup() {
  size(256,200);
  
  // start up Ess
  
  Ess.start(this);

  myChannel=new AudioChannel("alvinLucier.aif");
  myReverb=new Reverb();
  myNormalize=new Normalize();

  myNormalize.filter(myChannel);
  myChannel.play(1);

  rTimes=0;

  framerate(30);
 
  noStroke(); 
  background(0,0,255);
}

void draw() {
  if (rTimes<9) {
    if (myChannel.state==Ess.STOPPED) {
      myChannel.adjustChannel(myChannel.size/16,Ess.END); 
      myChannel.out(myChannel.size);
      
      myReverb.filter(myChannel);
      myNormalize.filter(myChannel);

      myChannel.play(1);
      rTimes++;
    }

    float rWidth=256/10.0;
    
    fill(255-rWidth*rTimes,255-rWidth*rTimes,255);
    rect(rWidth*rTimes,0,(rWidth+.5),200);
  }
}

// clean up Ess before exiting

public void stop() {
  Ess.stop();
  super.stop();
}
