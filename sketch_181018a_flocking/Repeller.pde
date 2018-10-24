class Repeller {
  PVector pos;
  float r;

  Repeller(float x, float y, int r) {
    this.pos = new PVector(x, y);
    this.r = r;
  }

  void display(PGraphics canv) {
    canv.stroke(0, 0, 255);
    canv.strokeWeight(2);
    canv.noFill();
    canv.ellipse(pos.x, pos.y, r*2, r*2);
  }

  PVector repel(Boid b, int intensity) {
    PVector dir = PVector.sub(pos, b.position);
    float d = dir.mag();
    dir.normalize();
    d = constrain(d, 5, r);
    float f = -1 * intensity / d;
    dir.mult(f);
    return dir;
  }

  void update(int x, int y, int radius) {
    pos.x = x;
    pos.y = y;
    r = radius;
  }

  void update(int x, int y) {
    pos.x = x;
    pos.y = y;
  }
}
