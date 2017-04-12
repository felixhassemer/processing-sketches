// GLOBAL VARS
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput source;
FFT fftLog;
WindowFunction myWindow = FFT.NONE;
LogGraph log;

Indicator bassRange;
Indicator midRange;
Indicator trebleRange;

color cBgnd = color(0);
color cGraph = color(255);
color cBandRange = color(0, 200, 0);
color cActiveBand = color(255, 0, 0);


void setup() {
  size(800, 800);

  minim = new Minim(this);
  source = minim.getLineIn(Minim.STEREO, 1024);
  fftLog = new FFT(source.bufferSize(), source.sampleRate());
  bassRange = new Indicator(width/3, height/2, 80, color(128), color(255));
  midRange = new Indicator(width/2, height/2, 50, color(80), color(255));
  trebleRange = new Indicator(2*width/3, height/2, 25, color(30), color(255));

  log = new LogGraph(fftLog);

  fftLog.window(myWindow);
  fftLog.logAverages(120,12);

  log.setPosition(0, height);
  log.setSize(width, height);
}

void draw() {
  background(cBgnd);

  fftLog.forward(source.mix);

  noStroke();
  bassRange.setRange(0, 6, 4);
  bassRange.isBeat(fftLog, 0.3);
  bassRange.display();

  midRange.setRange(9, 16, 3);
  midRange.isBeat(fftLog, 0.22);
  midRange.display();

  trebleRange.setRange(20, 26, 2);
  trebleRange.isBeat(fftLog, 0.1);
  trebleRange.display();

  log.display(bassRange);
  log.display(midRange);
  log.display(trebleRange);
}

// void keyReleased()
// {
//   if ( key == '1' )
//   {
//     myWindow = FFT.BARTLETT;
//   }
//   else if ( key == '2' )
//   {
//     myWindow = FFT.BARTLETTHANN;
//   }
//   else if ( key == '3' )
//   {
//     myWindow = FFT.BLACKMAN;
//   }
//   else if ( key == '4' )
//   {
//     myWindow = FFT.COSINE;
//   }
//   else if ( key == '5' )
//   {
//     myWindow = FFT.GAUSS;
//   }
//   else if ( key == '6' )
//   {
//     myWindow = FFT.HAMMING;
//   }
//   else if ( key == '7' )
//   {
//     myWindow = FFT.HANN;
//   }
//   else if ( key == '8' )
//   {
//     myWindow = FFT.LANCZOS;
//   }
//   else if ( key == '9' )
//   {
//     myWindow = FFT.TRIANGULAR;
//   }
//
//   fftLog.window( myWindow );
// }

void stop() {
  source.close();
  minim.stop();
  super.stop();
}
