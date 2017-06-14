class Circle {
  float x, y, diam;
  int canv;
  color col;
  int alpha;
  boolean toggle;
  Ani ani;
  float weight;

  Circle(int canv, float x, float y, float diam, boolean toggle, float weight, color col) {
    this.canv = canv;
    this.x = x;
    this.y = y;
    this.diam = diam;
    this.toggle = toggle;
    this.weight = weight;
    this.alpha = 100;
    this.col = col;
  }

  void display() {
    if (weight == 0) {
      canvas[canv].fill(col);
      canvas[canv].noStroke();
    } else {
      canvas[canv].stroke(col);
      canvas[canv].strokeWeight(weight);
      canvas[canv].noFill();
    }
    canvas[canv].ellipse(x, y, diam, diam);
  }

  void grow() {
    ani = new Ani(this, 3, "diam", canvas[canv].width-150);
  }

  void flipColor() {
    toggle = !toggle;
    if (toggle) col = color(0);
  }

  void moveReverse() {
    diam = canvas[canv].width+200;
    ani = new Ani(this, 3, "diam", canvas[canv].width-150);
  }
}
