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
Indicator[] dots = new Indicator[number];

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
  fftLin = new FFT(source.bufferSize(), source.sampleRate());
  fftLin.linAverages(100);
  fftLin.window(myWindow);
  fftLog = new FFT(source.bufferSize(), source.sampleRate());
  fftLog.logAverages(60, 6);
  fftLog.window(myWindow);
  beat = new BeatDetect(source.bufferSize(), source.sampleRate());
  beat.setSensitivity(300);
  listener = new BeatListener(beat, source);


  dots[0] = new Indicator(width/4, 2*height/3, dotSize, offColor, onKick);
  dots[1] = new Indicator(width/2, 2*height/3, dotSize, offColor, onSnare);
  dots[2] = new Indicator(width-width/4, 2*height/3, dotSize, offColor, onHat);
}

void draw() {
  background(bgndCol);

  // linGraph();
  logGraph();

  noStroke();
  dots[0].flashKick(beat);
  dots[0].display();
  dots[1].flashSnare(beat);
  dots[1].display();
  dots[2].flashHat(beat);
  dots[2].display();
}

// GRAPH functions

void linGraph() {
  // draw the FFT linear average
  fftLin.forward(source.mix);
  float spectrumScale = 300;
  int w = int((width/2)/fftLin.avgSize());
  for (int i=0; i < fftLin.avgSize(); i++) {
    stroke(255);
    float h = map(fftLin.getAvg(i), 0, 100, 0, spectrumScale);
    line(i*w+width/4, height/2, i*w+width/4, height/2-h);

    // text every 5 indexes
    if (i % 5 == 0) {
      textSize(8);
      fill(255);
      noStroke();
      text(i, i*w+width/4, height/2+10);
    }
  }
}

void logGraph() {
  fftLog.forward(source.mix);
  float spectrumScale = 100;
  int w = int((width/2)/fftLog.avgSize());

  for (int i=0; i < fftLog.avgSize(); i++) {
    // float centerFrequency = fftLog.getAverageCenterFrequency(i);
    // float averageWidth = fftLog.getAverageBandWidth(i);
    //
    // float lowFreq = centerFrequency - averageWidth/2;
    // float highFreq = centerFrequency + averageWidth/2;
    //
    // int xl = (int)fftLog.freqToIndex(lowFreq);
    // int xr = (int)fftLog.freqToIndex(highFreq);

    stroke(255);
    float h = map(fftLog.getAvg(i), 0, 200, 0, spectrumScale);
    line(i*w+width/4, height/2, i*w+width/4, height/2-h);
    // rect(xl, height, xr, height- fftLog.getAvg(i)*spectrumScale);

    // text every 5 indexes
    if (i % 5 == 0) {
      textSize(8);
      fill(255);
      noStroke();
      text(i, i*w+width/4, height/2+10);
    }
  }
}

void stop() {
  source.close();
  minim.stop();
  super.stop();
}
