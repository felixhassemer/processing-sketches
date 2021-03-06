class Particle {
  float a, r;
  float x, y;
  int canv;
  color col;
  boolean toggle;
  Ani ani;
  PApplet parent;

  Particle(PApplet parent, int canv, float a, float r, color col) {
    this.parent = parent;
    this.canv = canv;
    this.a = a;
    this.r = r;
    this.col = col;
  }

  void polar() {
    x = r * cos(a);
    y = r * sin(a);
  }

  void display() {
    canvas[canv].stroke(col);
    canvas[canv].strokeWeight(10);
    canvas[canv].noFill();
    canvas[canv].pushMatrix();
    canvas[canv].translate(x, y);
    canvas[canv].point(0, 0);
    canvas[canv].popMatrix();
  }

  void move() {
    ani = new Ani(this, 6, "r", canvas[canv].width/2+100, Ani.LINEAR);
  }

  void moveInverse() {
    r = canvas[canv].width/2+100;
    ani = new Ani(this, 4, "r", 0);
  }
}
