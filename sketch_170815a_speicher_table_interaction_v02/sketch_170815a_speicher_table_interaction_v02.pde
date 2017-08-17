// import libraries
import processing.video.*;
Particle p;
Particle[] particles = new Particle[1000];
int pCount = 0;

void setup() {
  size(1280, 960, P2D);
  background(0);

  p = new Particle(40, 70);
}

void draw() {
  background(0);
  // p.display();

  if (particles.length != 0) {
    for (Particle p : particles) {
      p.display();
    }
  }

  // here goes code for visuals

}

void mousePressed() {
  particles[pCount] = new Particle(mouseX, mouseY);
  pCount ++;
}

void stop() {
  super.stop();
}
