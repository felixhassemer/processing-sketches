// IMPORT THE LIBRARIES
import spout.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import de.looksgood.ani.*;

import themidibus.*;

// MINIM variables
Minim minim;
AudioInput source;
FFT fftLog;
WindowFunction myWindow = FFT.NONE;

// LOGARITHMIC GRAPH of fft
LogGraph log;

// INDICATORS
Indicator bassRange;       Indicator midRange;   Indicator trebleRange;

// Indicator settings
float bassSense = 0.5;     int bassLowT = 1;     int bassHighT = 6;    int bassThresh = 2;
float midSense = 0.25;     int midLowT = 8;      int midHighT = 14;    int midThresh = 4;
float trebleSense = 0.15;  int trebleLowT = 15;  int trebleHighT = 25; int trebleThresh = 4;

// SPOUT variables
int nSenders = 3;
PGraphics[] canvas;
Spout[] senders;

// MIDI bus
MidiBus bus;
float[] cc =      new float[10];
boolean[] pads =  new boolean[50];
boolean[] keys =  new boolean[128];

// COLOR variables
color cBgnd = color(0);
int r = 255; int g = 255; int b = 255;
color cOne = color(r, g, b);
boolean colorSwitch = true;
int weight = 10;

int[] triCenter = new int[2];
// array for triangle corner positions after translation
int[][] triCorners = { {-300, 200}, {0, -400}, {300, 200} };

// CHOOSE variables
int chooseOne = 0; int chooseTwo = 0; int chooseThree = 0;

// ANIMATION variables
float x1 = -300;
// Arraylists :
ArrayList<Triangle> triangles;    ArrayList<Circle> circles;    ArrayList<SideLine> sideLines;

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
  minim =       new Minim(this);
  source =      minim.getLineIn(Minim.STEREO, 1024);
  fftLog =      new FFT(source.bufferSize(), source.sampleRate());
  bassRange =   new Indicator(width/3 + 100, 700, 150, color(128), color(255));
  midRange =    new Indicator(bassRange.x + bassRange.diameter/2, 700, 100, color(80), color(255));
  trebleRange = new Indicator(midRange.x + midRange.diameter/2, 700, 50, color(30), color(255));
  log =         new LogGraph(fftLog, color(128), color(0, 200, 0), color(200, 0, 0));

  // List all Midi devices
  MidiBus.list();
  bus = new MidiBus(this, 0, 5);

  // initialize Ani
  Ani.init(this);

  // animation objects
  triangles = new ArrayList<Triangle>();
  circles = new ArrayList<Circle>();
  sideLines = new ArrayList<SideLine>();

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

  // check midi signals
  midiControl();

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

  // start drawing on senders
  senderDraw();

  // translate to the centroids instead of canvas center
  senderTranslate();

  // space for animations
  // ----------------------------------------------------------------------
  if (bassRange.beat) colorSwitch = !colorSwitch;
  // circleZoom(2);
  // triangleZoom(0);
  // linesToCenter(1);
  //
  // moveLine(1, bassRange);
  chooseAnimation();

  // flashColor(0, bassRange, color(255));
  // flashColor(1, midRange, color(255));
  // flashColor(2, trebleRange, color(255));

  // ----------------------------------------------------------------------

  triangleOutlines(color(255));
  // send frames to spout and end drawing
  senderEnd();
}

/////////////////////////////  VISUALS  ///////////////////////////////////

void chooseAnimation() {
  int functionCount = 4;
  if (bassRange.beatCount % 32 == 0) {
    chooseOne = round(random(functionCount));
    chooseTwo = round(random(functionCount));
    chooseThree = round(random(functionCount));
  }

  // choose Animation for Canvas One
  if (chooseOne == 0) {
    flashColor(0, bassRange, cOne);
  } else if (chooseOne == 1) {
    circleZoom(0, bassRange, cOne);
  } else if (chooseOne == 2) {
    triangleZoom(0, bassRange, cOne);
  } else if (chooseOne == 3) {
    linesToCenter(0, trebleRange, cOne);
  } else if (chooseOne == 4) {
    moveLine(0, bassRange, cOne, weight);
  }

  // choose Animation for Canvas Two
  if (chooseTwo == 0) {
    flashColor(1, midRange, cOne);
  } else if (chooseTwo == 1) {
    circleZoom(1, bassRange, cOne);
  } else if (chooseTwo == 2) {
    triangleZoom(1, bassRange, cOne);
  } else if (chooseTwo == 3) {
    linesToCenter(1, trebleRange, cOne);
  } else if (chooseTwo == 4) {
    moveLine(1, bassRange, cOne, weight);
  }

  // choose Animation for Canvas Three
  if (chooseThree == 0) {
    flashColor(2, trebleRange, cOne);
  } else if (chooseThree == 1) {
    circleZoom(2, bassRange, cOne);
  } else if (chooseThree == 2) {
    triangleZoom(2, bassRange, cOne);
  } else if (chooseThree == 3) {
    linesToCenter(2, trebleRange, cOne);
  } else if (chooseThree == 4) {
    moveLine(2, bassRange, cOne, weight);
  }
}

