// Spooky Stream Save
// by Krister Olsson <http://www.tree-axis.com>

// Sound is generated in realtime, with pitch and 
// pan controlled by the mouse. Streaming of generated 
// sound to a file can be started/stopped by pressing 
// any key
//
// Sound is saved to "spookyStream.aif"

// Created 9 May 2006

import krister.Ess.*;

AudioStream myStream;
SineWave myWave1;
TriangleWave myWave2;

FadeOut myFadeOut;
FadeIn myFadeIn;
Reverb myReverb;

int oldFrequency=0;
boolean doFadeIn=false;

boolean recording=false;
AudioFile myFile=new AudioFile();
int bytesWritten;

void setup() {
  size(256,200);

  // start up Ess
  Ess.start(this);

  // create a new AudioStream
  myStream=new AudioStream();
  myStream.smoothPan=true;

  // our waves
  myWave1=new SineWave(0,.33);
  myWave2=new TriangleWave(0,.66);

  // our effects
  myFadeOut=new FadeOut();
  myFadeIn=new FadeIn();
  myReverb=new Reverb();

  // start
  myStream.start();

  framerate(30);
}

void draw() {
  // adjust the pan
  int mx=mouseX;
  int my=height-mouseY;

  myStream.pan((mx-width/2f)/(width/2f));

  // clear the old
  noStroke();
  fill(0,0,255,64);
  rect(0,0,width,height);

  // paint new based on pan
  for (int i=0;i<width;i++) {
    stroke(255,abs(mx-i));
    line(i,0,i,height);
  }  

  // draw the curve
  stroke(255);

  // draw waveform
  int interp=(int)(((millis()-myStream.bufferStartTime)/(float)myStream.duration)*myStream.size);

  for (int i=0;i<256;i++) {
    float left=my;
    float right=my;

    if (i+interp+1<myStream.buffer2.length) {
      left-=myStream.buffer2[i+interp]*75.0;
      right-=myStream.buffer2[i+1+interp]*75.0;
    }

    line(i,left,i+1,right);
  }
}

void audioStreamWrite(AudioStream theStream) {
  // next wave
  int frequency=mouseY+200;

  myWave1.generate(myStream);
  myWave2.generate(myStream,Ess.ADD);

  // adjust our phases
  myWave1.phase+=myStream.size;
  myWave1.phase%=myStream.sampleRate; 
  myWave2.phase=myWave1.phase;

  if (doFadeIn) {
    myFadeIn.filter(myStream);
    doFadeIn=false;
  }

  if (frequency!=oldFrequency) {
    // we have a new frequency    
    myWave1.frequency=frequency;

    // non integer frequencies can cause timing issues with our simple timing code
    myWave2.frequency=(int)(frequency*4.33); 

    myWave1.phase=myWave2.phase=0;

    // out with the old
    // fade out the old sound to create a 
    myFadeOut.filter(myStream);

    doFadeIn=true;
    println("Playing frequency: "+frequency);

    oldFrequency=frequency;
  } 

  // reverb
  myReverb.filter(myStream,.5);
  
  // record
  if (recording) {
    myFile.write(myStream);
    bytesWritten+=myStream.size*2;
  }
}

void keyPressed() {
  if (recording) {
    // stop
    myFile.close();
    
    println("Finished recording. "+bytesWritten+" bytes written.");
  } else {
    // start
    myFile.open("spookyStream.aif",myStream.sampleRate,Ess.WRITE);
    bytesWritten=0;
    
    println("Recording started.");
  }
  
  recording=!recording;
}

// we are done, clean up Ess

public void stop() {
  Ess.stop();
  super.stop();
}
