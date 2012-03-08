class Rocket extends Body
{
    Stack<Body> myPath;
    Vec2D prevLoc = null;
    Vec2D myVelocity;
    int tick = 0;
    float currBest = Float.MAX_VALUE;
    boolean waitingITN = false;
    boolean launchITN = false;
    boolean waitingHohmann = false;
    boolean launchHohmann = false;
    float ellipseAngle = 0;
  
    Planet source, dest;
  
    Rocket(Planet source, Planet dest) {
	name = "rocket";
	myColor = color(130);
	this.source = source;
	this.dest = dest;
	displaySize = .5;
	updateHohmann();
    }
  
    void display() {
	if (mouseOver()) {
	    myColor = color(200);
	    follow = true;
	} else {
	    myColor = color(130);
	    follow = false;
	}
	noStroke();
	translate(x(), y(), 0);
	if (myVelocity != null)
	    rotateZ(tan(myVelocity.y()/myVelocity.x()) - HALF_PI);
	fill(255, 160, 0);
	cylinder(1*displaySize, 1*displaySize, 15);
	translate(0, 1*displaySize, 0);
	fill(RED);
	cylinder(2*displaySize,2*displaySize,15);
	fin(displaySize, -PI/6);
	fin(displaySize, -5*PI/6);
	fin(displaySize, HALF_PI);
	translate(0,8*displaySize,0);
	fill(myColor);
	cylinder(3*displaySize, 16*displaySize, 15);
	translate(0, 8*displaySize, 0);
	rotateX(-PI/2);
	cone(0, 0, 3*displaySize, 3*displaySize);
    } 
    
    void update() {
	if (!(launchHohmann || launchITN))
	    set(source);
	if (waitingITN) {
	    if (TICK % 3 == 0 && itnLaunchWindow()) {
		waitingITN = false;
		launchITN = true;
	    }
	} else if (waitingHohmann) {
	    if (hohmannLaunchWindow()) {
		waitingHohmann = false;
                prevLoc = source;
		launchHohmann = true;
		pathAngle = -HALF_PI;
	    }
	} else if (launchITN)
	    tickITN();
	else if (launchHohmann)
	    tickHohmann();
    }
  
  
    Vec2D getITNVelocity(Body dest) {
	for (int t = 1; t < 10000; ++t) {
	    Vec2D projectedDest = dest.locationAtTime(t);
	    Vec2D projectedVelocity = projectedDest.sub(this).normalize().scale(ROCKET_SPEED);
	    if (add(projectedVelocity.scale(t).scale(SIM_SPEED)).distanceTo(projectedDest) < 5)
		return projectedVelocity;
	}
	return null;
    }
  
    void waitITN() {
	waitingITN = true;
	launchITN = false;
	launchHohmann = false;
	waitingHohmann = false;
	myPath = getPath(source, dest);
	currBest = dest.distance;
    }
  
    void waitHohmann() {
	waitingHohmann = true;
	launchHohmann = false;
	launchITN = false;
	waitingITN = false;
    }
  
    void setSize(float newSize) { displaySize = newSize; }
  
    void setSource(Planet source) {
	this.source = source;
	if (waitingITN)
	    ITN(0);
    }
  
    void setDest(Planet dest) {
	this.dest = dest;
	if (waitingITN)
	    ITN(0);
    }
  
    void previewITN() {
	if (!launchITN && !waitingITN)
	    myPath = getPath(source, dest);
	Body[] pathList = myPath.toArray(new Body[myPath.size()]);
	if (pathList.length == 0)
	    return;
	noFill();
	stroke(color(255,0,0));
	beginShape();
	vertex(pathList[pathList.length - 1].x(), pathList[pathList.length - 1].y());
	for (int i = pathList.length - 1; i > 0; --i) {
	    Vec2D between = pathList[i - 1].sub(pathList[i]).scale(.5);
	    float angleC1 = i % 2 == 0 ? PI/4 : -PI/4;
	    Vec2D c1 = pathList[i].add(between.rotate(angleC1));
	    Vec2D c2 = pathList[i-1].add(between.rotate(angleC1*2));
	    bezierVertex(c1.x(), c1.y(), c2.x(), c2.y(), pathList[i-1].x(), pathList[i-1].y());
	}
	endShape();
    }
  
    void previewHohmann() {
	if (!(launchHohmann))
	    updateHohmann();
	noFill();
	stroke(color(255,0,0));
	strokeWeight(2);
	rotateZ(ellipseAngle);
	// For preview, draw a dashed ellipse:
	beginShape(LINES);
	for (float i = 0; i < TWO_PI; i += PI/25)
	    vertex(ellipseCenter + ellipseA*sin(i), ellipseB*cos(i));
	endShape();
	rotateZ(-ellipseAngle);
    }
  
    void updateHohmann() {
	float angle = getNormalized().angleBetween(new Vec2D(1,0));//source.angle();
	angle = (y < 0) ? angle - HALF_PI : -angle - HALF_PI;
	ellipseA = source.distanceTo(dest.locationAtAngle(angle))/2;
	ellipseE = 1 - source.distanceTo(planets[0])/ellipseA;
	ellipseB = (float)(ellipseA*Math.sqrt(1-ellipseE*ellipseE));
	orbit_speed = 1/map(ellipseA/AU, 0, width/2, 0, SCALE_FACTOR);
	ellipseCenter = ellipseA*ellipseE;
	pathAngle = source.angle();
	ellipseAngle = pathAngle;
    }
  
    void tickITN() {
	//if (myVelocity == null)
	    myVelocity = getITNVelocity(myPath.peek());
	set(add(myVelocity.scale(SIM_SPEED)));
	if (distanceTo(myPath.peek()) < SNAP_DIST) {
	    myPath.pop().animate();
	    if (!myPath.isEmpty())
		myVelocity = getITNVelocity(myPath.peek());
	    else {
		launchITN = false;
		if (followBody == this)
		    followBody = dest;
		resetProgress();
	    }
	}
	display();
    }
  
    void tickHohmann() {
	pathAngle += orbit_speed*SIM_SPEED;
	Vec2D nextLoc = new Vec2D(ellipseCenter + ellipseA*sin(pathAngle), ellipseB*cos(pathAngle)).getRotated(ellipseAngle);
        Vec2D projected = locationAtAngle(0).rotate(ellipseAngle);
        myVelocity = projected.y > 0 ? projected.rotate(PI/2) : projected;
        prevLoc = new Vec2D(this);
	set(nextLoc);
	if (distanceTo(dest) < SNAP_DIST*2) {
	    dest.animate();
	    launchHohmann = false;
	    if (followBody == this)
		followBody = dest;
	    resetProgress();
	}
	display();
    }
  
    boolean itnLaunchWindow() {
	float goal = source.distanceTo(dest);
	myPath = getPath(source, dest);
	if (dest.distance < currBest)
	    currBest = dest.distance;
	setProgress(map(goal/currBest, .8, 1, 0, 1));
	return (currBest <= goal);
    }
  
    boolean hohmannLaunchWindow() {
	Vec2D destProject = dest.locationAtTime((int)(PI/(orbit_speed*SIM_SPEED)));
	float distance = locationAtAngle(0).getRotated(pathAngle).distanceTo(destProject);
	float goal = SNAP_DIST*2;
	setProgress(goal/distance);
	return distance <= goal;
    }
}

