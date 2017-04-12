class LogGraph {
  int y, scaleFactor;
  float w;

  LogGraph(int tempY, int tempScale) {
    y = tempY;
    scaleFactor = tempScale;
  }

  void display() {
    w = float(width)/fftLog.avgSize();

  }

}
