class Particle {
  float x, y, r;
  int canv;
  color col;
  boolean toggle;
  Ani ani;
  PApplet parent;

  Particle(PApplet parent, int canv, float x, float y, float r) {
    this.canv = canv;
    this.x = x;
    this.y = y;
    this.r = r;
    this.parent = parent;
  }

  void display() {
    canvas[canv].stroke(col);
    canvas[canv].noFill();
    canvas[canv].pushMatrix();
    canvas[canv].translate(x, y);
    canvas[canv].point(0, 0);
    canvas[canv].popMatrix();
  }

  void grow() {
    ani = new Ani(this, 3, "diameter", canvas[canv].width+100);
  }
}
