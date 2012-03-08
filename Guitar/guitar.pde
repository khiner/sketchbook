/*************************************************************
 Play the guitar!
 Select chords, or double-click where you want to place fingers,
 and strum by holding down the mouse!
 Move the finger markers by dragging them.  Remove them by either
 dragging them off the fretboard or by double-clicking them.
 
 Typing letters selects that chord.  A capital letter is for a sharp
 
 The equation used for the string animation is due to:
 http://www.oberlin.edu/faculty/brichard/Apples/StringsPage.html
 **************************************************************/

import ddf.minim.*;
import controlP5.*;

final float PI_SQUARED = PI*PI;  // used in main loop; this saves time
final int SNAP_DIST = 8;  // distance from string to start bending it with mouse
final int MAX_PULL = 60;  // how far we can pull a string before plucked
final int DOUBLE_CLICK_TIME = 200;  // millisecond time for double clicks
final float VOLUME_MAX = 65536; // max Java sound volume
int lastClickTime = 0;  // used to keep track of double-clicks
int[] fretLines = new int[13]; // x locations of all frets
float volume = VOLUME_MAX*.8;
int guitarX, guitarY, guitarH;  // paramaters for the guitar
GuitarString[] strings = new GuitarString[6];
GuitarString pulled = null;  // pulled string is pulled by mouse
color guitarColor = color(92, 51, 23);  // color of fretboard
color brass = color(181, 166, 66);  // color of strings
color copper = color(204, 153, 0);
ArrayList<FingerMarker> markers = new ArrayList<FingerMarker>();
FingerMarker selectedMarker = null;  // the finger marker that's being dragged
AudioSnippet[] samples; // holds all guitar samples in ascending order of pitch
Minim minim;
ControlP5 controlP5;

void setup() {
  minim = new Minim(this);
  controlP5 = new ControlP5(this);
  size(900, 500, P2D);
  strokeWeight(3);
  smooth();
  textSize(20);
  textMode(SCREEN);  //increases text rendering and quality for P2D mode
  guitarX = 30;
  guitarY = height/2 - 50;
  guitarH = 220;
  // figure out where the frets should go
  float d = 1.47*width/fretLines.length;
  for (int i = 0; i < fretLines.length; ++i) {
    fretLines[i] = int(i*d + guitarX);
    d -= (width*.003); // the frets get skinnier as we move up the board
  }
  loadSamples();
  loadChordButtons();
  loadChords();
  int inc = guitarH/22; // for string y-positions
  // initialize strings
  strings[0] = new GuitarString(guitarY + inc*21, 0);
  strings[1] = new GuitarString(guitarY + inc*17, 5);
  strings[2] = new GuitarString(guitarY + inc*13, 10);
  strings[3] = new GuitarString(guitarY + inc*9, 15);
  strings[4] = new GuitarString(guitarY + inc*5, 19);
  strings[5] = new GuitarString(guitarY + inc, 24);
  //setChord places the finger markers for the chord
  handleClicks(0, chords);
  handleClicks(0, chordTypes);
}

void draw() {
  background(255);
  // write string names
  fill(0);
  text('E', 5, strings[0].y + 10);
  text('A', 5, strings[1].y + 10);
  text('D', 5, strings[2].y + 10);
  text('G', 5, strings[3].y + 10);
  text('B', 5, strings[4].y + 10);
  text('E', 5, strings[5].y + 10);
  // draw fretboard
  fill(guitarColor);
  noStroke();
  beginShape();
  vertex(guitarX, guitarY);
  vertex(width, guitarY);
  vertex(width, guitarY + guitarH);
  vertex(guitarX, guitarY + guitarH);
  endShape(CLOSE);
  // draw frets, and fret markers
  fill(0);
  for (int i = 0; i < fretLines.length; ++i) {
    stroke(brass);
    line(fretLines[i], guitarY, fretLines[i], guitarY + guitarH);
    noStroke();
    if (i == 3 || i == 5 || i == 7 || i == 9)
      ellipse((fretLines[i] + fretLines[i-1])/2, guitarY + guitarH/2, 10, 10);
    else if (i == 12) {
      ellipse((fretLines[i] + fretLines[i-1])/2, guitarY + guitarH/6, 10, 10);
      ellipse((fretLines[i] + fretLines[i-1])/2, guitarY + 5*guitarH/6, 10, 10);
    }
  }
  // draw strings
  for (GuitarString s : strings) {
    if (pulled != null && s.equals(pulled))
      s.drawPulled();
    else
      s.draw();
  }
  // draw finger markers
  for (FingerMarker m : markers)
    m.draw();

  controlP5.draw();  // we need to manually draw controlP5 when using P2D
}

