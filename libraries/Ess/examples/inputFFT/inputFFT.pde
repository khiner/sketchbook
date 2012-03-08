// Input FFT
// original code by Marius Watz <http://www.unlekker.net>
// modified by Krister Olsson <http://www.tree-axis.com>

// Showcase for new FFT processing options in Ess v2. 
// Clicking and dragging changes FFT damping

// Created 27 May 2006

import krister.Ess.*;

int bufferSize;
int steps;
float limitDiff;
int numAverages=32;
float myDamp=.1f;
float maxLimit,minLimit;

FFT myFFT;
AudioInput myInput;

void setup () {
  size(700,221);

  // start up Ess
  Ess.start(this);  

  // set up our AudioInput
  bufferSize=512;
  myInput=new AudioInput(bufferSize);

  // set up our FFT
  myFFT=new FFT(bufferSize*2);
  myFFT.equalizer(true);

  // set up our FFT normalization/dampening
  minLimit=.005;
  maxLimit=.05;
  myFFT.limits(minLimit,maxLimit);
  myFFT.damp(myDamp);
  myFFT.averages(numAverages);

  // get the number of bins per average 
  steps=bufferSize/numAverages;

  // get the distance of travel between minimum and maximum limits
  limitDiff=maxLimit-minLimit;

  framerate(25);         

  myInput.start();
}

void draw() {
  background(0,0,255);

  // draw the waveform 

  stroke(255,100);
  int interp=(int)max(0,(((millis()-myInput.bufferStartTime)/(float)myInput.duration)*myInput.size));

  for (int i=0;i<bufferSize;i++) {
    float left=160;
    float right=160;

    if (i+interp+1<myInput.buffer2.length) {
      left-=myInput.buffer2[i+interp]*50.0;
      right-=myInput.buffer2[i+1+interp]*50.0;
    }

    line(10+i,left,11+i,right);
  }

  noStroke();
  fill(255,128);

  // draw the spectrum

  for (int i=0; i<bufferSize; i++) {
    rect(10+i,10,1,myFFT.spectrum[i]*200);
  }

  // draw our averages
  for(int i=0; i<numAverages; i++) {
    fill(255,128);
    rect(10+i*steps,10,steps,myFFT.averages[i]*200);
    fill(255);
    rect(10+i*steps,(int)(10+myFFT.maxAverages[i]*200),steps,1);
    rect(10+i*steps,10,1,200);
  }
  
  // complete the frame around our averages
  rect(10+numAverages*steps,10,1,201);
  rect(10,10,bufferSize,1);
  rect(10,210,bufferSize,1);

  // draw the range of normalization
  rect(600,10,50,1);
  rect(600,210,50,1);

  float percent=max(0,(myFFT.max-minLimit)/limitDiff);
  
  fill(255,128);
  rect(600,(int)(11+198*percent),50,1);
  rect(600,11,50,(int)(198*percent)); 

  // draw our damper slider
  fill(255);
  rect(660,10,30,1);
  rect(660,210,30,1);
  fill(255,128);
  rect(660,(int)(11+198*myDamp),30,1);
}

void mouseDragged() {
  mousePressed(); 
}

void mousePressed() {
  // set our damper
  myDamp=mouseY/(float)height;
  if (myDamp>1) myDamp=1;
  else if(myDamp<0) myDamp=0;

  myFFT.damp(myDamp);  
}

public void audioInputData(AudioInput theInput) {
  myFFT.getSpectrum(myInput);
}
