// Analysis
// by Krister Olsson <http://www.tree-axis.com> 

// Plays an MP3 while displaying an oscilloscope 
// and performing real-time spectrum analysis. 
// Click to start/stop

// Created 1 May 2005
// Updated 18 May 2006

import krister.Ess.*;

AudioChannel myChannel;
FFT myFFT;

int bufferSize;
int bufferDuration;

void setup() {
  size(256,200);

  // start up Ess

  Ess.start(this);

  myChannel=new AudioChannel("0124.mp3");
  bufferSize=myChannel.buffer.length;
  bufferDuration=myChannel.ms(bufferSize);

  myFFT=new FFT(512);

  framerate(30);
  noSmooth();
}

void draw() {
  background(0,0,255);
  drawSpectrum();
  drawSamples();
}

void drawSpectrum() {
  noStroke();

  myFFT.getSpectrum(myChannel);

  for (int i=0; i<256; i++) {
    float temp=max(0,185-myFFT.spectrum[i]*175);
    rect(i,temp+.5,1,height-temp+.5);
  }
}

void drawSamples() {
  stroke(255);

  // interpolate between 0 and writeSamplesSize over writeUpdateTime
  int interp=(int)max(0,(((millis()-myChannel.bufferStartTime)/(float)bufferDuration)*bufferSize));

  for (int i=0;i<256;i++) {
    float left=100;
    float right=100;

    if (i+interp+1<myChannel.buffer2.length) {
      left-=myChannel.buffer2[i+interp]*75.0;
      right-=myChannel.buffer2[i+1+interp]*75.0;
    }

    line(i,left,i+1,right);
  }
}

void mousePressed() {
  if (myChannel.state==Ess.PLAYING) {
    myChannel.stop();
  } 
  else {
    myChannel.play(Ess.FOREVER);
  }
}

// clean up Ess before exiting

public void stop() {
  Ess.stop();
  super.stop();
}
