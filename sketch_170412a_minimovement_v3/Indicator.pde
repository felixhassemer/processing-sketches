class Indicator {
  float x, y, diam;
  color col, onC, offC;
  FFT fft;
  float[] normArray;
  int low, high, bandThreshold;
  float sensitivity;

  // Amplitude variables
  float[] amps;
  float maxAmp;

  // Beat variables
  boolean beat;
  float beatSize;

  // Timer and Counter variables
  boolean hasFinished;
  int startTime;
  int offTime;
  int beatCount;

  // CONSTRUCTOR
  ///////////////////////////////////////////////////////////
  Indicator(float x, float y, float diam, color offC, color onC) {
    this.x = x;
    this.y = y;
    this.diam = diam;
    this.onC = onC;
    this.offC = offC;
    this.beatCount = 30;
    this.maxAmp = 200;
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
    if (beatCount > 256) {
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
    float[] activeAvg = new float[32];
    float beatSum = 0;

    for (int j=low; j < high; j++) {
      if (normArray[j] > sensitivity) {
        count++;
        activeAvg[j] = fft.getAvg(j);
        beatSum += activeAvg[j];
      }

      // break if enough bands go above threshold
      if (hasFinished) {
        if (count >= bandThreshold) {
          col = onC;
          startTime = millis();
          beat = true;
          beatSize = norm((beatSum / (high - low)), 0, maxAmp);
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
    ellipse(x, y, diam, diam);
  }
}