/**
 * Start the pluck animation for the pulled string, if there is one
 */
void pluck() {
  if (pulled != null) {
    pulled.pluck();
    pulled = null;
  }
}

/**
 * Return the fret that the mouse is over, or 0 if none
 */
int fretWithMouse() {
  for (int i = 0; i < fretLines.length - 1; ++i)
    if (mouseX > fretLines[i] && mouseX < fretLines[i+1])
      return i + 1;
  return 0;
}

//Used for finding which string the mouse is 'pulling'
GuitarString stringWithMouse() {
  for (GuitarString s : strings)
    if (s.isMouseOver())
      return s;
  return null;
}

// Returns the string nearest to the mouse, or NULL if we are far away from all strings
// Used for placement of finger markers
GuitarString stringNearestMouse() {
  int bestDist = Integer.MAX_VALUE;
  GuitarString bestString = null;
  for (GuitarString s : strings) {
    if (abs(mouseY - s.y) < bestDist) {
      bestDist = abs(mouseY - s.y);
      bestString = s;
    }
  }
  return bestDist < MAX_PULL ? bestString : null;
}

/**
 * Returns which marker has the mouse over it, or NULL if none
 */
FingerMarker markerWithMouse() {
  for (FingerMarker m : markers)
    if (m.isMouseOver())
      return m;
  return null;
}

/**
 * Returns true if the time between the last click and the current time
 * is less than the global DOUBLE_CLICK_TIME
 */
boolean isDoubleClick() {
  if (millis() - lastClickTime < DOUBLE_CLICK_TIME)
    return true;
  return false;
}

void mouseClicked() {
  if (isDoubleClick()) {
    FingerMarker m = markerWithMouse();
    if (m != null) {
      m.getString().setFret(0);
      markers.remove(m);
    } 
    else {
      GuitarString s = stringNearestMouse();
      if (s != null)
        markers.add(new FingerMarker(s, fretWithMouse()));
    }
  }
  lastClickTime = millis();
}

void mousePressed() {
  FingerMarker m = markerWithMouse();
  if (m != null) {
    selectedMarker = m;
    m.getString().setFret(0);
  }
}

void mouseReleased() {
  if (selectedMarker != null) {
    GuitarString s = stringNearestMouse();
    int fret = fretWithMouse();
    if (s != null) {
      if (!s.equals(selectedMarker.getString()))
        selectedMarker.setString(s, fret); // marker moved to different string
      else if (s.getFret() != fret)  
        selectedMarker.setFret(fret); // marker moved to different fret, same string
    } 
    else { // marker was dragged off the fret board. delete it.
      markers.remove(selectedMarker);
      selectedMarker = null;
    }
  } 
  else // no selected marker. pluck the pulled string, if any
  pluck();
  selectedMarker = null;
}

void mouseDragged() {
  if (selectedMarker == null) {
    GuitarString s = stringWithMouse();
    if (s != null && mouseX > s.fretDist()) {
      if (pulled != null && !s.equals(pulled))
        pluck();
      pulled = s;
    }
    if (pulled != null) {
      pulled.setVertex(mouseX, mouseY);
      if (abs(mouseY - pulled.y) > MAX_PULL || mouseX < pulled.fretDist())
        pluck();
    }
  } 
  else
    selectedMarker.set(mouseX, mouseY);
}

void loadSamples() {
  samples = new AudioSnippet[31];
  for (int i = 0; i < samples.length; ++i) {
    samples[i] = minim.loadSnippet(i + ".mp3");
    samples[i].setVolume(volume);
  }
}

/**
 * Called when the sketch is closed.  Clean up audio stuff
 */
void dispose() {
  println("closing samples");
  for (int i = 0; i < samples.length; ++i)
    samples[i].close();
  minim.stop();
}

