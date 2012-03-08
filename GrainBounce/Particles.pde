class Particles {
  ArrayList<Particle> particles;
  
  Particles() {
    particles = new ArrayList<Particle>();
  }
  
  void addParticle(float x, float y) {
    particles.add(new Particle(0, random(10,20), mouseX, mouseY, 20, particles));
  }
  
  void removeParticle() {
    particles.remove(particles.size() - 1);
  }
  
  void draw() {
    for (Particle p : particles) {
      p.collide();
      p.move();
      p.draw(); 
    }
  }
}
