class Indicator {
  float x, y, diameter;
  color col, onC, offC;
  FFT fft;
  float[] normArray;
  int low, high, bandThreshold;
  float sensitivity;

  // Amplitude variables
  float[] amps;
  float maxAmp;

  // Timer and Counter variables
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
    maxAmp = 600;
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
    normArray = new float[fft.avgSize()];
    amps = new float[fft.avgSize()];

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

    // store amplitudes in arrays
    for (int i=0; i < fft.avgSize(); i++) {
      // store average amplitudes in array
      amps[i] = fft.getAvg(i);
      // store normalized values in array
      normArray[i] = norm(fft.getAvg(i), 0, maxAmp);
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
    if (maxAmp > max(amps)) {
      maxAmp -= 0.1;
    } else {
      maxAmp = max(amps);
    }
  }

  // draw the dot and set fill color
  void display() {
    fill(col);
    noStroke();
    ellipse(x, y, diameter, diameter);
  }
}
