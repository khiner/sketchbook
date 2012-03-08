class Particle {
  float x, y,z;
  float diameter;
  float vx = 0;
  float vy = 0;
  float vz = 0;
  int id;
  ArrayList<Particle> particles;
 
  Particle(float vx, float vy, float x, float y, float d, ArrayList<Particle> particles) {
    this.vx = vx;
    this.vy = vy;
    this.x = x;
    this.y = y;
    this.z = z;
    diameter = d;
    this.particles = particles;
    id = particles.size();
  }
 
  void collide() {
    for (int i = id + 1; i < particles.size(); ++i) {
      Particle other = particles.get(i);
      float dx = other.x - x;
      float dy = other.y - y;
      float distance = sqrt(dx*dx + dy*dy);
      //float minDist = particles.get(i).diameter/2 + diameter/2;
      // using fixed diameter = this.radius + other.radius
      if (distance < diameter) {
        float angle = atan2(dy, dx);
        float targetX = x + cos(angle)*diameter;//minDist;
        float targetY = y + sin(angle)*diameter;//minDist;
        float ax = (targetX - other.x);
        float ay = (targetY - other.y);
        vx -= ax;
        vy -= ay;
        other.vx += ax;
        other.vy += ay;
        break;
      }
    }
    if (vx > maxV)
      vx = maxV;
    if (vy > maxV)
      vy = maxV;
  }

   void move() {
    vy += gravity;
    x += vx;
    y += vy;
    if (x + diameter/2 > width) {
      x = width - diameter/2;
      //vx *= friction;
      vx = -vx;
      if (!samples[RIGHT].muted)
        samples[RIGHT].play(y);
    }
    else if (x - diameter/2 < 0) {
      x = diameter/2;
      //vx *= friction;
      vx = -vx;
      if (!samples[LEFT].muted)
        samples[LEFT].play(y);
    }
    if (y + diameter/2 > height) { //>height = 400
      y = height - diameter/2;
      //vy *= friction;
      vy = -vy;
      if (!samples[BOTTOM].muted)
        samples[BOTTOM].play(x);
    }
    else if (y - diameter/2 < 0) {
      y = diameter/2;
      //vy *= friction;
      vy = -vy;
    }
  }
 
  void draw() {
    fill(255, 200);
    noStroke();
    ellipse(x, y, diameter, diameter);
  }
}
