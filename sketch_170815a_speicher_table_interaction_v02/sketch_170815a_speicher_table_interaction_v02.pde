// import libraries
import processing.video.*;

ArrayList<Particle> particles;

int cols;
int rows;
int scl = 10;
PVector[] flowField;

float incr = 0.001;
float zoff = 0;



void setup() {
  size(1280, 960, P2D);
  background(0);

  particles = new ArrayList<Particle>();

  cols = floor(width / scl);
  rows = floor(height / scl);
  flowField = new PVector[(cols*rows)];
}

void draw() {
  background(0);
  strokeWeight(1);
  stroke(255);

  // here goes code for visuals
  for (Particle p : particles) {
    p.display();
    p.update();
  }

  float xoff = 0;
  for (int x = 0; x < cols; x++) {
    float yoff = 0;
    for (int y = 0; y < rows; y++) {
      int index = x + y * cols;
      float angle = noise(xoff, yoff, zoff) * TWO_PI;
      PVector v = PVector.fromAngle(angle);
      v.setMag(11);
      flowField[index] = v;

      // draw the vectors as lines
      pushMatrix();
      translate(x*scl, y*scl);
      rotate(v.heading());
      line(0, 0, scl, 0);
      popMatrix();

      yoff += incr;
    }
    xoff += incr;
  }
  zoff += incr;
}

void mousePressed() {
  particles.add(new Particle(mouseX, mouseY));
}

void stop() {
  super.stop();
}
