class Sample {
  AudioChannel[] channels;
  int side;
  int sideLength;
  boolean muted = false;
  
  Sample(int side, int numChannels, String fileName) {
    this.side = side;
    sideLength = (side == BOTTOM) ? width : height;
    channels = new AudioChannel[numChannels];
    for (int i = 0; i < numChannels; ++i)
      channels[i] = new AudioChannel(fileName);
  }
  
  //Translate the location (loc) on the wall or floor that the ball hit to the corresponding sample start time
  //Use the diameter of the ball (diam) to help determine the grain duration.
  void play(float loc) {
    int startTime = int(map(loc, 0, sideLength, 0, channels[0].samples.length));
    int duration = int(random(lowDuration, highDuration));
    float pan = random(lowPan, highPan);
    AudioChannel channel = getAvailableChannel();
    if (channel != null) {
    channel.out(startTime + duration);
    channel.cue(startTime);
    channel.pan(pan);
    if (envelope.enabled)
      envelope.getEnvelope().filter(channel, channel.cue, duration);
    channel.play();
    }
  }
  
  AudioChannel getAvailableChannel() {
    for (AudioChannel channel : channels)
      if (channel.state != Ess.PLAYING)
        return channel;
    return null;
  }
  
  void draw() {
    noFill();
    if (muted)
      stroke(255, 0, 0);
    else if (channels[0].state == Ess.PLAYING)
      stroke(0, 255, 0);
    else
      stroke(255);
    strokeWeight(1.2);
    
    pushMatrix();
    switch (side) {
      case LEFT: translate(25, 0);
              rotate(PI/2);
              break;
      case RIGHT: translate(width - 25, 0);
              rotate(PI/2);
              break;
      case BOTTOM: translate(0, height - 25);
              break;
      default: break;
    }
    beginShape();
    for (int i=0; i < sideLength ;++i)
      vertex(i,(int)(channels[0].samples[(int)map(i, 0, sideLength, 0, channels[0].samples.length)]*100));
    endShape();
    popMatrix();
  }
}
