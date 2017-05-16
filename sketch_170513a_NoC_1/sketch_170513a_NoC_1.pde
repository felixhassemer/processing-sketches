// GLOBAL

PVector loc, vel, acc, grav;
int d = 50;
float r = d/2;

float xoff;
float xincr;

void setup() {
  size(800, 800);
  noStroke();
  fill(0);

  loc = new PVector(width/2, height/2);
  vel = new PVector(2, 1);
  grav = new PVector(0, 0.1);

}

void draw() {
  // acc.random2D();
  acc = PVector.random2D();
  acc.div(10);
  vel.limit(10);

  background(255);

  vel.add(acc);
  vel.add(grav);
  loc.add(vel);
  ellipse(loc.x, loc.y, d, d);

  if ((loc.x < 0 + r) || (loc.x > width - r)) {
    vel.x = -vel.x;
  } else if ((loc.y < 0 + r) || (loc.y > height - r)) {
    vel.y = -vel.y;
  }
  xoff += xincr;
}
