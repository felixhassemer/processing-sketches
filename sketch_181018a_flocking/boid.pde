// The Boid class

class Boid {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed

  Boid(float x, float y) {
    this.acceleration = new PVector(0, 0);
    this.velocity = PVector.random2D(); // initial velocity vector (random)
    this.position = new PVector(x, y);
    this.r = 2.0;
    this.maxspeed = 10;
    this.maxforce = 0.4;
  }

  void run(PGraphics canv, ArrayList<Boid> boids, float sepDist, float aliDist, float cohDist) {
    flock(boids, sepDist, aliDist, cohDist); // arraylist boids, float separationdist, float aligndist, float cohesiondist
    update();
    borders();
    render(canv);
    // centerForce(new PVector(canv.width/2, canv.height/2), 600, 400, 80);
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids, float sepDist, float aliDist, float cohDist) {
    PVector sep = separate(boids, sepDist);   // Separation
    PVector ali = align(boids, aliDist);      // Alignment
    PVector coh = cohesion(boids, cohDist);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(1.6);
    ali.mult(0.5);
    coh.mult(0.4);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  // Method to update position
  void update() {
    // Update velocity
    velocity.add(this.acceleration);
    // Limit speed
    velocity.limit(this.maxspeed);
    position.add(this.velocity);
    // Reset acceleration to 0 each cycle
    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, this.position);  // A vector pointing from the position to the target
    // Scale to maximum speed
    desired.setMag(this.maxspeed);
    // desired.limit(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, this.velocity);
    steer.limit(this.maxforce);  // Limit to maximum steering force
    return steer;
  }

  void render(PGraphics canv) {
    // Draw a triangle rotated in the direction of velocity
    float heading = (float) FastMath.atan2(this.velocity.y, this.velocity.x);
    float theta = heading + radians(90);
    canv.fill(255);
    canv.noStroke();
    canv.pushMatrix();
    canv.translate(this.position.x, this.position.y);
    canv.rotate(theta);
    canv.beginShape(TRIANGLES);
    canv.vertex(0, -this.r*2);
    canv.vertex(-this.r, this.r*2);
    canv.vertex(this.r, this.r*2);
    canv.endShape();
    canv.popMatrix();
  }

  // Wraparound
  void borders() {
    if (this.position.x < -this.r) this.position.x = width+this.r;
    if (this.position.y < -this.r) this.position.y = height+this.r;
    if (this.position.x > width+r) this.position.x = -this.r;
    if (this.position.y > height+r) this.position.y = -this.r;
  }

  // void centerForce(PVector cPos, float rx, float ry, int intensity) {
  //
  //   // check if boid is inside of ellipse, if it is, condition is satisfied
  //   if ( (pow((this.position.x - cPos.x), 2) / (rx * rx)) +
  //        (pow((this.position.y - cPos.y), 2) / (ry * ry)) >= 1) {
  //     PVector dir = PVector.sub(cPos, this.position);
  //     float d = dir.mag();
  //     dir.normalize();
  //     // d = constrain(d, 5, 100);
  //     float f = 1 * intensity / d;
  //     dir.mult(f);
  //     applyForce(dir);
  //   }
  // }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate(ArrayList<Boid> boids, float _separationdist) {
    float desiredseparation = _separationdist;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    Circle checkArea = new Circle(this.position.x, this.position.y, desiredseparation);
    ArrayList<Boid> others = qt.query(checkArea, null);

    for (Boid other : others) {
      if (other != this) {
        // calculate Vector pointing away from neighbor
        float d = PVector.dist(this.position, other.position);
        // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
        if ((d > 0) && (d < desiredseparation)) {
          PVector diff = PVector.sub(this.position, other.position);
          diff.normalize();
          diff.div(d);
          steer.add(diff);
          count++;
        }
      }
    }
    // average out
    if (count > 0) {
      steer.div((float)count);
    }
    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      steer.setMag(this.maxspeed);
      steer.sub(this.velocity);
      steer.limit(this.maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align(ArrayList<Boid> boids, float _neighbordist) {
    float neighbordist = _neighbordist;
    int count = 0;
    PVector sum = new PVector(0, 0);
    Circle checkArea = new Circle(this.position.x, this.position.y, neighbordist);
    ArrayList<Boid> others = qt.query(checkArea, null);

    for (Boid other : others) {
      if (other != this) {
        float d = PVector.dist(this.position, other.position);
        if ((d > 0) && (d < neighbordist)) {
          sum.add(other.velocity);
          count++;
        }
      }
    }
    if (count > 0) {
      sum.div((float)count);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.setMag(this.maxspeed);
      PVector steer = PVector.sub(sum, this.velocity);
      steer.limit(this.maxforce);
      return steer;
    }
    else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids,
  // calculate steering vector towards that position
  PVector cohesion(ArrayList<Boid> boids, float _neighbordist) {
    float neighbordist = _neighbordist;
    int count = 0;
    PVector sum = new PVector(0, 0);
    Circle checkArea = new Circle(this.position.x, this.position.y, neighbordist);
    ArrayList<Boid> others = qt.query(checkArea, null);

    for (Boid other : others) {
      if (other != this) {
        float d = PVector.dist(this.position, other.position);
        if ((d > 0) && (d < neighbordist)) {
          sum.add(other.position);
          count++;
        }
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);
    }
    else {
      return new PVector(0, 0);
    }
  }
}
