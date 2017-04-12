class LogGraph {
  int x, y, scaleFactor;
  float w, h;
  int low, high;
  float[] amps;
  float maxAmp;
  FFT fft;
  Indicator indicator;

  LogGraph(FFT fftTemp) {
    fft = fftTemp;
    amps = new float[512];
    maxAmp = 600;
  }

  void setSize(int tempW, int tempScale) {
    w = float(tempW)/fftLog.avgSize();
    scaleFactor = tempScale;
  }

  void setPosition(int tempX, int tempY) {
    x = tempX;
    y = tempY;
  }

  void display(Indicator tIndicator) {
    indicator = tIndicator;

    low = indicator.low;
    high = indicator.high;

    for (int i=0; i < fft.avgSize(); i++) {
      amps[i] = fft.getAvg(i);
      float avg = map(fft.getAvg(i), 0, maxAmp, 0, 1);
      h = scaleFactor * avg;
      float lnH = scaleFactor - (scaleFactor*indicator.sensitivity);

      // paint bandrange and active bands in different colors
      if ((i >= low) && (i <= high)) {
        if (avg > indicator.sensitivity) {
          fill(cActiveBand);
        } else {
          fill(cBandRange);
        }
        // draw rects width on indicator line
        rect(i*w, lnH, w, 10);
      } else {
        noFill();
        stroke(cGraph);
        line(0, lnH, width, lnH);
      }
      rect(i*w, y, w, -h);
    }
    if (maxAmp > max(amps)) {
      maxAmp -= 0.1;
    } else {
      maxAmp = max(amps);
    }
  }
}
