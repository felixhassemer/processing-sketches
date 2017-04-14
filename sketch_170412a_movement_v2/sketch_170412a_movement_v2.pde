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
Indicator bassRange;
Indicator midRange;
Indicator trebleRange;

// SPOUT variables
int nSenders = 3;
PGraphics[] canvas;
Spout[] senders;

// MIDI bus
MidiBus bus;
float[] cc = new float[10];
boolean[] pads = new boolean[50];
boolean[] keys = new boolean[128];

// COLOR variables
color cBgnd = color(0);

int[] triCenter = new int[2];

// ANIMATION variables
float x1 = -300;
// Triangle[] triangles;
ArrayList<Triangle> triangles;
boolean colorToggle = true;

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

  // List all Midi devices
  MidiBus.list();
  bus = new MidiBus(this, 0, 5);

  // initialize Ani
  Ani.init(this);

  // animation objects
  triangles = new ArrayList<Triangle>();

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

  // start drawing on senders
  senderDraw();

  // translate to the centroids instead of canvas center
  senderTranslate();

  // space for animations
  // ----------------------------------------------------------------------

  triangleZoom();

  moveLine(1, bassRange);

  flashColor(0, bassRange, color(255));
  flashColor(1, midRange, color(255));
  flashColor(2, trebleRange, color(255));

  // ----------------------------------------------------------------------

  triangleOutlines(color(255));
  // send frames to spout and end drawing
  senderEnd();
}

/////////////////////////////  VISUALS  ///////////////////////////////////

void flashColor(int _canv, Indicator _range, color _col) {
  if (_range.beat) {
    canvas[_canv].fill(_col);
    canvas[_canv].noStroke();
    canvas[_canv].rect(-width/2, -height/2, width, height);
  }
}

void triangleZoom() {
  for (int i=0; i < triangles.size(); i++) {
    Triangle t = triangles.get(i);
    if (t.ani.isEnded()) {
      triangles.remove(i);
    }
  }

  if (bassRange.beat) {
    triangles.add(new Triangle(0, 0, 1, 0));
    int current = triangles.size()-1;
    triangles.get(current).flipColor(colorToggle);
    colorToggle = !colorToggle;
    triangles.get(current).grow();
  }

  for (Triangle t : triangles) {
    t.display();
  }
}

void moveLine(int _canv, Indicator _range) {
  if (_range.beatCount % 4 == 0) {
    float rotation;
    rotation = random(0, PI);
    canvas[_canv].rotate(rotation);
  }
  if (_range.beat) {
    if (x1 < 0) {
      Ani.to(this, 0.5, "x1", 300);
    } else {
      Ani.to(this, 0.5, "x1", -300);
    }
  }
  canvas[_canv].strokeWeight(10);
  canvas[_canv].stroke(255);
  canvas[_canv].line(x1, -height/2, x1, height/2);
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
  println();
  println("--------");
  println("Note On:");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);

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
  println();
  println("--------");
  println("Note Off:");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);

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
  println();
  println("--------");
  println("Controller Change:");
  println("Channel:"+channel);
  println("Number:"+number);
  println("Value:"+value);

  // put all normalized values in cc array
  cc[number] = norm(value, 0, 127);
  println(cc);
}

// close minim and midibus
void stop() {
  source.close();
  minim.stop();
  bus.dispose();
  super.stop();
}
