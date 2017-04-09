class FlashDot {
  float x, y, diameter;
  color col;

  // CONSTRUCTOR
  FlashDot(float tx, float ty, float td) {
    x = tx;
    y = ty;
    diameter = td;
  }

  void display(float duration, color onC, color offC) {
    int m = millis();
    if ((m % duration >= 0) && (m % duration <= 100)) {
      col = onC;
    } else {
      col = offC;
    }
    fill(col);
    ellipse(x, y, diameter, diameter);
  }
}
