class Attractor {
  PVector pos;
  float r;

  Attractor(float x, float y, int r) {
    this.pos = new PVector(x, y);
    this.r = r;
  }

  void display() {
    stroke(0, 255, 0);
    strokeWeight(2);
    noFill();
    ellipse(pos.x, pos.y, r*2, r*2);
  }

  PVector attract(Boid b, int intensity) {
    PVector dir = PVector.sub(pos, b.position);
    float d = dir.mag();
    dir.normalize();
    d = constrain(d, 5, r);
    float force = 1 * intensity / d;
    dir.mult(force);
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
