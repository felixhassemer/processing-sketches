// import libraries
import processing.video.*;
import spout.*;
import gab.opencv.*;

// Variables
Capture cam;
Spout sender;
OpenCV opencv;

float scaleFr = 4;

void setup() {
  size(1280, 960, P2D);
  background(0);

  // list all cameras and initialize one
  camInit(15);

  // OPENCV
  opencv = new OpenCV(this, int(width / scaleFr), int(height / scaleFr));
  opencv.startBackgroundSubtraction(3, 3, 0.5);

  // Create Spout senders to send frames out.
  // sender = new Spout(this);
  // sender.createSender("Spout Processing");
}

void draw() {
  background(0);
  scale(scaleFr);
  opencv.loadImage(cam);
  // opencv.flip(180);
  opencv.updateBackground();
  opencv.dilate();
  opencv.erode();


  // show camera image
  // image(cam, 0, 0);

  // OPENCV
  noFill();
  // fill(255);
  stroke(255);
  strokeWeight(1);

  for (Contour contour : opencv.findContours()) {
    contour.draw();
  }


  // here goes code for visuals


  // send texture to spout
  // sender.sendTexture();
}


void camInit(int num) {
  String[] cameras = Capture.list();
  println(cameras.length);
  if (cameras.length == 0) {
    println("No Camera found");
    exit();
  } else {
    println("available Cameras");
    for (int i=0; i < cameras.length; i++) {
      println(i, cameras[i]);
    }
    cam = new Capture(this, int(width/scaleFr), int(height/scaleFr), cameras[num]);
    cam.start();
  }
}

// read the frames from camera
void captureEvent(Capture c) {
  c.read();
}
