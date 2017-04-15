class Triangle {
  float x, y, diameter;
  int canv;
  color col;
  boolean toggle;
  Ani ani;

  Triangle(int canv, float x, float y, float diam, boolean toggle) {
    this.canv = canv;
    this.x = x;
    this.y = y;
    this.diameter = diam;
    this.toggle = toggle;
  }

  void display() {
    canvas[canv].noStroke();
    canvas[canv].fill(col);
    canvas[canv].pushMatrix();
    canvas[canv].translate(x, y);
    canvas[canv].scale(diameter);
    canvas[canv].triangle(-1, 1,
                          0, -1,
                          1, 1);
    canvas[canv].popMatrix();
  }

  void grow() {
    ani = new Ani(this, 3, "diameter", canvas[canv].width/2-10);
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
