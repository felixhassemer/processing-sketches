class Indicator {
  float x, y, diameter;
  color col, onC, offC;
  FFT fft;
  float[] normArray;
  int low, high, bandThreshold;
  float sensitivity;

  boolean hasFinished;
  boolean beat;
  int startTime;
  int offTime;
  int beatCount;

  // CONSTRUCTOR
  ///////////////////////////////////////////////////////////
  Indicator(float tempX, float tempY, float tempDiam, color tempOffC, color tempOnC) {
    x = tempX;
    y = tempY;
    diameter = tempDiam;
    onC = tempOnC;
    offC = tempOffC;
    beatCount = 0;
  }

  // METHODS
  ///////////////////////////////////////////////////////////
  // sets the band ranges for beat detection and their threshold
  void setRange(int tempLow, int tempHigh, int tempBandThreshold) {
    low = tempLow;
    high = tempHigh;
    bandThreshold = tempBandThreshold;
  }

  // check if enough bands in the range are loud enough
  // and set the color accordingly
  void isBeat(FFT tempfft, float tempSensitivity, int tempOffTime) {
    fft = tempfft;
    sensitivity = tempSensitivity;
    offTime = tempOffTime;

    // reset beat counter after 4 bars
    if (beatCount > 16) {
      beatCount = 1;
    }

    // allow beat detection if timer has finished
    if (millis() - startTime > offTime) {
      hasFinished = true;
    } else {
      hasFinished = false;
    }

    // create float Array for average amplitudes
    normArray = new float[fft.avgSize()];
    for (int i=0; i < fft.avgSize(); i++) {
      normArray[i] = norm(fft.getAvg(i), 0, 600);
    }
    // check if threshold is passed
    int count = 0;
    for (int j=low; j < high; j++) {
      if (normArray[j] > sensitivity) {
        count++;
      }
      // break if enough bands go above threshold
      if (hasFinished) {
        if (count >= bandThreshold) {
          col = onC;
          startTime = millis();
          beat = true;
          beatCount ++;
          break;
        }
      } else {
        beat = false;
      }
    }
    if (!beat) {
      col = offC;
    }
  }

  // draw the dot and set fill color
  void display() {
    fill(col);
    noStroke();
    ellipse(x, y, diameter, diameter);
  }
}
