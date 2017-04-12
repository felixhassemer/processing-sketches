// IMPORT THE LIBRARIES
import spout.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

// MINIM variables
Minim minim;
AudioInput source;
FFT fftLog;
WindowFunction myWindow = FFT.NONE;

// LOGARITHMIC GRAPH of fft
LogGraph log;

// INDICATORS
Indicator bassRange;
Indicator midRange;
Indicator trebleRange;

// SPOUT variables
int nSenders = 3;
PGraphics[] canvas;
PGraphics graph;
Spout[] senders;
color[] colors;

// COLOR variables
color cBgnd = color(0);
color cGraph = color(255);
color cBandRange = color(0, 200, 0);
color cActiveBand = color(255, 0, 0);

/////////////////////////////  SETUP  ///////////////////////////////////
void setup() {
  // windowsize
  size(1800, 800, P3D);

  // size of spout senders
  canvas = new PGraphics[nSenders];
  for (int i = 0; i < nSenders; i++) {
    canvas[i] = createGraphics(width/3, width/3);
  }

  // Create Spout senders to send frames out.
  senders = new Spout[nSenders];
  for (int i = 0; i < nSenders; i++) {
    senders[i] = new Spout(this);
    String sendername = "Processing Spout"+i;
    senders[i].createSender(sendername, width/3, width/3);
  }

  // size of graph
  graph = createGraphics(width, height-width/3, P2D);

  // set up Minim and Audio In
  minim = new Minim(this);
  source = minim.getLineIn(Minim.STEREO, 1024);
  fftLog = new FFT(source.bufferSize(), source.sampleRate());
  bassRange = new Indicator(width/3 + 100, 700, 150, color(128), color(255));
  midRange = new Indicator(bassRange.x + bassRange.diameter/2, 700, 100, color(80), color(255));
  trebleRange = new Indicator(midRange.x + midRange.diameter/2, 700, 50, color(30), color(255));
  log = new LogGraph(fftLog);

  fftLog.window(myWindow);
  fftLog.logAverages(120, 12);

  log.setPosition(0, height);
  log.setSize(width/3, height-width/3);
}


/////////////////////////////  DRAW  ///////////////////////////////////
void draw() {
  background(cBgnd);

  // forward source to fft
  fftLog.forward(source.mix);

  // execute beat detection functions
  bassRange.setRange(0, 5, 3);
  bassRange.isBeat(fftLog, 0.3, 450);
  bassRange.display();
  // println(bassRange.beatCount);

  midRange.setRange(7, 15, 3);
  midRange.isBeat(fftLog, 0.22, 100);
  midRange.display();

  trebleRange.setRange(20, 26, 2);
  trebleRange.isBeat(fftLog, 0.1, 100);
  trebleRange.display();

  log.display(bassRange);
  log.display(midRange);
  log.display(trebleRange);

  // start drawing on senders
  for (int i=0; i < nSenders; i++) {
    canvas[i].beginDraw();
    canvas[i].background(cBgnd);
    canvas[i].translate(canvas[i].width/2, canvas[i].height/2);
  }

  // draw triangle outline
  for (int i=0; i < nSenders; i++) {
    canvas[i].stroke(255);
    canvas[i].noFill();
    canvas[i].triangle(-canvas[i].width/2, canvas[i].height/2-1,
      0, -canvas[i].height/2,
      canvas[i].width/2, canvas[i].height/2-1);
  }

  // space for animations on canvases
  // ----------------------------------------------------------------------

  anim1();
  anim2();
  anim3();



  // ----------------------------------------------------------------------

  // send frames to spout and end drawing
  for (int i = 0; i < nSenders; i++) {
    canvas[i].endDraw();
    senders[i].sendTexture(canvas[i]);
    image(canvas[i], (width/3)*i, 0);
  }
}

/////////////////////////////  VISUALS  ///////////////////////////////////

void anim1() {
  if (bassRange.beat) {
    canvas[0].scale(canvas[0].width/2);
    canvas[0].fill(255);
    canvas[0].noStroke();
    canvas[0].triangle(-1, 1,
                      0, -1,
                      1, 1);
  }
}

void anim2() {
  float ellipseSize = map(midRange.fft.getAvg(10), 0, 300, 0, 1) * 600;
  canvas[1].fill(255);
  canvas[1].noStroke();
  canvas[1].ellipse(0, 50, ellipseSize, ellipseSize);
}

void anim3() {
  if (trebleRange.beat) {
    canvas[2].scale(canvas[0].width/2);
    canvas[2].fill(255);
    canvas[2].noStroke();
    canvas[2].triangle(-1, 1,
                      0, -1,
                      1, 1);
  }
}
