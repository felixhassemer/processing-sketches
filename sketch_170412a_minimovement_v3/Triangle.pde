class Triangle {
  float x, y, diam;
  int canv;
  color col;
  boolean toggle;
  Ani ani;
  float weight;

  Triangle(int canv, float x, float y, float diam, boolean toggle, float weight, color col) {
    this.canv = canv;
    this.x = x;
    this.y = y;
    this.diam = diam;
    this.toggle = toggle;
    this.weight = weight;
    this.col = col;
  }

  void display() {
    if (this.weight == 0) {
      canvas[canv].fill(col);
      canvas[canv].noStroke();
    } else {
      col = color(cOne);
      canvas[canv].stroke(col);
      canvas[canv].noFill();
      canvas[canv].strokeWeight(this.weight/this.diam);
    }
    canvas[canv].pushMatrix();
    canvas[canv].translate(x, y);
    canvas[canv].scale(diam);
    canvas[canv].triangle(-1, 1,
                          0, -1,
                          1, 1);
    canvas[canv].popMatrix();
  }

  void grow() {
    ani = new Ani(this, 3, "diam", canvas[canv].width/2-10);
  }

  void moveReverse() {
    diam = canvas[canv].width;
    ani = new Ani(this, 3, "diam", 1);
  }

  void flipColor() {
    toggle = !toggle;
    if (toggle) col = color(0);
  }
}
