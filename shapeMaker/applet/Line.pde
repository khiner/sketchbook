class Line {
  PVector centerPoint;
  float angle;
  float mySize;
  float stretchRate;
  
  Line(PVector cp, float a, float sr) {
    centerPoint = cp;
    angle = a;
    stretchRate = sr;
  }
  
  void draw() {
    line(centerPoint.x - mySize*cos(angle), centerPoint.y - mySize*sin(angle),
         centerPoint.x + mySize*cos(angle), centerPoint.y + mySize*sin(angle));
  }
  
  void stretch() {
    mySize *= stretchRate;
  }
  
  
}
