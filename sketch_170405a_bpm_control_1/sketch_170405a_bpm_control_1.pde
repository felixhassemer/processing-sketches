float bpm = 120.0;

color offC = color(25);
color measureC = color(255, 0, 0);
color beat4C = color(0, 255, 0);
color beat8C = color(0, 0, 255);
color beat16C = color(0, 128, 128);

FlashDot[] dots = new FlashDot[5];

void setup() {
  size(500, 200);
  frameRate(60);
  noStroke();
  dots[0] = new FlashDot(100, height/2, 50);
  dots[1] = new FlashDot(200, height/2, 50);
  dots[2] = new FlashDot(300, height/2, 50);
  dots[3] = new FlashDot(400, height/2, 50);
}

void draw() {
  float beat4 = 60000/bpm;
  float measure = beat4*4;
  float beat8 = beat4/2;
  float beat16 = beat8/2;
  float beat4tri = measure/3;

  background(0);

  dots[0].display(measure, measureC, offC);
  dots[1].display(beat4, beat4C, offC);
  dots[2].display(beat8, beat8C, offC);
  dots[3].display(beat4tri, beat16C, offC);

}
