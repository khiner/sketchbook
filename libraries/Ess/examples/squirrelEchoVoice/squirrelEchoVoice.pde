// Squirrel/Echo Voice
// by Krister Olsson <http://www.tree-axis.com>

// Sound is grabbed from the microphone and pitch 
// shifted or reverbed in real-time (toggled by 
// pressing any key)
//
// Note: Requires a fast computer

// Created 14 May 2006

import krister.Ess.*;

AudioStream myStream;
AudioInput myInput;

PitchShift myShift;
Amplify myAmplify;
Reverb myReverb;

boolean inputReady=false;
float[] streamBuffer;

boolean toggle=true;

void setup() {
  size(256,200);

  // start up Ess
  Ess.start(this);

  // create a new AudioInput (4k buffer)
  myInput=new AudioInput(4096); 

  // create a new AudioStream (4k buffer)
  myStream=new AudioStream(myInput.size);
  streamBuffer=new float[myInput.size];

  // our filters
  myShift=new PitchShift(2);
  myAmplify=new Amplify(4);
  myReverb=new Reverb();
  
  // start
  myStream.start();
  myInput.start();

  framerate(30);
}

void draw() {
  background(0,0,255);
  
  // paint the top white
  fill(255);
  noStroke();
  
  rect(0,0,width,height/2);
  
  // draw both waveforms 
  int interp=(int)max(0,(((millis()-myStream.bufferStartTime)/(float)myStream.duration)*myStream.size));

  for (int i=0;i<256;i++) {
    float leftp=50;
    float rightp=50;

    float left=150;
    float right=150;
    
    if (i+interp+1<myStream.buffer2.length) {
      leftp-=myInput.buffer2[i+interp]*50.0;
      rightp-=myInput.buffer2[i+1+interp]*50.0;
      
      left-=myStream.buffer2[i+interp]*50.0;
      right-=myStream.buffer2[i+1+interp]*50.0;
    }
    
    stroke(0,0,255);
    line(i,leftp,i+1,rightp);
    
    stroke(255);
    line(i,left,i+1,right);
  }
}

void audioStreamWrite(AudioStream theStream) {
  // block until we have some input
  while (!inputReady); 
  
  System.arraycopy(streamBuffer,0,myStream.buffer,0,streamBuffer.length);
  
  if (toggle) {
    myShift.filter(myStream);
    myAmplify.filter(myStream);
  } else {
    myReverb.filter(myStream);
  }
  
  inputReady=false;
}

void audioInputData(AudioInput theInput) {
  System.arraycopy(myInput.buffer,0,streamBuffer,0,myInput.size);
  
  inputReady=true;
}

void keyPressed() {
  toggle=!toggle;
}

// we are done, clean up Ess

public void stop() {
  Ess.stop();
  super.stop();
}
