class AudioControl {
  int beatCount;
  float xoff, yoff, xincr, yincr;
  int maxIntensity;

  AudioControl() {
    this.beatCount = 0;
    this.xoff = 0;
    this.yoff = 0;
    this.xincr = 0.002;
    this.yincr = 0.002;
    this.maxIntensity = 300;
  }

  void run(Analyzer ana) {
    countBeats(ana);
    moveNoise();
    flock.centerForce(center,
                      centerSize().x, centerSize().y,
                      calcForceIntensity(), changeDirection()); // int intensity, int direction
    //flock.speedChange(ana.sum, 10.0, 15.0);
    condense();
  }

  void countBeats(Analyzer ana) {
    if (ana.isOnset) this.beatCount ++;
  }

  PVector centerSize() {
    return new PVector(canvas.width/2 - (xNoise() * 350), canvas.height/2 - (yNoise() * 300));
  }

  void showCenter(PGraphics canv) {
    canv.stroke(0, 0, 255);
    canv.strokeWeight(1);
    canv.noFill();
    canv.ellipse(center.x, center.y, centerSize().x*2, centerSize().y*2);
  }

  int changeDirection() {
    int direction = 1;
    if (this.beatCount % 8 == 1) {
      direction = -1;
    }
    return direction;
  }

  void condense() {
    if (this.beatCount % 64 == 1) {
      flock.centerForce(center, random(400), random(400), maxIntensity * 2, 1);
    }
  }

  float sepChange(float min, float max) {
    if (this.beatCount % 16 == 1) {
      return constrain(ana.sum * max, min, max);
    } else {
      return min;
    }
  }

  int calcForceIntensity() {
    return (int) constrain(ana.sum * maxIntensity, 140, maxIntensity);
  }

  void moveNoise() {
    xoff += xincr;
    yoff += yincr;
  }

  float xNoise() {
    return noise(xoff);
  }

  float yNoise() {
    return noise(yoff);
  }
}
