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
float bassSense = 0.7;     int bassLowT = 1;     int bassHighT = 6;    int bassThresh = 2;
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
float hueNoise = 0; float hueIncr = 0.001;
float satNoise = 9872; float satIncr = 0.003;
int weight = 10;

int[] triCenter = new int[2];
int[] rectCenter = new int[2];
// array for triangle corner positions after translation
int[][] triCorners = new int[3][2];
int[][] rectCorners= new int[4][2];

// CHOOSE variables
int[] choose = new int[3];

// ANIMATION variables
float x1 = -300;
// Arraylists :
ArrayList<Triangle> triangles;    ArrayList<Circle> circles;
ArrayList<SideLine> sideLines;    ArrayList<Particle> particles;
ArrayList<Rectangle> rectangles;

// removal of animation objects
ArrayList toRemove;

/////////////////////////////  SETUP  ///////////////////////////////////
void setup() {
  // windowsize
  size(1200, 600, P2D);
  frameRate(24);

  // size of spout senders
  canvas = new PGraphics[nSenders];
  for (int i = 0; i < nSenders; i++) {
    canvas[i] = createGraphics(width/3, width/3);
  }

  // edge points of triangle and rectangles
  // x                                    // y
  rectCorners[0][0] = -canvas[0].width/2; rectCorners[0][1] = -canvas[0].height/2;
  rectCorners[1][0] = canvas[0].width/2;  rectCorners[1][1] = -canvas[0].height/2;
  rectCorners[2][0] = canvas[0].width/2;  rectCorners[2][1] = canvas[0].height/2;
  rectCorners[3][0] = -canvas[0].width/2; rectCorners[3][1] = canvas[0].height/2;

  triCorners[0][0] = -canvas[0].width/2;  triCorners[0][1] = canvas[0].height/2;
  triCorners[1][0] = 0;                   triCorners[1][1] = -canvas[0].height/2;
  triCorners[2][0] = canvas[0].width/2;   triCorners[2][1] = canvas[0].height/2;

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
  bassRange =   new Indicator(width/3 + 100, 500, 150, color(128), color(255));
  midRange =    new Indicator(bassRange.x + bassRange.diam/2, 500, 100, color(80), color(255));
  trebleRange = new Indicator(midRange.x + midRange.diam/2, 500, 50, color(30), color(255));
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
  rectangles = new ArrayList<Rectangle>();

  toRemove = new ArrayList();


  // calculate centroids
  triCenter = centroid(triCorners[0][0], triCorners[0][1],
                      triCorners[1][0], triCorners[1][1],
                      triCorners[2][0], triCorners[2][1]);
  rectCenter = centroid(0, 0, canvas[0].width, canvas[0].height);

  // apply fft window and calculate logarithmic averages
  fftLog.window(myWindow);
  fftLog.logAverages(120, 12);

  // set position and size of the fft graph
  log.setPosition(0, height);
  log.setSize(width/3, height-width/3);

  colorMode(HSB, 360, 100, 100, 100);
}

/////////////////////////////  DRAW  ///////////////////////////////////
void draw() {
  background(cBgnd);
  showFramerate();

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

  outlines(color(255), 0);
  // send frames to spout and end drawing
  senderEnd();
}

/////////////////////////////  VISUALS  ///////////////////////////////////

