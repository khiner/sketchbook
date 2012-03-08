class Planet extends Body
{
  float angle_to_ecliptic;

  Body[] lagranges = new Body[5];

  Planet(String name, float sz, float ellipseA, float ellipseE, float pathAngle, float angle_to_ecliptic, color theColor) {
    super(name, sz);
    for (int i = 0; i < lagranges.length; ++i) {
      lagranges[i] = new Body(this, name + "l" + (i + 1), sz, i + 1);
      lagranges[i].setSize(mySize);
      bodyGraph.addVertex(lagranges[i]);
    }
    this.ellipseA = map(ellipseA*AU, 0, SCALE_FACTOR, 0, width/2);
    this.ellipseE = ellipseE;
    ellipseCenter = this.ellipseA*ellipseE;
    ellipseB = (float)(this.ellipseA*Math.sqrt(1-ellipseE*ellipseE));
    orbit_speed= (ellipseA == 0) ? 0 : 1.0/ellipseA;
    this.angle_to_ecliptic = radians(angle_to_ecliptic);
    this.pathAngle = radians(pathAngle);
    myColor = theColor;
    update();
    bodyGraph.addVertex(this);
  }

  void setupGraph(Planet next) {
    bodyGraph.addEdge(this, lagranges[0]);
    bodyGraph.addEdge(this, lagranges[1]);
    //            bodyGraph.addEdge(lagranges[0], lagranges[3]);
    //            bodyGraph.addEdge(lagranges[0], lagranges[4]);
    bodyGraph.addEdge(lagranges[1], lagranges[3]);
    bodyGraph.addEdge(lagranges[1], lagranges[4]);
    if (next != null)
      for (int i = 1; i < lagranges.length; ++i)
        for (int j = 0; j < lagranges.length; ++j)
          if (j != 1)
            bodyGraph.addEdge(lagranges[i], next.lagranges[j]);
  }

  void display() {
    if (isMouseOverOrbit()) {
      strokeWeight(3);
      follow = true;
    } 
    else {
      strokeWeight(1);
      follow = false;
    }
    stroke(myColor);
    if (showOrbits) {
      noFill();
      ellipse(ellipseCenter, 0, ellipseA, ellipseB);
    }
    noStroke();
    if (showLagrange && !this.equals(planets[0]))
      showLagrange();
    if (showPlanets) {
      super.display();
    }
  }

  void tick() {
    pathAngle += orbit_speed*SIM_SPEED;
    set(ellipseCenter + ellipseA*sin(pathAngle), ellipseB*cos(pathAngle));
    update();
  }

  void update() {
    lagranges[0].set(scale(.95));  // L1 is just in front of the planet
    lagranges[1].set(scale(1.15)); // L2 is just behind the planet
    lagranges[2].set(getRotated(PI));  // L3 is almost exactly on the opposite side of the sun
    lagranges[3].set(getRotated(PI/3));  // L4 and L5 both form an equilateral
    lagranges[4].set(getRotated(-PI/3)); // triangle with the planet and the sun.
  }

  boolean isMouseOverOrbit() {
    for (float i = 0; i < 2*PI; i += PI/(ellipseA)) {
      if (dist(screenX(ellipseCenter + ellipseA*sin(i), ellipseB*cos(i), 0), screenY(ellipseCenter + ellipseA*sin(i), ellipseB*cos(i), 0), mouseX, mouseY) < SNAP_DIST)
        return true;
    }
    return false;
  }

  void setSizeFactor(float sizeFactor) {
    displaySize = mySize*sizeFactor;
    for (int i = 0; i < lagranges.length; ++i)
      lagranges[i].setSize(displaySize);
  }

  void showLagrange() {
    // display all L-Points
    for (Body l : lagranges) {
      l.display();
    }
  }

  Vec2D locationAtAngle(float angle) {
    return new Vec2D(ellipseCenter + ellipseA*sin(angle), ellipseB*cos(angle));
  }

  float angle() {
    float angle = getNormalized().angleBetween(new Vec2D(1, 0));
    return y < 0 ? -(angle + PI) : (angle + PI);
  }
}

