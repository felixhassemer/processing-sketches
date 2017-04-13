class LogGraph {
  int x, y, scaleFactor, fullWidth;
  float w, h;
  int low, high;
  float[] amps;
  float maxAmp;
  FFT fft;
  Indicator indicator;
  color cGraph, cBandRange, cActiveBand;

  LogGraph(FFT fftTemp, color tempCGraph, color tempCBandRange, color tempCActiveBand) {
    fft = fftTemp;
    maxAmp = 600;
    cGraph = tempCGraph;
    cBandRange = tempCBandRange;
    cActiveBand = tempCActiveBand;
  }

  void setSize(int tempW, int tempScale) {
    fullWidth = tempW;
    w = float(tempW)/fftLog.avgSize();
    scaleFactor = tempScale;
  }

  void setPosition(int tempX, int tempY) {
    x = tempX;
    y = tempY;
  }

  void display(Indicator tIndicator) {
    indicator = tIndicator;
    amps = new float[fft.avgSize()];

    low = indicator.low;
    high = indicator.high;

    for (int i=0; i < fft.avgSize(); i++) {
      amps[i] = fft.getAvg(i);
      float avg = norm(fft.getAvg(i), 0, maxAmp);
      h = scaleFactor * avg;
      float lnH = y - (scaleFactor*indicator.sensitivity);

      // paint bandrange and active bands in different colors
      if ((i >= low) && (i <= high)) {
        if (avg > indicator.sensitivity) {
          fill(cActiveBand);
        } else {
          fill(cBandRange);
        }
        // draw rects width on indicator line
        rect(i*w, lnH, w, 5);
      } else {
        noFill();
        stroke(255);
        line(0, lnH, fullWidth, lnH);
        stroke(cBgnd);
        fill(cGraph);
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
