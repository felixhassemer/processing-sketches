// IMPORT libraries
import ddf.minim.*;
import ddf.minim.analysis.*;
import oscP5.*;
import netP5.*;

// VARIABLES *****************************************************
Minim minim;    AudioInput source;    FFT fft;    WindowFunction windowFunction = FFT.HANN;
SoundProcessor sp;
boolean listening = true;

// samples
int sampNum = 66;   // total number of loaded samples

// SUPERCOLLIDER COMMUNICATION
OscP5 osc;
NetAddress sc, ls;


// --   SETUP    ---------------------------------------------------------------
void setup() {
  size(1280, 960, P2D);
  background(0);
  frameRate(60);

  // init Minim
  if (listening) {
    initMinim();
    sp = new SoundProcessor(fft, source, 2, 800); // (fft, source, int smoothing, int maxDetectFrequency)
  }

  // init OSC and SUPERCOLLIDER
  osc = new OscP5(this, 12000);
  sc = new NetAddress("127.0.0.1", 57120);
  ls = new NetAddress("127.0.0.1", 12000);
}


// --   DRAW    ----------------------------------------------------------------
void draw() {
  background(0);
  stroke(255);
  noFill();

  // ***************************************************************************
  // here goes code for audioprocessing
  if (listening) {
    fft.forward(source.mix);
    fftFunctions();
  }

  // ***************************************************************************
  // execute misc functions
  showUI(20, 40, 32, 50); // (int x, int y, int txtSize, int distance)

  // Open Sound Control
  oscOut();
  showGraph();
  showWave(100);
}


// --   AUDIO FUNCTIONS   ------------------------------------------------------

void fftFunctions() {
  sp.fillArray();
  sp.normalizeArray();
  sp.setMax();
  sp.smoothData();
}

// --   OSC FUNCTIONS   ------------------------------------------------------

void oscOut() {
  OscMessage msg = new OscMessage("/oscmsg");
  float amp = sp.smAmp;
  float freq = sp.getMaxFreq();

  msg.add(freq);
  msg.add(amp);
  osc.send(msg, sc);
  msg.clear();
}


// --   CORE FUNCTIONS   -------------------------------------------------------

void showUI(int x, int y, int size, int distance) {
  textSize(size);
  text(frameRate, x, y);
  text("Freq: " + sp.getMaxFreq(), x, y + distance);
  text("Amp: " + sp.smAmp, x, y + distance * 2);
  text("max Detect: " + sp.detectFreq, x, y + distance * 3);
  text("Smoothing: " + sp.smoothing, x, y + distance * 4);
}

void showWave(int scl) {
  for(int i = 0; i < source.bufferSize()/6 - 1; i++) {
    float x = map(i, 0, source.bufferSize()/6-1, 0, width);
    line( x, height/3 + source.mix.get(i) * scl, x+1, height/3 + source.mix.get(i+1) * scl);
  }
}

void showGraph() {
  for (int i = 0; i < fft.avgSize(); i++) {
    float x = map(i, 0, fft.avgSize(), 0, width);
    float w = width / fft.avgSize();
    rect(x, height, w, -fft.getAvg(i)*2);
  }
}

void initMinim() {
  minim = new Minim(this);
  source = minim.getLineIn(Minim.STEREO, 1024);
  fft = new FFT(source.bufferSize(), source.sampleRate()/2);
  fft.logAverages(32, 12);
  fft.window(windowFunction);
}

void stop() {
  source.close();
  minim.stop();
  super.stop();
}
