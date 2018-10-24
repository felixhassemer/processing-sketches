class Analyzer {
  Minim minim;
  FFT fft;
  AudioInput source;
  int x, y, w, h;
  float max;
  float[] bands;
  int avgSize;
  WindowFunction fftwin;
  boolean isOnset;
  float sum;
  int threshold;
  int time;

  Analyzer(PApplet parent, int x, int y, int w, int h, WindowFunction fftwin) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.fftwin = fftwin;
    this.minim = new Minim(parent);
    this.source = minim.getLineIn(Minim.STEREO, 2048);
    this.fft = new FFT(source.bufferSize(), source.sampleRate());
    this.max = 0;
    this.bands = new float[16];
    this.isOnset = false;
    this.fft.window(fftwin);
    this.fft.logAverages(22, 1);
    this.avgSize = fft.avgSize();
    this.threshold = 214;
    this.time = millis() + this.threshold;
    this.sum = 0;
  }

  void update(PGraphics canv) {
    show(canv);

    // pass the mix into the fft
    fft.forward(source.mix);
    getBands();
    int wBand = (int)(w/avgSize); // calculate width per band
    float tempmax = 0;
    sum = 0;

    for (int i=0; i < avgSize; i++) {
      float avg = bands[i];
      tempmax = (avg > tempmax) ? avg : tempmax;  // set new tempmax if it's higher than the previous
      canv.rect(i*wBand, h, i*wBand + wBand, h - norm(avg, 0, max)*(h - h/6)); // leave h/6 headroom
      sum += avg; // add averages to the sum
    }
    sum = norm(sum, 0, max); // normalize the sum so it's easier to work with
    checkOnset(tempmax);
    showOnset(canv);
    showMax(canv);
    max = (tempmax > max) ? tempmax : max; // set new overall maximum
    decreaseMax(audioThreshold);
  }

  void show(PGraphics canv) {
    canv.background(155);
    canv.fill(255);
    canv.noStroke();
    canv.rectMode(CORNERS);
  }

  // fill the bands array with all the averages
  void getBands() {
    for (int i=0; i < avgSize; i++) {
      bands[i] = fft.getAvg(i);
    }
  }

  // check if the tmp maximum is over max - a threshold
  // and if enough time has passed after last onset
  void checkOnset(float tempmax) {
    if (millis() > time &&
        tempmax > max - max / 6) {
      time = millis() + threshold;
      isOnset = true;
    } else {
      isOnset = false;
    }
  }

  // show dot marker if isOnset it true
  void showOnset(PGraphics canv) {
    if (isOnset) {
      canv.fill(255, 0, 0);
      canv.noStroke();
      canv.ellipse(w/2, h/8, 80, 80);
    }
  }

  // always decrease the max variable
  void decreaseMax(float _threshold) {
    max -= 0.5;
    if (max < _threshold) max = _threshold;
  }

  void showMax(PGraphics canv) {
    canv.fill(0);
    canv.noStroke();
    canv.text("Max : " + max, 150, 50);
  }

  // close the audioinput and stop minim
  void end() {
    this.source.close();
    this.minim.stop();
  }
}
