class SoundProcessor {
  float level = 0;
  float maxAmp = 200;
  int detectFreq = 800;
  int maxIndex = 0;
  float[] amps;
  float[] normAmps;
  FFT fft;
  AudioInput source;

  SoundProcessor(FFT fft, AudioInput source) {
    this.fft = fft;
    this.source = source;
    this.amps = new float[fft.avgSize()];
    this.normAmps = new float[fft.avgSize()];
  }

  float level() {
    level = source.mix.level();
    return level;
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
    for (int i=0; i < amps.length; i++) {
      if (amps[i] > maxAmp) {
        maxAmp = amps[i];
        maxIndex = i;
      } else {
        maxAmp -= 0.1;
        maxAmp = constrain(maxAmp, 0, 200);
      }
    }
  }

  float getMaxFreq() {
    float maxAmpFreq;
    maxAmpFreq = fft.getAverageCenterFrequency(maxIndex);
    maxAmpFreq = constrain(maxAmpFreq, 1, detectFreq);
    return maxAmpFreq;
  }
}
