// GLOBAL
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput source;
BeatDetect beat;
BeatListener listener;
FFT fftLin;
FFT fftLog;
WindowFunction myWindow = FFT.NONE;

int number = 10;
int dotSize = 200;
float[] amps;

color bgndCol = color(0);
color onKick = color(255, 0, 0);
color onSnare = color(0, 255, 0);
color onHat = color(0, 0, 255);
color offColor = color(60, 60, 60);


void setup() {
  size(1000, 1000);
  noStroke();

  // inputs zuweisen und objekte initialisieren
  minim = new Minim(this);
  source = minim.getLineIn(Minim.STEREO, 1024);
  fftLog = new FFT(source.bufferSize(), source.sampleRate());
  fftLog.logAverages(60, 6);
  fftLog.window(myWindow);
  beat = new BeatDetect(source.bufferSize(), source.sampleRate());
  beat.setSensitivity(300);
  listener = new BeatListener(beat, source);
  amps = new float[fftLog.avgSize()];
}

void draw() {
  background(bgndCol);

  logGraph();
}

// GRAPH function
void logGraph() {
  fftLog.forward(source.mix);
  float spectrumScale = 500;
  int w = int((3*width/4)/fftLog.avgSize());

  for (int i=0; i < fftLog.avgSize(); i++) {
    amps[i] = map(fftLog.getAvg(i), 0, 600, 0, 1);
    if (amps[i] > 0.5) {
      stroke(255, 0, 0);
    } else {
      stroke(255);
    }
    line(i*w+width/8, height/2, i*w+width/8, height/2-amps[i]*spectrumScale);

    // text every 5 indexes
    if (i % 5 == 0) {
      textSize(8);
      fill(255);
      noStroke();
      text(i, i*w+width/8, height/2+10);
    }
  }
}

void stop() {
  source.close();
  minim.stop();
  super.stop();
}
