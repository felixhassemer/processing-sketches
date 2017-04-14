class Circle {
  float x, y, diameter;
  int canv;
  color col;
  Ani ani;

  Circle(float _x, float _y, float _diameter, int _canv) {
    x = _x;
    y = _y;
    diameter = _diameter;
    canv = _canv;
  }

  void display() {
    canvas[canv].noStroke();
    canvas[canv].fill(col);
    canvas[canv].pushMatrix();
    canvas[canv].translate(0, -20);
    canvas[canv].scale(diameter);
    canvas[canv].ellipse(0, 0, 1, 1);
    canvas[canv].popMatrix();
  }

  void grow() {
    ani = new Ani(this, 3, "diameter", canvas[canv].width+80);
  }

  void flipColor(boolean _toggle) {
    if (_toggle) {
      col = color(0);
    } else {
      col = color(255);
    }
  }
}
