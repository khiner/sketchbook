import ddf.minim.*;

ArrayList<Line> lines = new ArrayList<Line>();
ArrayList<PVector> points = new ArrayList<PVector>();
float weight = 7;
Minim minim;
AudioPlayer sample;
Listener listener;

void setup() {
  size(800, 500, P2D);
  smooth();
  background(255);
  minim = new Minim(this);
  sample = minim.loadFile("sample.wav", 512);
  sample.loop();
  listener = new Listener();
  sample.addListener(listener);
}

void draw() {
  listener.draw();
}

void mousePressed() {
  lines.add(new Line(mouseX, mouseY, (int)random(8)*(QUARTER_PI), .7, weight, lines.size()));
}

