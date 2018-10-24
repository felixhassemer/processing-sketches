// The Flock (a list of Boid objects)


class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids

  Flock() {
    this.boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }

  void run(PGraphics canv, float sepDist, float aliDist, float cohDist) {
    for (Boid boid : boids) {
      qt.insert(boid);
      boid.run(canv, boids, sepDist, aliDist, cohDist);  // Passing the entire list of boids to each boid individually
    }
  }

  void addBoid(Boid b) {
    boids.add(b);
  }

  void applyForce(PVector f) {
    for (Boid b : boids) {
      b.applyForce(f);
    }
  }

  void centerForce(PVector cPos, float rx, float ry, int intensity, int direction) {
    for (Boid b : boids) {
      if ( (pow((b.position.x - cPos.x), 2) / (rx * rx)) +
           (pow((b.position.y - cPos.y), 2) / (ry * ry)) >= 1) {
        PVector dir = PVector.sub(cPos, b.position);
        float d = dir.mag();
        dir.normalize();
        // d = constrain(d, 5, 100);
        float f = direction * intensity / d;
        dir.mult(f);
        b.applyForce(dir);
      }
    }
  }

  void speedChange(float ctrl, float min, float max) {
    for (Boid b : boids) {
      b.maxspeed = constrain(ctrl * max, min, max);
    }
  }
}
