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
float[]   cc =    new float[10];
boolean[] pads =  new boolean[50];
boolean[] keys =  new boolean[128];

// COLOR variables
color cBgnd = color(0);
color cOne;
boolean colorSwitch = true;
float hueNoise = 0; float hueIncr = 0.002;
float satNoise = 9872; float satIncr = 0.005;
int weight = 10;

int[] triCenter = new int[2];
int[] rectCenter = new int[2];
// array for triangle corner positions after translation
int[][] triCorners = { {-300, 200}, {0, -400}, {300, 200} };

// CHOOSE variables
int[] choose = new int[3];

// ANIMATION variables
float x1 = -300;
// Arraylists :
ArrayList<Triangle> triangles;    ArrayList<Circle> circles;
ArrayList<SideLine> sideLines;    ArrayList<Particle> particles;

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
  midRange =    new Indicator(bassRange.x + bassRange.diam/2, 700, 100, color(80), color(255));
  trebleRange = new Indicator(midRange.x + midRange.diam/2, 700, 50, color(30), color(255));
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
  particles = new ArrayList<Particle>();

  // calculate centroids to translate to
  triCenter = centroid(0, canvas[0].height,
                      canvas[0].width/2, 0,
                      canvas[0].width, canvas[0].height);
  rectCenter = centroid(0, 0, canvas[0].width, canvas[0].height);

  // apply fft window and calculate logarithmic averages
  fftLog.window(myWindow);
  fftLog.logAverages(120, 12);

  // set position and size of the fft graph
  log.setPosition(0, height);
  log.setSize(width/3, height-width/3);

  colorMode(HSB, 360, 100, 100);
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

  // change RGB colors
  chooseColors();

  // space for animations
  // ----------------------------------------------------------------------
  if (bassRange.beat) colorSwitch = !colorSwitch;

  // randomly choose new Animation for each canvas every x beats
  chooseAnimation();

  // remove all objects that have finished their animation
  removeObjects();
  // ----------------------------------------------------------------------

  outlines(color(255), 10);
  // send frames to spout and end drawing
  senderEnd();
}

/////////////////////////////  VISUALS  ///////////////////////////////////

void chooseAnimation() {
  int functionCount = 8;
  if (bassRange.beatCount % 16 == 0) {
    choose[0] = round(random(functionCount));
    choose[1] = round(random(functionCount));
    choose[2] = round(random(functionCount));
  }

  // choose Animation for Canvas One
  if (choose[0] == 0) {
    flashColor(0, bassRange, cOne);
  } else if (choose[0] == 1) {
    circleZoomFill(0, bassRange, cOne);
  } else if (choose[0] == 2) {
    // triangleZoomFill(0, bassRange, cOne);
  } else if (choose[0] == 3) {
    linesToCenter(0, trebleRange, cOne);
  } else if (choose[0] == 4) {
    moveLine(0, bassRange, cOne, weight);
  } else if (choose[0] == 5) {
    particleStream(0, trebleRange, cOne);
  } else if (choose[0] == 6) {
    particleExplosion(0, bassRange, cOne);
  } else if (choose[0] == 7) {
    // triangleZoomStroke(0, bassRange, cOne);
  } else if (choose[0] == 8) {
    circleZoomStroke(0, bassRange, cOne);
  }

  // choose Animation for Canvas Two
  if (choose[1] == 0) {
    flashColor(1, midRange, cOne);
  } else if (choose[1] == 1) {
    circleZoomFill(1, bassRange, cOne);
  } else if (choose[1] == 2) {
    // triangleZoomFill(1, bassRange, cOne);
  } else if (choose[1] == 3) {
    linesToCenter(1, trebleRange, cOne);
  } else if (choose[1] == 4) {
    moveLine(1, bassRange, cOne, weight);
  } else if (choose[1] == 5) {
    particleStream(1, bassRange, cOne);
  } else if (choose[1] == 6) {
    particleExplosion(1, midRange, cOne);
  } else if (choose[1] == 7) {
    // triangleZoomStroke(1, trebleRange, cOne);
  } else if (choose[1] == 8) {
    circleZoomStroke(1, bassRange, cOne);
  }

  // choose Animation for Canvas Three
  if (choose[2] == 0) {
    flashColor(2, trebleRange, cOne);
  } else if (choose[2] == 1) {
    circleZoomFill(2, bassRange, cOne);
  } else if (choose[2] == 2) {
    triangleZoomFill(2, bassRange, cOne);
  } else if (choose[2] == 3) {
    linesToCenter(2, trebleRange, cOne);
  } else if (choose[2] == 4) {
    moveLine(2, bassRange, cOne, weight);
  } else if (choose[2] == 5) {
    particleStream(2, bassRange, cOne);
  } else if (choose[2] == 6) {
    particleExplosion(2, midRange, cOne);
  } else if (choose[2] == 7) {
    triangleZoomStroke(2, trebleRange, cOne);
  } else if (choose[2] == 8) {
    circleZoomStroke(2, bassRange, cOne);
  }
}

