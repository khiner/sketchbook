class FingerMarker {

  private GuitarString myString;
  private int mySize = 30;
  private color myColor = color(255, 0, 0, 150);

  private int x, y;
  // a circle must be on the fret of a string when it is created.
  FingerMarker(GuitarString gs, int fret) {
    setString(gs, fret);
  }

  void setString(GuitarString gs, int fret) {
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

  void setFret(int fret) {
    myString.setFret(fret);
    set((fretLines[fret - 1] + fretLines[fret])/2, myString.y);
  }

  GuitarString getString() { 
    return myString;
  }

  boolean isMouseOver() {
    return (sqrt((mouseX - x)*(mouseX - x) + (mouseY - y)*(mouseY - y)) <= mySize);
  }

  void set(int x, int y) {
    this.x = x;
    this.y = y;
  }

  void draw() {
    fill(myColor);
    stroke(myColor);
    ellipse(x, y, mySize, mySize);
  }
}

