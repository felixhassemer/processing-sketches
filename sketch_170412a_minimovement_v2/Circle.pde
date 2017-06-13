class Circle {
  float x, y, diam;
  int canv;
  color col;
  boolean toggle;
  Ani ani;
  float weight;

  Circle(int canv, float x, float y, float diam, boolean toggle, float weight) {
    this.canv = canv;
    this.x = x;
    this.y = y;
    this.diam = diam;
    this.toggle = toggle;
    this.weight = weight;
  }

  void display() {
    if (this.weight == 0) {
      canvas[canv].fill(col);
      canvas[canv].noStroke();
    } else {
      col = cOne;
      canvas[canv].stroke(col);
      canvas[canv].strokeWeight(this.weight/this.diam);
      canvas[canv].noFill();
    }
    canvas[canv].ellipse(this.x, this.y, this.diam, this.diam);
  }

  void grow() {
    ani = new Ani(this, 3, "diam", canvas[canv].width-150);
  }

  void flipColor() {
    toggle = !toggle;
    if (toggle) {
      col = color(0);
    } else {
      col = color(cOne);
    }
  }

  void moveInverse() {
    diam = canvas[canv].width+200;
    ani = new Ani(this, 3, "diam", canvas[canv].width-150);
  }
}
