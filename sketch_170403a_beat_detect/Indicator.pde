class Indicator {
  float x, y, diameter;
  color col, onC, offC;

  // CONSTRUCTOR
  Indicator(float tempX, float tempY, float tempDiam, color tempOffC, color tempOnC) {
    x = tempX;
    y = tempY;
    diameter = tempDiam;
    onC = tempOnC;
    offC = tempOffC;
  }

  // Class Functions
  void flashColor(Amplitude input, float threshold) {
    if (input.analyze() > threshold) {
      col = onC;
    } else {
      col = offC;
    }
  }

  void display() {
    fill(col);
    ellipse(x, y, diameter, diameter);
  }
}
