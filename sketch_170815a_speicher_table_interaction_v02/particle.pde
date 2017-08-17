class Particle {
  PVector pos, vel, acc;

  Particle(int x, int y) {
    this.pos = new PVector(x, y);
    this.vel = new PVector();
    this.acc = new PVector();
  }

  void display() {
    stroke(255);
    point(pos.x, pos.y);
  }

  void move() {
    vel.limit(6);
    vel.add(acc);
    pos.add(vel);
  }

}
