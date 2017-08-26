class Particle {
  PVector pos;
  PVector vel;
  PVector acc;
  float maxSpeed = 2;

  Particle(int x, int y) {
    this.pos = new PVector(x, y);
    this.vel = new PVector(0, 0);
    this.acc = new PVector(0, 0);
  }

  void display() {
    stroke(255);
    strokeWeight(2);
    point(pos.x, pos.y);
  }

  void update() {
    vel.add(acc);
    vel.limit(maxSpeed);
    pos.add(vel);
    acc.mult(0);
  }

  void addForce(PVector force) {
    acc.add(force);
  }

  void follow(PVector[] vectors) {
    int x = floor(pos.x / scl);
    int y = floor(pos.y / scl);

    int index = x + y * cols;

    // check if index is out of bounds
    if (index > vectors.length) index = vectors.length - 1;
    else if (index < 0) index = 0;
    // add the underlying vector as a force
    this.addForce(vectors[index]);
  }

}
