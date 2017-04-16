class Circle {
  float x, y, diameter;
  int canv;
  color col;
  boolean toggle;
  Ani ani;
  float weight;

  Circle(int canv, float x, float y, float diam, boolean toggle, float weight) {
    this.canv = canv;
    this.x = x;
    this.y = y;
    this.diameter = diam;
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
      canvas[canv].strokeWeight(this.weight/diameter);
      canvas[canv].noFill();
    }
    canvas[canv].pushMatrix();
    canvas[canv].translate(x, y);
    canvas[canv].scale(diameter);
    canvas[canv].ellipse(0, 0, 1, 1);
    canvas[canv].popMatrix();
  }

  void grow() {
    ani = new Ani(this, 3, "diameter", canvas[canv].width+100);
  }

  void flipColor() {
    toggle = !toggle;
    if (toggle) {
      col = color(0);
    } else {
      col = color(cOne);
    }
  }
}
