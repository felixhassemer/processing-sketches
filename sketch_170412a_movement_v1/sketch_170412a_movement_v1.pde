// IMPORT THE SPOUT LIBRARY
import spout.*;

// spout variables
int nSenders = 3;
PGraphics[] canvas;
Spout[] senders;
color[] colors;


void setup() {
  size(1800, 800, P3D);
  canvas = new PGraphics[nSenders];
  for (int i = 0; i < nSenders; i++) {
    canvas[i] = createGraphics(width/3, width/3, P3D);
  }

  colors = new color[3];
  colors[0] = color(255, 0, 0);
  colors[1] = color(0, 255, 0);
  colors[2] = color(0, 0, 255);

  // Create Spout senders to send frames out.
  senders = new Spout[nSenders];
  for (int i = 0; i < nSenders; i++) {
    senders[i] = new Spout(this);
    String sendername = "Processing Spout"+i;
    senders[i].createSender(sendername, width/3, width/3);
  }
}

void draw() {
  for (int i = 0; i < nSenders; i++) {
    canvas[i].beginDraw();
    canvas[i].background(colors[i]);
    canvas[i].lights();
    canvas[i].translate(canvas[i].width/2, canvas[i].height/2);
    canvas[i].rotateX(frameCount * 0.01);
    canvas[i].rotateY(frameCount * 0.01);
    canvas[i].box(50);
    canvas[i].endDraw();
    senders[i].sendTexture(canvas[i]);
    image(canvas[i], (width/3)*i, 0);
  }
}
