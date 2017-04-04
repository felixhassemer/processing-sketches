// GLOBAL
import ddf.minim.*;
import ddf.minim.analysis.*;
import processing.sound.*;

Minim minim;
AudioInput source;
BeatDetect beat;
BeatListener listener;

int number = 10;
int dotSize = 200;
Indicator[] dots = new Indicator[number];

color bgndCol = color(30, 30, 30);
color onKick = color(255, 0, 0);
color onSnare = color(0, 255, 0);
color onHat = color(0, 0, 255);
color offColor = color(60, 60, 60);

class BeatListener implements AudioListener {
  private BeatDetect beat;
  private AudioInput source;

  BeatListener(BeatDetect beat, AudioInput source) {
    this.source = source;
    this.source.addListener(this);
    this.beat = beat;
  }

  void samples(float[] samps) {
    beat.detect(source.mix);
  }

  void samples(float[] sampsL, float[] sampsR) {
    beat.detect(source.mix);
  }
}

void setup() {
  size(1000, 1000);
  noStroke();

  minim = new Minim(this);
  source = minim.getLineIn();
  beat = new BeatDetect(source.bufferSize(), source.sampleRate());
  beat.setSensitivity(300);
  listener = new BeatListener(beat, source);

  dots[0] = new Indicator(width/4, height/2, dotSize, offColor, onKick);
  dots[1] = new Indicator(width/2, height/2, dotSize, offColor, onSnare);
  dots[2] = new Indicator(width-width/4, height/2, dotSize, offColor, onHat);
}

void draw() {
  background(0);
  stroke(255);
  // draw the waveforms so we can see what we are monitoring
  for(int i = 0; i < source.bufferSize() - 1; i++)
  {
    line( i, 3*height/4 + source.mix.get(i)*100, i+1, 3*height/4 + source.mix.get(i+1)*100 );
  }

  noStroke();
  dots[0].flashKick(beat);
  dots[0].display();
  dots[1].flashSnare(beat);
  dots[1].display();
  dots[2].flashHat(beat);
  dots[2].display();
}
