// IMPORT libraries
import spout.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import de.looksgood.ani.*;
import de.looksgood.ani.easing.*;
import oscP5.*;
import netP5.*;



// VARIABLES *****************************************************
Spout sender;   boolean sendFrames = false;
Minim minim;    AudioInput source;    FFT fft;    WindowFunction windowFunction = FFT.HANN;
SoundProcessor processor;
boolean listening = false;

// SUPERCOLLIDER COMMUNICATION
OscP5 osc;
NetAddress sc;

// record progressbar
RecordLine progressBar;
int[][] points = { {0, 0}, {0, 960}, {1280, 960}, {1280, 0} };

// ArrayLists
ArrayList<Particle> particles;
ArrayList toRemove;

// flowfield
PVector[] flowField;
int cols;       int rows;
int scl = 30;
float mag = 0.05;
boolean showVectors = true;

// flowfield NOISE
float xincr = 0.1; float yincr = 0.1; float zincr = 0.01;
float zoff = 0;

// audio
float sensitivity = 0.2;


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
    processor = new SoundProcessor(fft, source);
  }

  // init OSC and SUPERCOLLIDER
  osc = new OscP5(this, 12000);
  sc = new NetAddress("127.0.0.1", 57120);

  // init Ani
  Ani.init(this);

  // init arraylists for objects and deletion
  particles = new ArrayList<Particle>();
  toRemove = new ArrayList();

  progressBar = new RecordLine(this, points);

  initFlowField(); // set up rows, columns and flowfield array
}


// --   DRAW    ----------------------------------------------------------------
void draw() {
  // background(0);
  // stroke(255);
  // noFill();
  fill(0, 5);
  rect(0, 0, width, height);
  noFill();
  stroke(255);

  progressBar.display(255, 3); // (color c, int strokeweight)

  // ***************************************************************************
  // here goes code for audioprocessing
  if (listening) {
    fft.forward(source.mix);
    fftFunctions();
  }


  // ***************************************************************************
  // here goes code for visuals
  setFlowField(); // initialize and update the flowField + noise
  particleFunctions(); // execute all object functions on the particles


  // ***************************************************************************
  // execute misc functions
  removeObj();  // delete all the objects that have finished animating
  if (sendFrames) sender.sendTexture(); // send out each frame to resolume
  showFrameRate(20, 40, 32);  // (x, y, size)

  // Open Sound Control
  // oscOut();

}


// --   VISUALS   --------------------------------------------------------------

void particleFunctions() {
  for (Particle p : particles) {
    p.update();
    p.display();
    p.follow(flowField);

    // add objects that have reached edge to removal ArrayList
    if ((p.pos.x < 0) || (p.pos.x > width) || (p.pos.y < 0) || (p.pos.y > height)) toRemove.add(p);
  }
}

void initFlowField() {
  // calculate the number of cols and rows + some tolerance
  cols = floor((width+scl) / scl);
  rows = floor((height+scl) / scl);
  flowField = new PVector[(cols * rows)];
}

void setFlowField() {
  float xoff = 0;
  for (int x = 0; x < cols; x++) {
    float yoff = 0;
    for (int y = 0; y < rows; y++) {
      int index = x + y * cols;
      float angle = noise(xoff, yoff, zoff) * TWO_PI;
      PVector v = PVector.fromAngle(angle);
      v.setMag(mag);
      flowField[index] = v;

      // draw the vectors as lines
      if (showVectors) {
        stroke(120);
        strokeWeight(1);

        // translate line to each vectors position and rotate
        pushMatrix();
        translate(x*scl, y*scl);
        rotate(v.heading());
        line(0, 0, scl/2, 0);
        popMatrix();
      }
      yoff += yincr;
    }
    xoff += xincr;
  }
  zoff += zincr;
}

// --   AUDIO FUNCTIONS   ------------------------------------------------------

void listenPhase(int scale) {
  stroke(255);
  strokeWeight(3);
  for (int i=0; i < source.bufferSize() - 1; i++) {
    float x = map(i, 0, source.bufferSize(), 0, width);
    line(x, height/2 + source.mix.get(i) * scale, x + 1, height/2 + source.mix.get(i + 1) * scale);
  }
}


void fftFunctions() {
  processor.fillArray();
  processor.normalizeArray();
  processor.setMax();
}

// --   OSC FUNCTIONS   ------------------------------------------------------

void oscOut() {
  OscMessage msg = new OscMessage("/test");
  msg.add(400);

  osc.send(msg, sc);
}

// --   CORE FUNCTIONS   -------------------------------------------------------

void showFrameRate(int x, int y, int size) {
  textSize(size);
  text(frameRate, x, y);
}

void mousePressed() {
  // progressBar.move();
  oscOut();
}

void mouseDragged() {
  particles.add(new Particle(mouseX, mouseY));
}

void initMinim() {
  minim = new Minim(this);
  source = minim.getLineIn(Minim.STEREO, 1024);
  fft = new FFT(source.bufferSize(), source.sampleRate()/2);
  fft.logAverages(32, 12);
  fft.window(windowFunction);
}

void removeObj() {
  // all arraylists for removal of objects
  particles.removeAll(toRemove);

  if (toRemove.size() > 1000) toRemove.clear(); // clear arraylist after 1000 objects
}

void stop() {
  source.close();
  minim.stop();
  super.stop();
}
