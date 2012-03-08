/**
 cone taken from http://wiki.processing.org/index.php/Cone
 @author Tom Carden
 */

/**
 cylinder taken from http://wiki.processing.org/index.php/Cylinder
 @author matt ditton
 */

void cylinder(float w, float h, int sides)
{
  float angle;
  float[] x = new float[sides+1];
  float[] z = new float[sides+1];

  //get the x and z position on a circle for all the sides
  for (int i=0; i < x.length; i++) {
    angle = TWO_PI / (sides) * i;
    x[i] = sin(angle) * w;
    z[i] = cos(angle) * w;
  }

  //draw the top of the cylinder
  beginShape(TRIANGLE_FAN);

  vertex(0, -h/2, 0);

  for (int i=0; i < x.length; i++) {
    vertex(x[i], -h/2, z[i]);
  }

  endShape();

  //draw the center of the cylinder
  beginShape(QUAD_STRIP); 

  for (int i=0; i < x.length; i++) {
    vertex(x[i], -h/2, z[i]);
    vertex(x[i], h/2, z[i]);
  }

  endShape();

  //draw the bottom of the cylinder
  beginShape(TRIANGLE_FAN); 

  vertex(0, h/2, 0);

  for (int i=0; i < x.length; i++) {
    vertex(x[i], h/2, z[i]);
  }

  endShape();
}

static float unitConeX[];
static float unitConeY[];
static int coneDetail;

static {
  coneDetail(24);
}

// just inits the points of a circle, 
// if you're doing lots of cones the same size 
// then you'll want to cache height and radius too
static void coneDetail(int det) {
  coneDetail = det;
  unitConeX = new float[det+1];
  unitConeY = new float[det+1];
  for (int i = 0; i <= det; i++) {
    float a1 = TWO_PI * i / det;
    unitConeX[i] = (float)Math.cos(a1);
    unitConeY[i] = (float)Math.sin(a1);
  }
}

// places a cone with it's base centred at (x,y),
// height h in positive z, radius r.
void cone(float x, float y, float r, float h) {
  pushMatrix();
  translate(x, y);
  scale(r, r);
  beginShape(TRIANGLES);
  for (int i = 0; i < coneDetail; i++) {
    vertex(unitConeX[i], unitConeY[i], 0.0);
    vertex(unitConeX[i+1], unitConeY[i+1], 0.0);
    vertex(0, 0, h);
  }
  endShape();
  popMatrix();
}

// Draw a rocket fin with size sz, and given angle relative to Y Axis
void fin(float sz, float angle) {
  pushMatrix();
  scale(sz);
  rotateY(angle);
  beginShape();
  vertex(0, 6);
  vertex(4.2, 0);
  vertex(9, 0);
  vertex(5, 6);
  endShape(CLOSE);
  popMatrix();
}

