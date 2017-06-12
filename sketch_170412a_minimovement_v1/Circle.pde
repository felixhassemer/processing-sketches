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
    canvas[canv].pushMatrix();
    canvas[canv].translate(x, y);
    canvas[canv].scale(diam);
    canvas[canv].ellipse(0, 0, 1, 1);
    canvas[canv].popMatrix();
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
    // ani.reverse();
    diam = canvas[canv].width+200;
    ani = new Ani(this, 3, "diam", canvas[canv].width-150);

  }
}
