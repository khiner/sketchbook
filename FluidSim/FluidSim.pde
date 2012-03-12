import toxi.math.conversion.*;
import toxi.geom.*;

//    Update particle densities 
//    Update particle pressures 
//    while (time < end_of_time) 
//        for all particles 
//            Calculate acceleration due to pressure gradient (equation 2.7) 
//            Calculate rate of change of thermal energy (equation 2.8) 
//
//        for all particles 
//            Update position 
//            Update velocity 
//            Update thermal energy 
//
//        Update particle densities 
//        Update particle pressures 
//        Calculate new time step 
//        time += new_timestep

// http://www.plunk.org/~trina/thesis/html/thesis_ch2.html#equ2.6-7-8


Particle[] particles = new Particle[100];
float smoothLength = 200;
Vec2D gravity = new Vec2D(0, 9.8);

void setup() {
  size(800, 600);
  smooth();
  for (int i = 0; i < particles.length; ++i)
    particles[i] = new Particle(new Vec2D(random(width), random(height)), color(0));
  for (Particle p : particles) {
    p.updateDensity();
    p.updatePressure();
  }
}

void draw() {
  background(255);
  for (Particle p : particles) {
    p.updateAccel();
    p.updateEnergy();
  }

  for (Particle p : particles) {
    p.updatePosition();
    p.updateVelocity();
    p.updateEnergy();
  }

  for (Particle p : particles) {
    p.updateDensity();
  }

  for (Particle p : particles) {
    p.updatePressure();
    p.draw();
  }
}

float smooth(float r, float h) {
  float q = r/h;

  if (0 <= q && q < 1)
    return (1.0/(PI*pow(h, 3)))*(1 + 1.5*q*q + .75*q*q*q);
  else if (1 <= q && q <= 2)
    return (1.0/(PI*pow(h, 3)))*(0.25*pow(2.0 - q, 3));
  else
    return 0;
}

