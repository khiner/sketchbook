class Listener implements AudioListener {
  float[] left;
  float[] right;
  float thresh = .7;
  int[] activeIndices = new int[10];
  synchronized void samples(float[] samp) { 
    left = samp;
  }
  synchronized void samples(float[] sampL, float[] sampR) { 
    left = sampL; 
    right = sampR;
  }

  void draw() {
    if (left == null)
      return;
    float best = 0;
    for (int i = 0; i < left.length; ++i)
      if (left[i] > best)
        best = left[i];
    if (best > thresh) {
      weight *= .997;
      lines.add(new Line(random(width - 1), random(height - 1), (int)random(8)*(QUARTER_PI), 1, weight*best, lines.size()));
      for (int a = 0; a < activeIndices.length; ++a) {
        lines.get(activeIndices[a]).resetColor();
        activeIndices[a] = (int)random(0, lines.size());
        lines.get(activeIndices[a]).switchColor();
        //        for (Line l : lines)
        //          l.startGrow();
      }
    }
    for (Line l : lines) {
      l.grow(best);
      l.draw();
    }
  }
}

