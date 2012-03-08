// Scrub
// by Krister Olsson <http://www.tree-axis.com> 

// Loads a sample that can be played/paused by 
// clicking a button in the lower left-hand corner. 
// Playback head can be adjusted by clicking and dragging

// Created 1 May 2005
// Updated 2 May 2006

import krister.Ess.*;

AudioChannel myChannel;
boolean draggingSlider;
int clickX,sliderX,xOffset;

void setup() {
  size(256,200);
  
  // start up Ess
  
  Ess.start(this);

  myChannel=new AudioChannel("cell.aif");
  
  xOffset=0; // in case we want to move it later
  draggingSlider=false;
  myChannel.loop(Ess.FOREVER);

  framerate(30);

  stroke(255);
  noFill();  
}

void draw() {
  background(0,0,255);

  strokeWeight(1);
  line(0,100,width,100);

  if (!draggingSlider) {
    sliderX=(int)lerp(0,245,myChannel.cue/float(myChannel.size));
  } else {
    sliderX=constrain(mouseX-clickX,0,245);
    myChannel.cue((int)(sliderX/245.0*myChannel.size));
  }
  
  // strokeWeight misbehaves
  
  rect(sliderX,90,10,20);
  rect(sliderX+1,91,8,18);
  
  // play/pause button
  
  if (myChannel.state==Ess.PLAYING) {
    rect(5+xOffset,175,4,19);
    rect(12+xOffset,175,4,19);
  } else {
    line(6+xOffset,194,16+xOffset,184);
    line(16+xOffset,184,6+xOffset,174);
    line(6+xOffset,174,6+xOffset,194);
  }
}

void mousePressed() {
  int tx=mouseX;
  int ty=mouseY;

  if (tx>=sliderX && tx<sliderX+10 && ty>=90 && ty<110) {
    draggingSlider=true;
    clickX=tx-sliderX;
  } else if (tx>=6+xOffset && tx<=16+xOffset && ty>=174 && ty<=194) {
    if (myChannel.state==Ess.PLAYING) myChannel.pause();
    else myChannel.resume();
  }
}

void mouseReleased() {
  draggingSlider=false;
}

// clean up Ess before exiting

public void stop() {
  Ess.stop();
  super.stop();
}
