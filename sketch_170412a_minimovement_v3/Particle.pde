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
    canvas[canv].point(x, y);
  }

  void move() {
    ani = new Ani(this, 1, "r", canvas[canv].width/2+100, Ani.LINEAR);
  }

  void moveReverse() {
    r = canvas[canv].width/2+100;
    ani = new Ani(this, 4, "r", 0);
  }
}
