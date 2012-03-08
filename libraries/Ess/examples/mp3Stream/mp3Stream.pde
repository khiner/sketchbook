// mp3 Stream
// by Krister Olsson <http://www.tree-axis.com>

// Plays a stream from an Internet radio station in 
// real-time

// Created 12 May 2006

import krister.Ess.*;

AudioStream myStream;
AudioFile myFile;

boolean songDone;

void setup() {
  size(256,200);

  // start up Ess
  Ess.start(this);
  
  // get ready to stream KCRW
  // (Ess.READ does not require a sample rate)
  myFile=new AudioFile("http://64.236.34.67/stream/1046",0,Ess.READ);
 
  // create a new AudioStream and set the sample rate
  myStream=new AudioStream(32*1024); // 32k samples
  myStream.sampleRate(myFile.sampleRate);

  myStream.start();

  framerate(30);
}

void draw() {
  background(0,0,255);

  // draw waveform
  int interp=(int)max(0,(((millis()-myStream.bufferStartTime)/(float)myStream.duration)*myStream.size));

  for (int i=0;i<256;i++) {
    int top=50;
    
    if (i+interp<myStream.buffer2.length) top-=(int)(myStream.buffer2[i+interp]*50.0);

    int j=0;
    for (int k=top;k<height;k++) {
      set(i,k,color(j,j,255));
      j=min(j+2,255);
    }
  }
}

void audioStreamWrite(AudioStream theStream) {
  // read the next chunk

  int samplesRead=myFile.read(myStream);
  if (samplesRead==0) {
    // start over

    myFile.close();
    myFile.open("http://www.tree-axis.com/temp/vindaloo.mp3",myStream.sampleRate,Ess.READ);

    samplesRead=myFile.read(myStream);
  }
}

// we are done, clean up Ess

public void stop() {
  Ess.stop();
  super.stop();
}
