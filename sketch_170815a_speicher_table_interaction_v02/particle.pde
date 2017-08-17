class Particle {
  PVector pos;
  PVector vel;
  PVector acc;
  float maxSpeed = 2;

  Particle(int x, int y) {
    this.pos = new PVector(x, y);
    this.vel = new PVector();
    this.acc = new PVector();
  }

  void display() {
    stroke(255);
    point(pos.x, pos.y);
  }

  void update() {
    vel.limit(maxSpeed);
    vel.add(acc);
    pos.add(vel);
    acc.mult(0);
  }

}
