import processing.core.*; 
import processing.xml.*; 

import ddf.minim.*; 
import controlP5.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class guitar extends PApplet {

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




final float PI_SQUARED = PI*PI;  // used in main loop; this saves time
final int SNAP_DIST = 8;  // distance from string to start bending it with mouse
final int MAX_PULL = 60;  // how far we can pull a string before plucked
final int DOUBLE_CLICK_TIME = 200;  // millisecond time for double clicks
final float VOLUME_MAX = 65536; // max Java sound volume
int lastClickTime = 0;  // used to keep track of double-clicks
int[] fretLines = new int[13]; // x locations of all frets
float volume = VOLUME_MAX*.8f;
int guitarX, guitarY, guitarH;  // paramaters for the guitar
GuitarString[] strings = new GuitarString[6];
GuitarString pulled = null;  // pulled string is pulled by mouse
int guitarColor = color(92, 51, 23);  // color of fretboard
int brass = color(181, 166, 66);  // color of strings
int copper = color(204, 153, 0);
ArrayList<FingerMarker> markers = new ArrayList<FingerMarker>();
FingerMarker selectedMarker = null;  // the finger marker that's being dragged
AudioSnippet[] samples; // holds all guitar samples in ascending order of pitch
Minim minim;
ControlP5 controlP5;

public void setup() {
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
  float d = 1.47f*width/fretLines.length;
  for (int i = 0; i < fretLines.length; ++i) {
    fretLines[i] = PApplet.parseInt(i*d + guitarX);
    d -= (width*.003f); // the frets get skinnier as we move up the board
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

public void draw() {
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
public void pluck() {
  if (pulled != null) {
    pulled.pluck();
    pulled = null;
  }
}

/**
 * Return the fret that the mouse is over, or 0 if none
 */
public int fretWithMouse() {
  for (int i = 0; i < fretLines.length - 1; ++i)
    if (mouseX > fretLines[i] && mouseX < fretLines[i+1])
      return i + 1;
  return 0;
}

//Used for finding which string the mouse is 'pulling'
public GuitarString stringWithMouse() {
  for (GuitarString s : strings)
    if (s.isMouseOver())
      return s;
  return null;
}

// Returns the string nearest to the mouse, or NULL if we are far away from all strings
// Used for placement of finger markers
public GuitarString stringNearestMouse() {
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
public FingerMarker markerWithMouse() {
  for (FingerMarker m : markers)
    if (m.isMouseOver())
      return m;
  return null;
}

/**
 * Returns true if the time between the last click and the current time
 * is less than the global DOUBLE_CLICK_TIME
 */
public boolean isDoubleClick() {
  if (millis() - lastClickTime < DOUBLE_CLICK_TIME)
    return true;
  return false;
}

public void mouseClicked() {
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

public void mousePressed() {
  FingerMarker m = markerWithMouse();
  if (m != null) {
    selectedMarker = m;
    m.getString().setFret(0);
  }
}

public void mouseReleased() {
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

public void mouseDragged() {
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

public void loadSamples() {
  samples = new AudioSnippet[31];
  for (int i = 0; i < samples.length; ++i) {
    samples[i] = minim.loadSnippet(i + ".mp3");
    samples[i].setVolume(volume);
  }
}

/**
 * Called when the sketch is closed.  Clean up audio stuff
 */
public void dispose() {
  println("closing samples");
  for (int i = 0; i < samples.length; ++i)
    samples[i].close();
  minim.stop();
}

// This file separates out all things related to chords (buttons, fret lookup, etc)

// This hashmap takes chord strings as keys and returns the fret numbers for the 6 strings
HashMap<String, int[]> chordMap = new HashMap<String, int[]>();
ControlGroup chordGroup;
MultiList chords, chordTypes;  // the buttons
String currChord = "c";
String currChordType = "major";
final int BACKGROUND_COLOR = -16763310;
final int ACTIVE_COLOR = -16211249;

/**
 * Here is where we enter all the fret numbers for all the chords.
 * a fret of -1 means a muted string. 0 is open.
 */
public void loadChords() {
  //major chords
  chordMap.put("cmajor", new int[] {
    3, 3, 2, 0, 1, 0
  }
  );
  chordMap.put("c#major", new int[] {
    -1, 4, 6, 6, 6, 4
  }
  );
  chordMap.put("dmajor", new int[] {
    -1, -1, 0, 2, 3, 2
  }
  );
  chordMap.put("d#major", new int[] {
    -1, 6, 8, 8, 8, 6
  }
  );
  chordMap.put("emajor", new int[] {
    0, 2, 2, 1, 0, 0
  }
  );
  chordMap.put("fmajor", new int[] {
    1, 3, 3, 2, 1, 1
  }
  );
  chordMap.put("f#major", new int[] {
    2, 4, 4, 3, 2, 2
  }
  );
  chordMap.put("gmajor", new int[] {
    3, 2, 0, 0, 0, 3
  }
  );
  chordMap.put("gmajor", new int[] {
    3, 2, 0, 0, 0, 3
  }
  );
  chordMap.put("g#major", new int[] {
    4, 6, 6, 5, 4, 4
  }
  );
  chordMap.put("amajor", new int[] {
    -1, 0, 2, 2, 2, 0
  }
  );
  chordMap.put("a#major", new int[] {
    -1, 1, 3, 3, 3, 1
  }
  );
  chordMap.put("bmajor", new int[] {
    -1, 2, 4, 4, 4, 2
  }
  );
  //minors
  chordMap.put("cminor", new int[] {
    -1, 3, 5, 5, 4, 3
  }
  );
  chordMap.put("c#minor", new int[] {
    -1, 4, 6, 6, 5, 4
  }
  );
  chordMap.put("dminor", new int[] {
    -1, -1, 0, 2, 3, 1
  }
  );
  chordMap.put("d#minor", new int[] {
    -1, 6, 8, 8, 7, 6
  }
  );
  chordMap.put("eminor", new int[] {
    0, 2, 2, 0, 0, 0
  }
  );
  chordMap.put("fminor", new int[] {
    1, 3, 3, 1, 1, 1
  }
  );
  chordMap.put("f#minor", new int[] {
    2, 4, 4, 2, 2, 2
  }
  );
  chordMap.put("gminor", new int[] {
    3, 5, 5, 3, 3, 3
  }
  );
  chordMap.put("g#minor", new int[] {
    4, 6, 6, 4, 4, 4
  }
  );
  chordMap.put("aminor", new int[] {
    -1, 0, 2, 2, 1, 0
  }
  );
  chordMap.put("a#minor", new int[] {
    -1, 1, 3, 3, 2, 1
  }
  );
  chordMap.put("bminor", new int[] {
    -1, 2, 4, 4, 3, 2
  }
  );
  //6s
  chordMap.put("c6", new int[] {
    -1, 3, 2, 2, 1, 0
  }
  );
  chordMap.put("c#6", new int[] {
    -1, 4, 6, 6, 6, 6
  }
  );
  chordMap.put("d6", new int[] {
    -1, -1, 0, 2, 0, 2
  }
  );
  chordMap.put("d#6", new int[] {
    -1, -1, 1, 3, 1, 3
  }
  );
  chordMap.put("e6", new int[] {
    0, 2, 2, 1, 2, 0
  }
  );
  chordMap.put("f6", new int[] {
    -1, -1, 3, 2, 3, 1
  }
  );
  chordMap.put("f#6", new int[] {
    -1, -1, 4, 3, 4, 2
  }
  );
  chordMap.put("g6", new int[] {
    3, 2, 0, 0, 0, 0
  }
  );
  chordMap.put("g#6", new int[] {
    -1, -1, 6, 5, 6, 4
  }
  );
  chordMap.put("a6", new int[] {
    -1, 0, 2, 2, 2, 2
  }
  );
  chordMap.put("a#6", new int[] {
    -1, -1, 8, 7, 8, 6
  }
  );
  chordMap.put("b6", new int[] {
    -1, 2, 1, 1, 0, 2
  }
  );
  //7s
  chordMap.put("c7", new int[] {
    -1, 3, 2, 3, 1, 0
  }
  );
  chordMap.put("c#7", new int[] {
    -1, 4, 6, 4, 6, 4
  }
  );
  chordMap.put("d7", new int[] {
    -1, -1, 0, 2, 1, 2
  }
  );
  chordMap.put("d#7", new int[] {
    -1, -1, 1, 3, 2, 3
  }
  );
  chordMap.put("e7", new int[] {
    0, 2, 0, 1, 0, 0
  }
  );
  chordMap.put("f7", new int[] {
    1, 3, 1, 2, 1, 1
  }
  );
  chordMap.put("f#7", new int[] {
    2, 4, 2, 3, 2, 2
  }
  );
  chordMap.put("g7", new int[] {
    3, 2, 0, 0, 0, 1
  }
  );
  chordMap.put("g#7", new int[] {
    4, 6, 4, 5, 4, 4
  }
  );
  chordMap.put("a7", new int[] {
    -1, 0, 2, 0, 2, 0
  }
  );
  chordMap.put("a#7", new int[] {
    -1, 1, 3, 1, 3, 0
  }
  );
  chordMap.put("b7", new int[] {
    -1, 2, 1, 2, 0, 2
  }
  );
  //maj7s
  chordMap.put("cmaj7", new int[] {
    -1, 3, 2, 0, 0, 0
  }
  );
  chordMap.put("c#maj7", new int[] {
    -1, 4, 6, 5, 6, 4
  }
  );
  chordMap.put("dmaj7", new int[] {
    -1, -1, 0, 2, 2, 2
  }
  );
  chordMap.put("d#maj7", new int[] {
    -1, -1, 1, 3, 3, 3
  }
  );
  chordMap.put("emaj7", new int[] {
    0, 2, 2, 4, 4, 4
  }
  );
  chordMap.put("fmaj7", new int[] {
    -1, -1, 3, 2, 1, 0
  }
  );
  chordMap.put("f#maj7", new int[] {
    -1, -1, 4, 3, 2, 1
  }
  );
  chordMap.put("gmaj7", new int[] {
    3, 2, 0, 0, 0, 2
  }
  );
  chordMap.put("g#maj7", new int[] {
    -1, -1, 6, 5, 4, 3
  }
  );
  chordMap.put("amaj7", new int[] {
    -1, 0, 2, 1, 2, 0
  }
  );
  chordMap.put("a#maj7", new int[] {
    -1, 1, 3, 2, 3, 0
  }
  );
  chordMap.put("bmaj7", new int[] {
    -1, 2, 4, 3, 4, 2
  }
  );
  //m6s
  chordMap.put("cm6", new int[] {
    8, 10, 10, 8, 10, 8
  }
  );
  chordMap.put("c#m6", new int[] {
    9, 11, 11, 9, 11, 9
  }
  );
  chordMap.put("dm6", new int[] {
    -1, -1, 0, 2, 0, 1
  }
  );
  chordMap.put("d#m6", new int[] {
    -1, -1, 1, 3, 1, 2
  }
  );
  chordMap.put("em6", new int[] {
    0, 2, 2, 0, 2, 0
  }
  );
  chordMap.put("fm6", new int[] {
    1, 3, 3, 1, 3, 1
  }
  );
  chordMap.put("f#m6", new int[] {
    2, 4, 4, 2, 4, 2
  }
  );
  chordMap.put("gm6", new int[] {
    3, 5, 5, 3, 5, 3
  }
  );
  chordMap.put("g#m6", new int[] {
    4, 6, 6, 4, 6, 4
  }
  );
  chordMap.put("am6", new int[] {
    -1, 0, 2, 2, 1, 2
  }
  );
  chordMap.put("a#m6", new int[] {
    6, 8, 8, 6, 8, 6
  }
  );
  chordMap.put("bm6", new int[] {
    7, 9, 9, 8, 9, 7
  }
  );
  //m7s
  chordMap.put("cm7", new int[] {
    -1, 3, 5, 3, 4, 3
  }
  );
  chordMap.put("c#m7", new int[] {
    -1, 4, 6, 4, 5, 4
  }
  );
  chordMap.put("dm7", new int[] {
    -1, -1, 0, 2, 1, 1
  }
  );
  chordMap.put("d#m7", new int[] {
    -1, -1, 1, 3, 2, 2
  }
  );
  chordMap.put("em7", new int[] {
    0, 2, 2, 0, 3, 0
  }
  );
  chordMap.put("fm7", new int[] {
    1, 3, 3, 1, 4, 1
  }
  );
  chordMap.put("f#m7", new int[] {
    2, 4, 4, 2, 5, 2
  }
  );
  chordMap.put("gm7", new int[] {
    3, 5, 5, 3, 6, 3
  }
  );
  chordMap.put("g#m7", new int[] {
    4, 6, 6, 4, 7, 4
  }
  );
  chordMap.put("am7", new int[] {
    -1, 0, 2, 0, 1, 0
  }
  );
  chordMap.put("a#m7", new int[] {
    -1, 1, 3, 1, 2, 1
  }
  );
  chordMap.put("bm7", new int[] {
    -1, 2, 4, 2, 3, 2
  }
  );
  //dims
  chordMap.put("cdim", new int[] {
    -1, 3, 4, 5, 4, -1
  }
  );
  chordMap.put("c#dim", new int[] {
    -1, 4, 5, 6, 5, -1
  }
  );
  chordMap.put("ddim", new int[] {
    -1, -1, 0, 1, 3, 1
  }
  );
  chordMap.put("d#dim", new int[] {
    -1, 6, 7, 8, 7, -1
  }
  );
  chordMap.put("edim", new int[] {
    -1, 7, 8, 9, 8, -1
  }
  );
  chordMap.put("fdim", new int[] {
    -1, 8, 9, 10, 9, -1
  }
  );
  chordMap.put("f#dim", new int[] {
    -1, 9, 10, 11, 10, -1
  }
  );
  chordMap.put("gdim", new int[] {
    -1, 10, 11, 12, 11, -1
  }
  );
  chordMap.put("g#dim", new int[] {
    4, 5, 6, 4, -1, -1
  }
  );
  chordMap.put("adim", new int[] {
    5, 6, 7, 5, -1, -1
  }
  );
  chordMap.put("a#dim", new int[] {
    6, 7, 8, 6, -1, -1
  }
  );
  chordMap.put("bdim", new int[] {
    7, 8, 9, 7, -1, -1
  }
  );
  //augs
  chordMap.put("caug", new int[] {
    -1, 3, 2, 1, 1, 0
  }
  );
  chordMap.put("c#aug", new int[] {
    -1, 4, 3, 2, 2, -1
  }
  );
  chordMap.put("daug", new int[] {
    -1, -1, 0, 3, 3, 2
  }
  );
  chordMap.put("d#aug", new int[] {
    -1, 6, 5, 4, 4, -1
  }
  );
  chordMap.put("eaug", new int[] {
    0, 3, 2, 1, 1, 0
  }
  );
  chordMap.put("faug", new int[] {
    -1, 8, 7, 6, 6, -1
  }
  );
  chordMap.put("f#aug", new int[] {
    -1, 9, 8, 7, 7, -1
  }
  );
  chordMap.put("gaug", new int[] {
    3, 2, 1, 0, 0, 3
  }
  );
  chordMap.put("g#aug", new int[] {
    -1, 11, 10, 9, 9, -1
  }
  );
  chordMap.put("aaug", new int[] {
    -1, 0, 3, 2, 2, 1
  }
  );
  chordMap.put("a#aug", new int[] {
    6, 5, 4, 7, -1, -1
  }
  );
  chordMap.put("baug", new int[] {
    7, 6, 5, 0, 0, -1
  }
  );
  //sus's
  chordMap.put("csus", new int[] {
    -1, 3, 3, 0, 1, 1
  }
  );
  chordMap.put("c#sus", new int[] {
    -1, 4, 6, 6, 7, 4
  }
  );
  chordMap.put("dsus", new int[] {
    -1, -1, 0, 2, 3, 3
  }
  );
  chordMap.put("d#sus", new int[] {
    -1, 6, 8, 8, 6, 6
  }
  );
  chordMap.put("esus", new int[] {
    0, 2, 2, 2, 0, 0
  }
  );
  chordMap.put("fsus", new int[] {
    1, 3, 3, 3, 1, 1
  }
  );
  chordMap.put("f#sus", new int[] {
    2, 4, 4, 4, 2, 2
  }
  );
  chordMap.put("gsus", new int[] {
    3, 3, 0, 0, 1, 3
  }
  );
  chordMap.put("g#sus", new int[] {
    4, 6, 6, 6, 4, 4
  }
  );
  chordMap.put("asus", new int[] {
    -1, 0, 2, 2, 3, 0
  }
  );
  chordMap.put("a#sus", new int[] {
    -1, 1, 3, 3, 4, 1
  }
  );
  chordMap.put("bsus", new int[] {
    -1, 2, 4, 4, 5, 2
  }
  );
}

public void loadChordButtons() {
  chordGroup = controlP5.addGroup("chordGroup", guitarX, 20);
  chordGroup.setBackgroundHeight(guitarY*4/5);
  chordGroup.setBarHeight(13);
  chordGroup.setWidth(100);
  chordGroup.setBackgroundColor(color(60, 128));
  chordGroup.captionLabel().setFont(ControlP5.grixel);
  chordGroup.setLabel("chords"); // controlP5 bug: need to reset label after font change
  chords = controlP5.addMultiList("chords", 5, 5, 30, chordGroup.getBackgroundHeight()/14);
  chords.setGroup(chordGroup);
  chords.add("c", 0);
  chords.add("c#", 1);
  chords.add("d", 2);
  chords.add("d#", 3);
  chords.add("e", 4);
  chords.add("f", 5);
  chords.add("f#", 6);
  chords.add("g", 7);
  chords.add("g#", 8);
  chords.add("a", 9);
  chords.add("a#", 10);
  chords.add("b", 11);
  chordTypes = controlP5.addMultiList("chordTypes", 37, 5, 40, chordGroup.getBackgroundHeight()/14);
  chordTypes.setGroup(chordGroup);
  chordTypes.add("major", 0);
  chordTypes.add("minor", 1);
  chordTypes.add("6", 2);
  chordTypes.add("7", 3);
  chordTypes.add("maj7", 4);
  chordTypes.add("m6", 5);
  chordTypes.add("m7", 6);
  chordTypes.add("dim", 7);
  chordTypes.add("aug", 8);
  chordTypes.add("sus", 9);
  controlP5.addSlider("volume", 0, 1, .8f, (int)chordGroup.position().x, (int)chordGroup.position().y + chordGroup.getBackgroundHeight(), chordGroup.getWidth(), 10);
  controlP5.controller("volume").setColorLabel(0);
}

/* Place the finger markers for all strings */
public void setChord(String chord) {
  if (chordMap.containsKey(chord)) {
    int[] frets = chordMap.get(chord);
    markers.clear();
    for (int i = 0; i < 6; ++i) {
      if (frets[i] > 0)
        markers.add(new FingerMarker(strings[i], (frets[i])));
      else
        strings[i].setFret(frets[i]);
    }
  }
}

public void volume(float value) {
  for (int i = 0; i < samples.length; ++i)
    samples[i].setVolume(value*VOLUME_MAX);
}

/**
 * Called when we click a chord button.  Update the current chord.
 */
public void chords(int value) {
  handleClicks(value, chords);
}

/**
 * Called when we click a chord-type button.  Update the current chord.
 */
public void chordTypes(int value) {
  handleClicks(value, chordTypes);
}

public void handleClicks(int value, MultiList ml) {
  controlP5.Controller chosen = ml.subelements().get(value);
  if (ml.equals(chords)) {
    currChord = chosen.getLabel();
  } 
  else {
    currChordType = chosen.getLabel();
  }
  // manually make it so that the current selected chord
  // is highlighted in the active color (controlP5 does not do this)
  for (controlP5.Controller c : ml.subelements())
    c.setColorBackground(BACKGROUND_COLOR);
  chosen.setColorBackground(ACTIVE_COLOR);
  setChord(currChord + currChordType);
}

public void keyPressed() {
  switch(key) {
  case 'c' : 
  case 'B' : 
    handleClicks(0, chords); 
    break;
  case 'C' : 
    handleClicks(1, chords); 
    break;
  case 'd' : 
    handleClicks(2, chords); 
    break;
  case 'D' : 
    handleClicks(3, chords); 
    break;
  case 'e' : 
    handleClicks(4, chords); 
    break;
  case 'E' : 
  case 'f' : 
    handleClicks(5, chords); 
    break;
  case 'F' : 
    handleClicks(6, chords); 
    break;
  case 'g' : 
    handleClicks(7, chords); 
    break;
  case 'G' : 
    handleClicks(8, chords); 
    break;
  case 'a' : 
    handleClicks(9, chords); 
    break;
  case 'A' : 
    handleClicks(10, chords); 
    break;
  case 'b' : 
    handleClicks(11, chords); 
    break;
  }
}

class FingerMarker {

  private GuitarString myString;
  private int mySize = 30;
  private int myColor = color(255, 0, 0, 150);

  private int x, y;
  // a circle must be on the fret of a string when it is created.
  FingerMarker(GuitarString gs, int fret) {
    setString(gs, fret);
  }

  public void setString(GuitarString gs, int fret) {
    if (gs.getFret() != 0) {
      FingerMarker other = null;
      for (FingerMarker m : markers)
        if (m.getString().equals(gs))
          other = m;
      if (other != null)
        markers.remove(other);
    }
    myString = gs;
    setFret(fret);
  }

  public void setFret(int fret) {
    myString.setFret(fret);
    set((fretLines[fret - 1] + fretLines[fret])/2, myString.y);
  }

  public GuitarString getString() { 
    return myString;
  }

  public boolean isMouseOver() {
    return (sqrt((mouseX - x)*(mouseX - x) + (mouseY - y)*(mouseY - y)) <= mySize);
  }

  public void set(int x, int y) {
    this.x = x;
    this.y = y;
  }

  public void draw() {
    fill(myColor);
    stroke(myColor);
    ellipse(x, y, mySize, mySize);
  }
}

class GuitarString {
  private int t = 0;        // time since pluck
  private int m_tot = 10;    // harmonics - each harmonic requires more computation
  private float c = 400;    // speed
  private float amp = 0;    // amplitude
  private float d = 0;      // x position of pluck
  private float damp = 1.1f; // damping constant

  private int myColor = copper;
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

  public void setFret(int num) {
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

  public void setVertex(int x, int y) {
    d = x;
    amp = y - this.y;
  }

  public int getFret() { 
    return fret;
  }

  public int fretDist() { 
    return fretDist;
  }

  public boolean isMouseOver() {
    return (abs(mouseY - y) < SNAP_DIST);
  }

  public void pluck() {
    int index = open_index + fret;
    if (index < samples.length) {
      samples[open_index + fret].cue(0);
      samples[open_index + fret].play();
      t = 0;
    }
  }

  public void draw() {
    noFill();
    stroke(myColor);
    t++;
    amp/= damp;
    if (abs(amp) > 0.1f) {
      float w = PI*(c/L);
      beginShape();
      vertex(guitarX, y);
      vertex(fretDist, y);
      for (int x = 0; x < L; x += 5) {
        float sum = 0;
        for (int m = 1; m <= m_tot; ++m)
          sum += (1.0f/(m*m)*sin((m*PI_SQUARED*d)/L)*sin((m*PI*x)/L)*cos(m*w*t));
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

  public void drawPulled() {
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

  public void drawFret() {
    if (fret > 0) {
    }
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--stop-color=#cccccc", "guitar" });
  }
}