void chooseColors() {
  int h, s, b;
  h = int(map(noise(hueNoise), 0, 1, -60, 420));
  h = constrain(h, 0, 360);
  s = int(map(noise(satNoise), 0, 1, -20, 120));
  s = constrain(s, 0, 100);
  b = 100;
  hueNoise += hueIncr;
  satNoise += satIncr;
  cOne = color(h, s, b);
  // println(h, s);
}

void removeObjects() {
  // delete objects if animation ended
  // remove PARTICLE
  for (int i=0; i < particles.size(); i++) {
    Particle p = particles.get(i);
    if (p.ani.isEnded()) {
      particles.remove(i);
    }
  }
  // remove SIDELINE
  for (int i=0; i < sideLines.size(); i++) {
    SideLine s = sideLines.get(i);
    if (s.ani.isEnded()) {
      sideLines.remove(i);
    }
  }
  // remove TRIANGLE
  for (int i=0; i < triangles.size(); i++) {
    Triangle t = triangles.get(i);
    if (t.ani.isEnded()) {
      triangles.remove(i);
    }
  }
  // remove CIRCLE
  for (int i=0; i < circles.size(); i++) {
    Circle c = circles.get(i);
    if (c.ani.isEnded()) {
      circles.remove(i);
    }
  }
}

void flashColor(int _canv, Indicator _range, color _col) {
  if (_range.beat) {
    canvas[_canv].fill(_col);
    canvas[_canv].noStroke();
    canvas[_canv].rect(-width/2, -height/2, width, height);
  }
}

void particleStream(int _canv, Indicator _range, color _col) {
  int canv = _canv;
  Indicator range = _range;
  color col = _col;

  if (range.beat) {
    int particleCount = int(map(range.beatSize, 0, 1, 0, 100));
    for (float i=0; i <= particleCount; i++) {
      float a = random(0, TWO_PI);
      particles.add(new Particle(this, canv, a, 0, cOne));
      int current = particles.size()-1;
      particles.get(current).move();
    }
  }

  for (Particle p : particles) {
    p.polar();
    p.display();
  }
}

void particleExplosion(int _canv, Indicator _range, color _col) {
  int canv = _canv;
  Indicator range = _range;
  color col = _col;

  if (range.beat) {
    int particleCount = int(random(4, 30));
    for (float a=0; a < TWO_PI; a += TWO_PI/particleCount) {
      // Parameters:  PApplet Parent, int canv, floats a, r, color col
      particles.add(new Particle(this, canv, a, 0, cOne));
      int current = particles.size()-1;
      particles.get(current).moveInverse();
    }
  }

  for (Particle p : particles) {
    p.polar();
    p.display();
  }
}