void chooseAnimation() {
  int functionCount = 9;
  if (bassRange.beatCount % 16 == 0) {
    choose[0] = round(random(functionCount));
    // choose[0] = 9;
    while (choose[1] == choose[0]) {                                // check again until other number
      choose[1] = round(random(functionCount));
    }
    // choose[1] = 9;
    // while ((choose[2] == choose[0]) || (choose[2] == choose[1])) {  // check again until other number
    //   choose[2] = round(random(functionCount));
    // }
    choose[2] = 2;
  }

  //  Animation for CANVAS ZERO
  if (choose[0] == 0) {
    flashColor(0, bassRange, cOne);
  } else if (choose[0] == 1) {
    circleZoom(0, bassRange, cOne, 0, false);     // fill
  } else if (choose[0] == 2) {
    rectLines(0, trebleRange, cOne);
  } else if (choose[0] == 3) {
    moveLine(0, bassRange, cOne, weight);
  } else if (choose[0] == 4) {
    particleSystem(0, trebleRange, cOne, "STREAM");
  } else if (choose[0] == 5) {
    particleSystem(0, bassRange, cOne, "EXPLOSION");
  } else if (choose[0] == 6) {
    rectZoom(0, midRange, cOne, 0, false);        // fill
  } else if (choose[0] == 7) {
    rectZoom(0, bassRange, cOne, 5, false);       // stroke
  } else if (choose[0] == 8) {
    circleZoom(0, bassRange, cOne, 5, false);     // stroke
  } else if (choose[0] == 9) {
    circleZoom(0, bassRange, cOne, 5, true);      // stroke + reverse
  }

  // Animation for CANVAS ONE
  if (choose[1] == 0) {
    flashColor(1, midRange, cOne);
  } else if (choose[1] == 1) {
    circleZoom(1, bassRange, cOne, 0, false);     // fill
  } else if (choose[1] == 2) {
    rectLines(1, midRange, cOne);
  } else if (choose[1] == 3) {
    moveLine(1, bassRange, cOne, weight);
  } else if (choose[1] == 4) {
    particleSystem(1, bassRange, cOne, "STREAM");
  } else if (choose[1] == 5) {
    particleSystem(1, midRange, cOne, "EXPLOSION");
  } else if (choose[1] == 6) {
    rectZoom(1, midRange, cOne, 0, false);        // fill
  } else if (choose[1] == 7) {
    rectZoom(1, bassRange, cOne, 5, false);       // stroke
  } else if (choose[1] == 8) {
    circleZoom(1, bassRange, cOne, 5, false);     // stroke
  } else if (choose[1] == 9) {
    circleZoom(1, bassRange, cOne, 5, true);      // stroke + reverse
  }

  // Animation for CANVAS TWO
  if (choose[2] == 0) {
    flashColor(2, trebleRange, cOne);
  } else if (choose[2] == 1) {
  } else if (choose[2] == 2) {
    triLines(2, bassRange, cOne);
  } else if (choose[2] == 3) {
    moveLine(2, bassRange, cOne, weight);
  } else if (choose[2] == 4) {
    particleSystem(2, bassRange, cOne, "STREAM");
  } else if (choose[2] == 5) {
    particleSystem(2, midRange, cOne, "EXPLOSION");
  } else if (choose[2] == 6) {
    triangleZoom(2, trebleRange, cOne, 5);        // with stroke
  } else if (choose[2] == 7) {
    triangleZoom(2, bassRange, cOne, 0);          // with fill
  } else if (choose[2] == 8) {
    circleZoom(2, bassRange, cOne, 5, false);     // with stroke
  } else if (choose[2] == 9) {
    circleZoom(2, bassRange, cOne, 5, true);      // stroke + reverse

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
}

void removeObjects() {
  // delete objects if animation ended
  // remove PARTICLE
  for (Particle p : particles) {
    if (p.ani.isEnded()) toRemove.add(p);
  }

  // remove SIDELINE
  for (SideLine s : sideLines) {
    if (s.ani.isEnded()) toRemove.add(s);
  }

  // remove TRIANGLE
  for (Triangle t : triangles) {
    if (t.ani.isEnded()) toRemove.add(t);
  }

  // remove CIRCLE
  for (Circle c : circles) {
    if (c.ani.isEnded()) toRemove.add(c);
  }

  // remove RECTANGLE
  for (Rectangle r : rectangles) {
    if (r.ani.isEnded()) toRemove.add(r);
  }

  // remove all objects that have finished animating
  particles.removeAll(toRemove);
  sideLines.removeAll(toRemove);
  triangles.removeAll(toRemove);
  circles.removeAll(toRemove);
  rectangles.removeAll(toRemove);
  // clear removal arraylist
  toRemove.clear();
}

void flashColor(int canv, Indicator range, color col) {
  if (range.beat) {
    canvas[canv].fill(col);
    canvas[canv].noStroke();
    canvas[canv].rect(-width/2, -height/2, width, height);
  }
}

void particleSystem(int canv, Indicator range, color col, String type) {
  if (range.beat) {
    if (type == "STREAM") {
      int particleCount = int(map(range.beatSize, 0, 1, 0, 40));
      for (float i=0; i <= particleCount; i++) {
        float a = random(0, TWO_PI);
        particles.add(new Particle(this, canv, a, 0, cOne));
        int current = particles.size()-1;
        particles.get(current).move();
      }
    } else if (type == "EXPLOSION") {
      int particleCount = int(random(4, 26));
      for (float a=0; a < TWO_PI; a += TWO_PI/particleCount) {
        // Parameters:  PApplet Parent, int canv, floats a, r, color col
        particles.add(new Particle(this, canv, a, 0, cOne));
        int current = particles.size()-1;
        particles.get(current).moveReverse();
      }
    } else {
      // error message
      println("animation type undefined");
    }
  }

  for (Particle p : particles) {
    p.polar();
    p.display();
  }
}

void triLines(int canv, Indicator range, color col) {
  if (range.beat) {
    int rC1 = round(random(2));
    int rC2 = round(random(2));

    boolean check = false;

    while (check != true) {
      rC2 = round(random(2));
      if (rC2 != rC1) {
        check = true;
        break;
      }
    }

    // Parameters:  PApplet Parent, int canv, floats x1, y2, x2, y2, color
    sideLines.add(new SideLine(this, canv,
                                triCorners[rC1][0], triCorners[rC1][1]-triCenter[1], // -triCenter for centroid offset
                                triCorners[rC2][0], triCorners[rC2][1]-triCenter[1],
                                cOne));
    int current = sideLines.size()-1;
    sideLines.get(current).move();
  }

  for (SideLine s : sideLines) {
    s.display();
  }
}

void rectLines(int canv, Indicator range, color col) {
  if (range.beat) {
    int rC1 = round(random(3));
    int rC2 = round(random(3));

    boolean check = false;

    while (check != true) {
      rC2 = round(random(3));
      if (rC2 != rC1) {
        check = true;
        break;
      }
    }
    // Parameters:  PApplet Parent, int canv, floats x1, y2, x2, y2, color
    sideLines.add(new SideLine(this, canv,
                                rectCorners[rC1][0], rectCorners[rC1][1],
                                rectCorners[rC2][0], rectCorners[rC2][1],
                                cOne));
    int current = sideLines.size()-1;
    sideLines.get(current).move();
  }

  for (SideLine s : sideLines) {
    s.display();
  }
}

void triangleZoom(int canv, Indicator range, color col, int sW) {
  if (range.beat) {
    if (sW == 0) {
      // Parameters:  int canv, floats x, y, diameter, boolean colortoggle, strokeWeight, color
      // with fill
      triangles.add(new Triangle(canv, 0, 0, 1, colorSwitch, 0, cOne));
      int current = triangles.size()-1;
      triangles.get(current).flipColor();
      triangles.get(current).grow();
    } else {
      // Parameters:  int canv, floats x, y, diameter, boolean colortoggle. strokeWeight, color
      // with stroke
      triangles.add(new Triangle(canv, 0, 0, 1, false, 5, cOne));
      int current = triangles.size()-1;
      triangles.get(current).grow();
    }
  }

  // display all objects
  for (Triangle t : triangles) {
    t.display();
  }
}

void circleZoom(int canv, Indicator range, color col, int sW, boolean reverse) {
  if (range.beat) {
    // Parameters:  int canv, floats x, y, diameter, boolean colortoggle, strokeweight, color
    circles.add(new Circle(canv, 0, 0, 1, colorSwitch, sW, cOne));
    int current = circles.size()-1;
    circles.get(current).flipColor();
    if (reverse) {
      circles.get(current).moveReverse();
    } else {
      circles.get(current).grow();
    }
  }

  for (Circle c : circles) {
    c.display();
  }
}

void rectZoom(int canv, Indicator range, color col, int sW, boolean reverse) {
  if (range.beat) {
    if (sW == 0) {
      // Parameters:  int canv, floats x, y, diameter, boolean colortoggle, strokeweight, color
      rectangles.add(new Rectangle(canv, 0, 0, 1, colorSwitch, 0, cOne));
      int current = rectangles.size()-1;
      rectangles.get(current).flipColor();
      rectangles.get(current).grow();
    } else {
      // Parameters:  int canv, floats x, y, diameter, boolean colortoggle, float weight
      rectangles.add(new Rectangle(canv, 0, 0, 1, false, sW, cOne));
      int current = rectangles.size()-1;
      rectangles.get(current).grow();
    }
  }
  for (Rectangle r : rectangles) {
    r.display();
  }
}

void moveLine(int canv, Indicator range, color col, int sWeight) {
  if (range.beatCount % 8 == 0) {
    float rotation;
    rotation = random(0, PI);
    canvas[canv].rotate(rotation);
  }
  if (range.beat) {
    if (x1 < 0) {
      Ani.to(this, 0.8, "x1", canvas[canv].width/2);
    } else {
      Ani.to(this, 0.8, "x1", -canvas[canv].width/2);
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
      canvas[i].translate(canvas[i].width/2, canvas[i].height/2);
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

void showFramerate() {
  textSize(32);
  fill(255);
  text(frameRate, 1000, 500);
}

// close minim and midibus
void stop() {
  source.close();
  minim.stop();
  bus.dispose();
  super.stop();
}
