class GuitarString {
  private int t = 0;        // time since pluck
  private int m_tot = 10;    // harmonics - each harmonic requires more computation
  private float c = 400;    // speed
  private float amp = 0;    // amplitude
  private float d = 0;      // x position of pluck
  private float damp = 1.1; // damping constant

  private color myColor = copper;
  private int open_index;
  private int fret = 0;
  private int L;
  private int fretDist;
  private int y;

  GuitarString(int y, int open_index) {
    this.y = y;
    this.open_index = open_index;
    setFret(0);
  }

  void setFret(int num) {
    fret = num;
    if (fret == -1) {// -1 means mute
      fretDist = width;
      myColor = color(255, 0, 0); //red=muted
    } 
    else {
      myColor = copper;
      fretDist = fretLines[fret];
      L = width - fretDist;
    }
  }

  void setVertex(int x, int y) {
    d = x;
    amp = y - this.y;
  }

  int getFret() { 
    return fret;
  }

  int fretDist() { 
    return fretDist;
  }

  boolean isMouseOver() {
    return (abs(mouseY - y) < SNAP_DIST);
  }

  void pluck() {
    int index = open_index + fret;
    if (index < samples.length) {
      samples[open_index + fret].cue(0);
      samples[open_index + fret].play();
      t = 0;
    }
  }

  void draw() {
    noFill();
    stroke(myColor);
    t++;
    amp/= damp;
    if (abs(amp) > 0.1) {
      float w = PI*(c/L);
      beginShape();
      vertex(guitarX, y);
      vertex(fretDist, y);
      for (int x = 0; x < L; x += 5) {
        float sum = 0;
        for (int m = 1; m <= m_tot; ++m)
          sum += (1.0/(m*m)*sin((m*PI_SQUARED*d)/L)*sin((m*PI*x)/L)*cos(m*w*t));
        float y = (amp*L*L)/(PI_SQUARED*d*(L - d))*sum;
        y += this.y;
        vertex(x + fretDist, y);
      }
      vertex(width, y);
      endShape();
    } 
    else
      line(guitarX, y, width, y);
    drawFret();
  }

  void drawPulled() {
    stroke(myColor);
    noFill();
    beginShape();
    vertex(guitarX, y);
    vertex(fretLines[fret], y);
    vertex(d, y + amp);
    vertex(width, y);
    endShape();
    drawFret();
  }

  void drawFret() {
    if (fret > 0) {
    }
  }
}

