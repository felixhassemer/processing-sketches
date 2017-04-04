// GLOBAL
import processing.sound.*;
AudioIn in;
Amplitude amp;
int number = 100;
int dotSize = 10;
Indicator[] dots = new Indicator[number];

color bgndCol = color(0);
color onColor = color(255, 0, 0);
color offColor = color(60, 60, 60);


void setup() {
  size(1000, 1000);

  // fill Array with Indicator objects
  for (int i=0; i<number; i++) {
    dots[i] = new Indicator(i*dotSize, height/2, dotSize, offColor, onColor);
  }

  in = new AudioIn(this, 0);
  amp = new Amplitude(this);
  in.start();
  amp.input(in);
}

void draw() {
  translate(dotSize/2, 0);
  background(bgndCol);

  // apply functions on all Indicator Objects in dots[]
  for (int i=0; i<dots.length; i++) {
    float thresh = map(i, 0, dots.length, 0, 1);
    dots[i].flashColor(amp, thresh);
    dots[i].display();
  }
}
