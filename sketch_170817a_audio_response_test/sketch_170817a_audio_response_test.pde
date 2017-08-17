// IMPORT LIBRARIES
import ddf.minim.*;
import ddf.minim.analysis.*;


// MINIM variables
Minim minim;
AudioInput source;
FFT fft;
WindowFunction windowFunction = FFT.HANN;


// -----------------------------------------------------------------------------
void setup() {
  size(1000, 1000);
  frameRate(60);

  initMinim(); // Setup MINIM and initialize all MINIM objects
}

// -----------------------------------------------------------------------------
void draw() {
  translate(0, -100);
  background(0);
  stroke(255);
  noFill();


 // draw the waveforms
 for(int i = 0; i < source.bufferSize() - 1; i++) {
   line( i, height/3 + source.mix.get(i)*100, i+1, height/3 + source.mix.get(i+1)*100 );
 }

 // draw the FFT
 fft.forward(source.mix);
 for (int i = 0; i < fft.specSize(); i++) {
   float x = map(i, 0, fft.specSize()/2, 0, width);
   line(x, 2*height/3, x, 2*height/3 - fft.getBand(i));
 }

for (int i = 0; i < fft.avgSize(); i++) {
  float x = map(i, 0, fft.avgSize(), 0, width);
  float w = width / fft.avgSize();
  rect(x, height, w, -fft.getAvg(i));
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
