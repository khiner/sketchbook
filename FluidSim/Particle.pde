class Particle {
  Vec2D position = new Vec2D(0, 0);
  Vec2D velocity = new Vec2D(0, 0);
  Vec2D accel = new Vec2D(0, 0);
  Vec2D density = new Vec2D(0, 0);
  Vec2D pressure = new Vec2D(0, 0);
  Vec2D energy = new Vec2D(0, 0);

  float mass;

  color c;
  int s = 3;


  Particle(Vec2D pos, color c) {
    position.set(pos.x, pos.y);
    this.c = c;
  }

  void draw() {
    fill(c);
    ellipse(position.x, position.y, s, s);
  }

  float distanceTo(Particle p) {
    return position.distanceTo(p.position);
  }

  void updatePosition() {
    position.addSelf(velocity);
  }

  void updateVelocity() {
    velocity.addSelf(accel);
    println("Velocity: " + velocity.x + ' ' + velocity.y);
  }

  //Calculate acceleration due to pressure gradient
  void updateAccel() {
    accel.set(0, 0);
    for (Particle p : particles) {
      Vec2D i = new Vec2D(0, 0);
      i = pressure.scale(density.scale(density).invert());
      i.addSelf(p.pressure.scale(p.density.scale(p.density).invert()));
      i.scaleSelf(p.mass*gradient(p));
      accel.addSelf(i);
    }
    accel.addSelf(gravity);
    //accel.scaleSelf(-1);
    println("Accel: " + accel.x + ' ' + accel.y);
  }

  void updateDensity() {
    density.set(0, 0);
    for (Particle p : particles) {
      Vec2D d = new Vec2D(0, 0);
      d = velocity.sub(p.velocity).scale(p.mass*gradient(p));
      density.addSelf(d);
    }
    println("Density: " + density.x + ' ' + density.y);
  }

  void updatePressure() {
    for (Particle p : particles) {
      Vec2D i = new Vec2D(0, 0);
      i = pressure.scale(density.scale(density).invert());
      i.addSelf(p.pressure.scale(p.density.scale(p.density).invert()));
      i.scaleSelf(p.mass*gradient(p));
      pressure = pressure.add(i);
    }
    pressure.scaleSelf(density);
    println("Pressure: " + pressure.x + ' ' + pressure.y);
  }

  void updateEnergy() {
    //energy.set(0, 0);
    for (Particle p : particles) {
      Vec2D i = new Vec2D(0, 0);
      i = pressure.scale(density.scale(density).invert());
      i.addSelf(p.pressure.scale(p.density.scale(p.density).invert()));
      i.scaleSelf(p.mass*gradient(p)).scale(velocity.sub(p.velocity));
      energy.addSelf(i);
    }
    energy.scaleSelf(0.5);
    println("Energy: " + energy.x + ' ' + energy.y);
  }

  float gradient(Particle p) {
    return smooth(position.distanceTo(p.position), smoothLength);
  }
}

