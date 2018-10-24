// Import the Libraries
import ddf.minim.*;
import ddf.minim.analysis.*;
import codeanticode.syphon.*;

// GLOBAL VARIABLES
PGraphics canvas;
PGraphics ui;
SyphonServer syphon;
AudioControl ac;
Analyzer ana;
Flock flock;
QuadTree qt;
Rectangle boundary;
Repeller r;

// PROGRAM PARAMETERS
int totalCount = 2000;  // total count of particles
int capacity = (int) totalCount / 200; // capacity of the quadtree
PVector center;
float audioThreshold = 50.0;


// SETUP
// --------------------------------------------------------------------------
void setup() {
  size(1600, 800, P2D);
  canvas = createGraphics(1280, 800, P2D);
  ui = createGraphics(320, 800, P2D);
  syphon = new SyphonServer(this, "Processing Syphon");

  // fullScreen(P2D);
  frameRate(30);
  noSmooth();

  println("Number of available Processors : " + Runtime.getRuntime().availableProcessors()); // show available Processors on the machine


  // initialize variables
  ana = new Analyzer(this, canvas.width, 0, ui.width, ui.height, FFT.NONE);
  ac = new AudioControl();
  boundary = new Rectangle(0, 0, canvas.width, canvas.height);
  r = new Repeller(canvas.width/2, canvas.height/2, 100);
  flock = new Flock();
  center = new PVector(canvas.width/2, canvas.height/2);

  // Add an initial set of boids into the system
  for (int i = 0; i < totalCount; i++) {
    flock.addBoid(new Boid(random(canvas.width),random(canvas.height)));
  }
}

// DRAW
// --------------------------------------------------------------------------
void draw() {
  qt = new QuadTree(boundary, capacity);

  // begin drawing on ui section
  ui.beginDraw();
  ui.background(0, 125, 0);
  ana.update(ui);
  showFramerate(50, 50);
  ui.endDraw();
  image(ui, canvas.width, 0); // position ui to the right

  // begin drawing on main canvas
  canvas.beginDraw();
  canvas.background(0);
  flock.run(canvas, ac.sepChange(20.0, 40.0), 70.0, 70.0); // PGraphics canvas, float sepDist, float aliDist, float cohDist

  // testing sound control
  ac.run(ana);
  // ac.showCenter(canvas);
  // testRepeller(canvas);
  // show(qt);
  canvas.endDraw();
  image(canvas, 0, 0);
  syphon.sendImage(canvas);
}

// CONTROL FUNCTIONS
// --------------------------------------------------------------------------


// MISC FUNCTIONS
// --------------------------------------------------------------------------

void show(QuadTree qt) {
  canvas.rectMode(CORNER);
  canvas.stroke(255, 0, 0);
  canvas.noFill();
  canvas.strokeWeight(1);
  canvas.rect(qt.boundary.x, qt.boundary.y, qt.boundary.w, qt.boundary.h);

  if (qt.divided) {
    show(qt.northeast);
    show(qt.northwest);
    show(qt.southeast);
    show(qt.southwest);
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      audioThreshold += 5.0;
      println(audioThreshold);
    } else if (keyCode == DOWN) {
      audioThreshold -= 5.0;
      println(audioThreshold);
    }
  }
}
void showFramerate(int x, int y) {
  ui.noStroke();
  if (frameRate <= 20) {
    ui.fill(255, 0, 0);
  } else {
    ui.fill(0);
  }
  ui.text(frameRate, x, y);  // display the current framerate
}

void testRepeller(PGraphics canv) {
  r.update(mouseX, mouseY, 100);
  Circle range1 = new Circle(mouseX, mouseY, 100);
  r.display(canv);
  ArrayList<Boid> points = qt.query(range1, null);
  for (Boid boid : points) {
    PVector f = r.repel(boid, 100);
    boid.applyForce(f);
  }
}

void testQuery(PGraphics canv) {
  Circle range1 = new Circle(mouseX, mouseY, 100);
  stroke(0, 255, 0);
  noFill();
  strokeWeight(1);
  rectMode(CENTER);
  ellipse(range1.x, range1.y, range1.r * 2, range1.r * 2);
  rect(range1.bbox.x, range1.bbox.y, range1.bbox.w, range1.bbox.h);
  ArrayList<Boid> points = qt.query(range1, null);
  for (Boid boid : points) {
    stroke(0, 255, 0);
    strokeWeight(10);
    point(boid.position.x, boid.position.y);
  }
}

void stop() {
  ana.end();
  super.stop();
}