void flashColor(int _canv, Indicator _range, color _col) {
  if (_range.beat) {
    canvas[_canv].fill(_col);
    canvas[_canv].noStroke();
    canvas[_canv].rect(-width/2, -height/2, width, height);
  }
}

void particleExplosion(int _canv, Indicator _range, color _col) {
  int canv = _canv;
  Indicator range = _range;
  color col = _col;
}

void linesToCenter(int _canv, Indicator _range, color _col) {
  int canv = _canv;
  Indicator range = _range;
  color col = _col;

  for (int i=0; i < sideLines.size(); i++) {
    SideLine s = sideLines.get(i);
    if (s.ani.isEnded()) {
      sideLines.remove(i);
    }
  }

  if (range.beat) {
    int rC1 = round(random(2));
    int rC2 = round(random(2));

    // Parameters:  PApplet Parent, int canv, floats x1, y2, x2, y2
    sideLines.add(new SideLine(this, canv,
                                triCorners[rC1][0], triCorners[rC1][1],
                                triCorners[rC2][0], triCorners[rC2][1]));
    int current = sideLines.size()-1;
    sideLines.get(current).move();
  }

  for (SideLine s : sideLines) {
    s.display();
  }
}

void triangleZoom(int _canv, Indicator _range, color _col) {
  int canv = _canv;
  Indicator range = _range;
  color col = _col;

  // delete objects if animation ended
  for (int i=0; i < triangles.size(); i++) {
    Triangle t = triangles.get(i);
    if (t.ani.isEnded()) {
      triangles.remove(i);
    }
  }

  if (range.beat) {
    // Parameters:  int canv, floats x, y, diameter, boolean colortoggle
    triangles.add(new Triangle(canv, 0, -100, 1, colorSwitch));
    int current = triangles.size()-1;
    triangles.get(current).flipColor();
    triangles.get(current).grow();
  }

  for (Triangle t : triangles) {
    t.display();
  }
}

void circleZoom(int _canv, Indicator _range, color _col) {
  int canv = _canv;
  Indicator range = _range;
  color col = _col;

  // delete objects if animation ended
  for (int i=0; i < circles.size(); i++) {
    Circle c = circles.get(i);
    if (c.ani.isEnded()) {
      circles.remove(i);
    }
  }

  if (range.beat) {
    // Parameters:  int canv, floats x, y, diameter, boolean colortoggle
    circles.add(new Circle(canv, 0, -20, 1, colorSwitch));
    int current = circles.size()-1;
    circles.get(current).flipColor();
    circles.get(current).grow();
  }

  for (Circle c : circles) {
    c.display();
  }
}

void moveLine(int _canv, Indicator _range, color _col, int _sWeight) {
  int canv = _canv;
  Indicator range = _range;
  color col = _col;
  int sWeight = _sWeight;

  if (range.beatCount % 8 == 0) {
    float rotation;
    rotation = random(0, PI);
    canvas[canv].rotate(rotation);
  }
  if (range.beat) {
    if (x1 < 0) {
      Ani.to(this, 0.5, "x1", 300);
    } else {
      Ani.to(this, 0.5, "x1", -300);
    }
  }
  canvas[_canv].strokeWeight(10);
  canvas[_canv].stroke(col);
  canvas[_canv].line(x1, -height/2, x1, height/2);
}

/////////////////////////////  MIDI CONTROLS  ////////////////////////////////////

