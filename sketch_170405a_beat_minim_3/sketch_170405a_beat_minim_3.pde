// GLOBAL VARS
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput source;
FFT fftFull;
FFT fftLin;
FFT fftLog;
WindowFunction myWindow = FFT.NONE;

Indicator rangeLow;
Indicator rangeMid;

color bgndC = color(0);
color graphC = color(255);
color graphR1 = color(0, 200, 0);


void setup() {
  size(800, 800);

  minim = new Minim(this);
  source = minim.getLineIn(Minim.STEREO, 1024);
  fftFull = new FFT(source.bufferSize(), source.sampleRate());
  fftLin = new FFT(source.bufferSize(), source.sampleRate());
  fftLog = new FFT(source.bufferSize(), source.sampleRate());
  rangeLow = new Indicator(width/2, height/2, 50, color(60), color(255));
  rangeMid = new Indicator(width/3, height/2, 50, color(60), color(255));

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
  logGraph(height, height);
  noStroke();
  rangeLow.setRange(2, 6, 3);
  rangeLow.isBeat(fftLog, 0.3, 500);
  rangeLow.display();

  rangeMid.setRange(9, 13, 3);
  rangeMid.isBeat(fftLog, 0.2, 500);
  rangeMid.display();
}

// Graph for logarithm average FFT
void logGraph(int tempY, int scaleFactor) {
  fftLog.forward(source.mix);
  noFill();
  float w = float(width)/fftLog.avgSize();
  for (int i=0; i < fftLog.avgSize(); i++) {
    float h = scaleFactor * map(fftLog.getAvg(i), 0, 600, 0, 1);
    if ((i >= rangeLow.low) && (i <= rangeLow.high)) {
      fill(graphR1);
      noStroke();
      rect(i*w, height-height*rangeLow.sensitivity, w, 10);
    } else {
      noFill();
      stroke(graphC);
      line(0, height-height*rangeLow.sensitivity, width, height-height*rangeLow.sensitivity);
    }
    rect(i*w, tempY, w, -h);
  }
}
