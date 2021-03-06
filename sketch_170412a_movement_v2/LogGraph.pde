class LogGraph {
  int x, y, scaleFactor, fullWidth;
  float w;
  float[] h;
  int low, high;
  float[] amps;
  float[] normArray;
  float maxAmp;
  FFT fft;
  Indicator indicator;
  color cGraph, cBandRange, cActiveBand;

  // CONSTRUCTOR
  LogGraph(FFT fftTemp, color tempCGraph, color tempCBandRange, color tempCActiveBand) {
    fft = fftTemp;
    maxAmp = 400;
    cGraph = tempCGraph;
    cBandRange = tempCBandRange;
    cActiveBand = tempCActiveBand;
    normArray = new float[512];
    amps = new float[512];
    h = new float[512];
  }

  // position of lower left corner of the graph
  void setPosition(int tempX, int tempY) {
    x = tempX;
    y = tempY;
  }

  // size - height is subtracted from y position
  void setSize(int tempW, int tempScale) {
    fullWidth = tempW;
    w = float(tempW)/fftLog.avgSize();
    scaleFactor = tempScale;
  }

  // fill arrays with averages
  void getAmps() {
    for (int i=0; i < fft.avgSize(); i++) {
      amps[i] = fft.getAvg(i);
      normArray[i] = norm(amps[i], 0, maxAmp);
    }
  }

  // full spectrum of bands
  void display() {
    for (int i=0; i < fft.avgSize(); i++) {
      h[i] = scaleFactor * normArray[i];

      // draw all bands
      fill(cGraph);
      stroke(0);
      rect(i*w, y, w, -h[i]);
    }
  }

  // overload function for bandranges
  void display(Indicator tIndicator) {
    indicator = tIndicator;

    low = indicator.low;
    high = indicator.high;

    for (int i=0; i < fft.avgSize(); i++) {
      // the line height for sensitivity
      float lnH = y - (scaleFactor*indicator.sensitivity);

      // bandrange and active bands in different colors
      if ((i >= low) && (i <= high)) {
        if (normArray[i] > indicator.sensitivity) {
          fill(cActiveBand);
        } else {
          fill(cBandRange);
        }
        // rects on indicator line
        stroke(0);
        rect(i*w, lnH, w, 5);
        // bands below
        rect(i*w, y, w, -h[i]);
      } else {
        noFill();
        stroke(255);
        line(0, lnH, fullWidth, lnH);
      }
    }

    // decrements the maximum Amplitude or increases when new max(amps) is higher
    if (maxAmp > max(amps)) {
      maxAmp -= 0.1;
    } else {
      maxAmp = max(amps);
    }
  }


}
