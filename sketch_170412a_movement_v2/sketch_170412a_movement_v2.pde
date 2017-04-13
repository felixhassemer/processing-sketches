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
Spout[] senders;
color[] colors;

// COLOR variables
color cBgnd = color(0);

int[] triCenter = new int[2];
// ANIMATION variables
MovingLine[] lines = new MovingLine[512];

/////////////////////////////  SETUP  ///////////////////////////////////
void setup() {
  // windowsize
  size(1800, 800, P2D);

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

  // set up Minim and Audio In
  minim = new Minim(this);
  source = minim.getLineIn(Minim.STEREO, 1024);
  fftLog = new FFT(source.bufferSize(), source.sampleRate());
  bassRange = new Indicator(width/3 + 100, 700, 150, color(128), color(255));
  midRange = new Indicator(bassRange.x + bassRange.diameter/2, 700, 100, color(80), color(255));
  trebleRange = new Indicator(midRange.x + midRange.diameter/2, 700, 50, color(30), color(255));
  log = new LogGraph(fftLog, color(128), color(0, 200, 0), color(200, 0, 0));



  // calculate centroids to translate to
  triCenter = centroid(0, canvas[0].height,
                      canvas[0].width/2, 0,
                      canvas[0].width, canvas[0].height);


  // apply fft window and calculate logarithmic averages
  fftLog.window(myWindow);
  fftLog.logAverages(120, 12);

  // set position and size of the fft graph
  log.setPosition(0, height);
  log.setSize(width/3, height-width/3);
}

/////////////////////////////  DRAW  ///////////////////////////////////
void draw() {
  background(cBgnd);

  // forward source to fft
  fftLog.forward(source.mix);

  // execute beat detection functions
  detection();

  // display the ranges and color them
  log.getAmps();
  log.display();
  log.display(bassRange);
  log.display(midRange);
  log.display(trebleRange);

  // start drawing on senders and draw triangle outline
  senderDraw();
  triangleOutlines(color(255));

  // translate to the centroids instead of canvas center
  senderTranslate();

  // space for animations
  // ----------------------------------------------------------------------
  if (bassRange.beat) {
    lines[bassRange.beatCount] = new MovingLine(bassRange, 500, color(255), 2.0, 2.0);
  }
  for (int i=0; i =< bassRange.beatCount; i++) {
    lines[i].move();
    lines[i].display();

  }


  if (midRange.beat) {
    canvas[1].fill(255);
    canvas[1].noStroke();
    canvas[1].rect(-width/2, -height/2, width, height);
  }

  if (trebleRange.beat) {
    canvas[2].fill(255);
    canvas[2].noStroke();
    canvas[2].rect(-width/2, -height/2, width, height);
  }







  // ----------------------------------------------------------------------

  // send frames to spout and end drawing
  senderEnd();
}

/////////////////////////////  VISUALS  ///////////////////////////////////

class MovingLine {
  float x, y;
  float sWeight;
  color cStroke;
  float incr;
  float scale;
  Indicator indicator;
  boolean moving;
  float max;

  MovingLine(Indicator _indicator, float _scale, color _cStroke, float _sWeight, float _incr) {
    cStroke = _cStroke;
    sWeight = _sWeight;
    incr = _incr;
    scale = _scale;
    indicator = _indicator;
    max = indicator.beatSize;
    y = 0;
    moving = true;
  }

  void move() {
    if (y < max*scale) {
      y += incr;
    }
  }

  void display() {
    stroke(cStroke);
    strokeWeight(sWeight);
    noFill();
    line(0, y, width, 0);
  }
}

/////////////////////////////  CORE FUNCTIONS  ///////////////////////////////////

// centroid of three points
int[] centroid(int x1, int y1, int x2, int y2, int x3, int y3) {
  int x = int((x1 + x2 + x3)/3);
  int y = int((y1 + y2 + y3)/3);
  int[] centerPoint = {x, y};
  return centerPoint;
}

// midpoint of two points
int[] midPoint(int x1, int y1, int x2, int y2) {
  int x = int((x1 + x2)/2);
  int y = int((y1 + y2)/2);
  int[] midPoint = {x, y};
  return midPoint;
}

void detection() {
  bassRange.setRange(0, 6, 3);
  bassRange.isBeat(fftLog, 0.45, 200);
  bassRange.display();

  midRange.setRange(9, 16, 4);
  midRange.isBeat(fftLog, 0.25, 100);
  midRange.display();

  trebleRange.setRange(20, 26, 2);
  trebleRange.isBeat(fftLog, 0.1, 100);
  trebleRange.display();
}

void senderDraw() {
  for (int i=0; i < nSenders; i++) {
    canvas[i].beginDraw();
    canvas[i].background(cBgnd);
  }
}

void senderTranslate() {
  for (int i=0; i < nSenders; i++) {
    canvas[i].translate(triCenter[0], triCenter[1]);
  }
}

void senderEnd() {
  for (int i = 0; i < nSenders; i++) {
    canvas[i].endDraw();
    senders[i].sendTexture(canvas[i]);
    image(canvas[i], (width/3)*i, 0);
  }
}

void triangleOutlines(color triColor) {
  for (int i=0; i < nSenders; i++) {
    // draw triangle outlines
    canvas[i].stroke(triColor);
    canvas[i].noFill();
    canvas[i].triangle(0, canvas[i].height-1,
                      canvas[i].width/2, 1,
                      canvas[i].width, canvas[i].height-1);
  }
}
