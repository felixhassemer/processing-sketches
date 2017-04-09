// GLOBAL VARS
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput source;
FFT fftFull;
FFT fftLin;
FFT fftLog;
WindowFunction myWindow = FFT.NONE;

Indicator kickDot;

color bgndC = color(0);
color graphC = color(255);


void setup() {
  size(800, 800);

  minim = new Minim(this);
  source = minim.getLineIn(Minim.STEREO, 1024);
  fftFull = new FFT(source.bufferSize(), source.sampleRate());
  fftLin = new FFT(source.bufferSize(), source.sampleRate());
  fftLog = new FFT(source.bufferSize(), source.sampleRate());
  kickDot = new Indicator(width/2, height/2, 50, color(60), color(255));

  fftFull.window(myWindow);
  fftLin.window(myWindow);
  fftLog.window(myWindow);
  fftLin.linAverages(60);
  fftLog.logAverages(120,12);
}

void draw() {
  background(0);

  // fullGraph(height/3, height/3);

  // linGraph(2*height/3, height/3);
  stroke(255);
  line(0, 2*height/3, width, 2*height/3);
  logGraph(height, height);
  noStroke();
  kickDot.setRange(2, 6, 3);
  kickDot.isBeat(fftLog, 0.3, 500);
  kickDot.display();
}

// full Graph of frequency spectrum
void fullGraph(int tempY, int scaleFactor) {
  fftFull.forward(source.mix);
  noFill();
  float w = float(width)/fftFull.specSize();
  for (int i=0; i < fftFull.specSize(); i++) {
    float h = scaleFactor * map(fftFull.getBand(i), 0, 600, 0, 1);
    stroke(graphC);
    line(i*w, tempY, i*w, tempY-h);
  }
}

// Graph for linear average FFT
void linGraph(int tempY, int scaleFactor) {
  fftLin.forward(source.mix);
  noFill();
  float w = float(width)/fftLin.avgSize();
  for (int i=0; i < fftLin.avgSize(); i++) {
    float h = scaleFactor * map(fftLin.getAvg(i), 0, 600, 0, 1);
    stroke(graphC);
    rect(i*w, tempY, w, -h);
  }
}

// Graph for logarithm average FFT
void logGraph(int tempY, int scaleFactor) {
  fftLog.forward(source.mix);
  noFill();
  float w = float(width)/fftLog.avgSize();
  for (int i=0; i < fftLog.avgSize(); i++) {
    float h = scaleFactor * map(fftLog.getAvg(i), 0, 600, 0, 1);
    stroke(graphC);
    rect(i*w, tempY, w, -h);
  }
}
