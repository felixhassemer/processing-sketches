class Rectangle {
  float x, y, diam;
  int canv;
  color col;
  boolean toggle;
  Ani ani;
  float weight;

  Rectangle(int canv, float x, float y, float diam, boolean toggle, float weight, color col) {
    this.canv = canv;
    this.x = x;
    this.y = y;
    this.diam = diam;
    this.toggle = toggle;
    this.weight = weight;
    this.col = col;
  }

  void display() {
    if (weight == 0) {
      canvas[canv].fill(col);
      canvas[canv].noStroke();
    } else {
      col = cOne;
      canvas[canv].stroke(col);
      canvas[canv].strokeWeight(weight);
      canvas[canv].noFill();
    }
    canvas[canv].rectMode(CENTER);
    canvas[canv].rect(x, y, diam, diam);
    canvas[canv].rectMode(CORNER);
  }

  void grow() {
    ani = new Ani(this, 3, "diam", canvas[canv].width+100);
  }

  void moveReverse() {
    diam = canvas[canv].width*2;
    ani = new Ani(this, 3, "diam", 0);
  }

  void flipColor() {
    toggle = !toggle;
    if (toggle) col = color(0);
  }
}
