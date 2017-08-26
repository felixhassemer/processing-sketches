// IMPORT libraries
import spout.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import oscP5.*;
import netP5.*;

// VARIABLES *****************************************************
Spout sender;   boolean sendFrames = false;
Minim minim;    AudioInput source;    FFT fft;    WindowFunction windowFunction = FFT.HANN;
SoundProcessor sp;
boolean listening = true;

// samples
int sampNum = 35;   // total number of loaded samples
int toneRange = 24; // in semitones

// SUPERCOLLIDER COMMUNICATION
OscP5 osc;
NetAddress sc, ls;



// --   SETUP    ---------------------------------------------------------------
void setup() {
  size(1280, 960, P2D);
  background(0);

  // init Spout
  if (sendFrames) {
    sender = new Spout(this);
    sender.createSender("Spout Processing");
  }

  // init Minim
  if (listening) {
    initMinim();
    sp = new SoundProcessor(fft, source, 6, 800); // (fft, source, int smoothing, int maxDetectFrequency)
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
  if (sendFrames) sender.sendTexture(); // send out each frame to resolume
  showFrameRate(20, 40, 32);  // (x, y, size)
  showMaxFreq(20, 120, 32); // (x, y, size)

  // Open Sound Control
  oscOut();
}


// --   AUDIO FUNCTIONS   ------------------------------------------------------

void waveGraph(int scale) {
  stroke(255);
  strokeWeight(3);
  for (int i=0; i < source.bufferSize() - 1; i++) {
    float x = map(i, 0, source.bufferSize(), 0, width);
    line(x, height/2 + source.mix.get(i) * scale, x + 1, height/2 + source.mix.get(i + 1) * scale);
  }
}

void showMaxFreq(int x, int y, int size) {
  textSize(size);
  text(sp.getMaxFreq(), x, y);
}

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
  float freq = sp.smFreq;

  msg.add(freq);
  msg.add(amp);
  osc.send(msg, sc);
  msg.clear();
}


// --   CORE FUNCTIONS   -------------------------------------------------------

void showFrameRate(int x, int y, int size) {
  textSize(size);
  text(frameRate, x, y);
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
