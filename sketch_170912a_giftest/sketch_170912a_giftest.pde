import gifAnimation.*;
GifMaker gif;


void setup() {
  size(400, 400);
  frameRate(25);

  gif = new GifMaker(this, "export.gif", 20);
  gif.setRepeat(0);
  gif.setTransparent(0, 0, 0);
}

void draw() {
  background(0);
  fill(255, 0, 0);
  noStroke();
  ellipse(mouseX, mouseY, 20, 20);

  gif.setDelay(1);

  gif.addFrame();
}

void mousePressed() {
  gif.finish();
  println("gif saved");
}
