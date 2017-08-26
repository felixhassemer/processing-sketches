class SoundProcessor {
  float level = 0;
  float[] levels;
  float[] frequencies;
  int index = 0;
  int smoothing = 0;
  float maxAmp = 200;
  float smAmp = 0;
  float smFreq = 0;
  int detectFreq = 800;
  int maxIndex = 0;
  int detectIndex;
  float[] amps;
  float[] normAmps;
  FFT fft;
  AudioInput source;

  SoundProcessor(FFT fft, AudioInput source, int sm, int maxDetect) {
    this.fft = fft;
    this.source = source;
    this.smoothing = sm;
    this.amps = new float[fft.avgSize()];
    this.normAmps = new float[fft.avgSize()];
    this.levels = new float[sm];
    this.frequencies = new float[sm];
    this.detectFreq = maxDetect;
    this.detectIndex = fft.freqToIndex(this.detectFreq);
  }

  void smoothData() {
    levels[index] = source.mix.level();
    frequencies[index] = getMaxFreq();

    if (index == smoothing-1) {
      index = 0;
      for (int i=0; i < smoothing; i++) {
        smAmp += levels[i];
        smFreq += frequencies[i];
      }
      // divide by length of array
      smAmp /= smoothing;
      smFreq /= smoothing;
      // println("sm Amp :" + smAmp, "sm Freq :" + smFreq);
    } else {
      index ++;
    }
  }

  void fillArray() {
    for (int i=0; i < fft.avgSize(); i++) {
      amps[i] = fft.getAvg(i);
    }
  }

  void normalizeArray() {
    for (int i= 0; i < amps.length; i++) {
      normAmps[i] = norm(amps[i], 0, maxAmp);
    }
  }

  void setMax() {
    for (int i=0; i < detectIndex; i++) {
      if (amps[i] > maxAmp) {
        maxAmp = amps[i];
        maxIndex = i;
      } else {
        maxAmp -= 0.1;
      }
    }
  }

  float getMaxFreq() {
    float maxAmpFreq;
    maxAmpFreq = fft.getAverageCenterFrequency(maxIndex);
    return maxAmpFreq;
  }
}