void midiControl() {
  // change range parameters by pressing pad + knobs
  if (pads[40]) {                                         // pad 5
    bassLowT = int(map(cc[1], 0, 1, 0, 10));                          // knob 1
    bassHighT = int(map(cc[2], 0, 1, 6, 16));                         // knob 2
    bassThresh = int(map(cc[3], 0, 1, 1, bassHighT-bassLowT));        // knob 3
    bassSense = cc[4];                                                // knob 4
    println("-----------------------------------------");
    println("bass low threshold: " + bassLowT);
    println("bass high threshold: " + bassHighT);
    println("bass threshold: " + bassThresh);
    println("sensitivity: " + bassSense);
  } else if (pads[41]) {                                  // pad 6
    midLowT = int(map(cc[1], 0, 1, 8, 16));                           // knob 1
    midHighT = int(map(cc[2], 0, 1, 12, 22));                         // knob 2
    midThresh = int(map(cc[3], 0, 1, 1, midHighT-midLowT));           // knob 3
    midSense = cc[4];                                                 // knob 4
    println("-----------------------------------------");
    println("mid low threshold: " + midLowT);
    println("mid high threshold: " + midHighT);
    println("mid threshold: " + midThresh);
    println("sensitivity: " + midSense);
  } else if (pads[42]) {                                   // pad 7
    trebleLowT = int(map(cc[1], 0, 1, 16, 26));                       // knob 1
    trebleHighT = int(map(cc[2], 0, 1, 20, 30));                      // knob 2
    trebleThresh = int(map(cc[3], 0, 1, 1, trebleHighT-trebleLowT));  // knob 3
    trebleSense = cc[4];                                              // knob 4
    println("-----------------------------------------");
    println("treble low threshold: " + trebleLowT);
    println("treble high threshold: " + trebleHighT);
    println("treble threshold: " + trebleThresh);
    println("sensitivity: " + trebleSense);
  }

  // change colors with knobs
  r = int(cc[5]*255);
  g = int(cc[6]*255);
  b = int(cc[7]*255);
  cOne = color(r, g, b);
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
  bassRange.setRange(bassLowT, bassHighT, bassThresh);
  bassRange.isBeat(fftLog, bassSense, 200);
  bassRange.display();

  midRange.setRange(midLowT, midHighT, midThresh);
  midRange.isBeat(fftLog, midSense, 100);
  midRange.display();

  trebleRange.setRange(trebleLowT, trebleHighT, trebleThresh);
  trebleRange.isBeat(fftLog, trebleSense, 100);
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
    canvas[i].pushMatrix();
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
    // popmatrix so the translation doesn't affect the triangle outlines
    canvas[i].popMatrix();

    // draw triangle outlines
    canvas[i].strokeWeight(1);
    canvas[i].stroke(triColor);
    canvas[i].noFill();
    canvas[i].triangle(0, canvas[i].height-1,
                      canvas[i].width/2, 1,
                      canvas[i].width, canvas[i].height-1);
  }
}

// MIDI functions
void noteOn(int channel, int pitch, int velocity) {
  // Receive a noteOn
  // println();
  // println("--------");
  // println("Note On:");
  // println("Channel:"+channel);
  // println("Pitch:"+pitch);
  // println("Velocity:"+velocity);

  // put true in array if pad is pressed
  if (channel == 9) {
    pads[pitch] = true;
  }

  // put true in array if key is pressed
  if (channel == 0) {
    keys[pitch] = true;
  }
}

void noteOff(int channel, int pitch, int velocity) {
  // Receive a noteOff
  // println();
  // println("--------");
  // println("Note Off:");
  // println("Channel:"+channel);
  // println("Pitch:"+pitch);
  // println("Velocity:"+velocity);

  // put true in boolean array if pad is pressed
  if (channel == 9) {
    pads[pitch] = false;
  }

  // put true in array if key is pressed
  if (channel == 0) {
    keys[pitch] = true;
  }
}

void controllerChange(int channel, int number, int value) {
  // Receive a controllerChange
  // println();
  // println("--------");
  // println("Controller Change:");
  // println("Channel:"+channel);
  // println("Number:"+number);
  // println("Value:"+value);

  // put all normalized values in cc array
  cc[number] = norm(value, 0, 127);
}

// close minim and midibus
void stop() {
  source.close();
  minim.stop();
  bus.dispose();
  super.stop();
}