void linesToCenter(int _canv, Indicator _range, color _col) {
  int canv = _canv;
  Indicator range = _range;
  color col = _col;

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

void triangleZoomFill(int _canv, Indicator _range, color _col) {
  int canv = _canv;
  Indicator range = _range;
  color col = _col;

  if (range.beat) {
    // Parameters:  int canv, floats x, y, diameter, boolean colortoggle
    triangles.add(new Triangle(canv, 0, -100, 1, colorSwitch, 0));
    int current = triangles.size()-1;
    triangles.get(current).flipColor();
    triangles.get(current).grow();
  }

  for (Triangle t : triangles) {
    t.display();
  }
}

void triangleZoomStroke(int _canv, Indicator _range, color _col) {
  int canv = _canv;
  Indicator range = _range;
  color col = _col;

  if (range.beat) {
    // Parameters:  int canv, floats x, y, diameter, boolean colortoggle
    triangles.add(new Triangle(canv, 0, -100, 1, false, 5));
    int current = triangles.size()-1;
    triangles.get(current).grow();
  }

  for (Triangle t : triangles) {
    t.display();
  }
}

void circleZoomFill(int _canv, Indicator _range, color _col) {
  int canv = _canv;
  Indicator range = _range;
  color col = _col;

  if (range.beat) {
    // Parameters:  int canv, floats x, y, diameter, boolean colortoggle
    circles.add(new Circle(canv, 0, 0, 1, colorSwitch, 0));
    int current = circles.size()-1;
    circles.get(current).flipColor();
    circles.get(current).grow();
  }

  for (Circle c : circles) {
    c.display();
  }
}

void circleZoomStroke(int _canv, Indicator _range, color _col) {
  int canv = _canv;
  Indicator range = _range;
  color col = _col;

  if (range.beat) {
    // Parameters:  int canv, floats x, y, diameter, boolean colortoggle, float weight
    circles.add(new Circle(canv, 0, 0, 1, false, 5));
    int current = circles.size()-1;
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
  canvas[canv].strokeWeight(10);
  canvas[canv].stroke(col);
  canvas[canv].line(x1, -height/2, x1, height/2);
}

/////////////////////////////  MIDI CONTROLS  ////////////////////////////////////

void midiControl() {
  // change range parameters by pressing pad + knobs
  if (pads[40]) {                                         // pad 5
    bassLowT = int(map(cc[1], 0, 1, 0, 15));                          // knob 1
    bassHighT = int(map(cc[2], 0, 1, 6, 30));                         // knob 2
    bassThresh = int(map(cc[3], 0, 1, 1, bassHighT-bassLowT));        // knob 3
    bassSense = cc[4];                                                // knob 4
    println("-----------------------------------------");
    println("bass low threshold: " + bassLowT);
    println("bass high threshold: " + bassHighT);
    println("bass threshold: " + bassThresh);
    println("sensitivity: " + bassSense);
  } else if (pads[41]) {                                  // pad 6
    midLowT = int(map(cc[1], 0, 1, 8, 25));                           // knob 1
    midHighT = int(map(cc[2], 0, 1, 10, 35));                         // knob 2
    midThresh = int(map(cc[3], 0, 1, 1, midHighT-midLowT));           // knob 3
    midSense = cc[4];                                                 // knob 4
    println("-----------------------------------------");
    println("mid low threshold: " + midLowT);
    println("mid high threshold: " + midHighT);
    println("mid threshold: " + midThresh);
    println("sensitivity: " + midSense);
  } else if (pads[42]) {                                   // pad 7
    trebleLowT = int(map(cc[1], 0, 1, 12, 30));                       // knob 1
    trebleHighT = int(map(cc[2], 0, 1, 14, 45));                      // knob 2
    trebleThresh = int(map(cc[3], 0, 1, 1, trebleHighT-trebleLowT));  // knob 3
    trebleSense = cc[4];                                              // knob 4
    println("-----------------------------------------");
    println("treble low threshold: " + trebleLowT);
    println("treble high threshold: " + trebleHighT);
    println("treble threshold: " + trebleThresh);
    println("sensitivity: " + trebleSense);
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

// centroid of rectangle
int[] centroid(int x1, int y1, int w1, int h1) {
  int x = int((x1 + w1)/2);
  int y = int((y1 + h1)/2);
  int [] centerPoint = {x, y};
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
    if (i == 2) {
      canvas[i].translate(triCenter[0], triCenter[1]);
    } else {
      canvas[i].translate(rectCenter[0], rectCenter[1]);
    }
  }
}

void senderEnd() {
  for (int i = 0; i < nSenders; i++) {
    canvas[i].endDraw();
    senders[i].sendTexture(canvas[i]);
    image(canvas[i], (width/3)*i, 0);
  }
}

void outlines(color cOutlines, int outlineWeight) {
  int outlineOff = outlineWeight / 2;
  for (int i=0; i < nSenders; i++) {
    // popmatrix so the translation doesn't affect the triangle outlines
    canvas[i].popMatrix();

    // draw triangle outlines
    canvas[i].strokeWeight(outlineWeight);
    canvas[i].stroke(cOutlines);
    canvas[i].noFill();
    canvas[i].rect(outlineOff, outlineOff, canvas[i].width-outlineOff*2, canvas[i].height-outlineOff*2);
  }
  canvas[2].triangle(outlineOff, canvas[2].height-outlineOff,
    canvas[2].width/2, outlineOff,
    canvas[2].width-outlineOff, canvas[2].height-outlineOff);
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
