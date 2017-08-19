// IMPORT libraries
import processing.video.*;
import spout.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

// VARIABLES
Spout sender;   boolean sendFrames = false;
Minim minim;    AudioInput source;    FFT fft;    WindowFunction windowFunction = FFT.HANN;
SoundProcessor processor;

// ArrayLists
ArrayList<Particle> particles;
ArrayList toRemove;

// flowfield
PVector[] flowField;
int cols;       int rows;
int scl = 30;
float mag = 0.05;
boolean showVectors = false;

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
  initMinim();
  processor = new SoundProcessor(fft, source);

  // init arraylists for objects and deletion
  particles = new ArrayList<Particle>();
  toRemove = new ArrayList();

  initFlowField(); // set up rows, columns and flowfield array
}


// --   DRAW    ----------------------------------------------------------------
void draw() {
  background(0);
  stroke(255);
  noFill();
  // fill(0, 5);
  // noStroke();
  // rect(0, 0, width, height);
  // noFill();
  // stroke(255);

  // ***************************************************************************
  // here goes code for audioprocessing
  fft.forward(source.mix);
  fftFunctions();


  // ***************************************************************************
  // here goes code for visuals
  // setFlowField(); // initialize and update the flowField + noise
  // particleFunctions(); // execute all object functions on the particles


  // ***************************************************************************
  // execute misc functions
  removeObj();  // delete all the objects that have finished animating
  if (sendFrames) sender.sendTexture(); // send out each frame to resolume
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

void fftFunctions() {
  processor.fillArray();
  processor.normalizeArray();
  processor.setMax();
}

// --   CORE FUNCTIONS   -------------------------------------------------------

void mouseDragged() {
  // particles.add(new Particle(mouseX, mouseY));
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
