import themidibus.*; //Import the library

MidiBus myBus; // The MidiBus
float s = 20;
float grid = 20;
float xP, yP, xS, yS;

void setup() {
  size(800, 800);
  // fullScreen();
  background(0);
  stroke(255);
  fill(0);

  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.

  myBus = new MidiBus(this, 0, 3); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
}

void draw() {
  background(0);
  for (int xP=0; xP < width; xP += grid) {
    for (int yP=0; yP < height; yP += grid) {
      ellipse(xP, yP, xS, yS);

    }
  }
  // ellipse(xP, yP, xS, yS);
}

// void noteOn(int channel, int pitch, int velocity) {
//   // Receive a noteOn
//   println();
//   println("Note On:");
//   println("--------");
//   println("Channel:"+channel);
//   println("Pitch:"+pitch);
//   println("Velocity:"+velocity);
// }
//
// void noteOff(int channel, int pitch, int velocity) {
//   // Receive a noteOff
//   println();
//   println("Note Off:");
//   println("--------");
//   println("Channel:"+channel);
//   println("Pitch:"+pitch);
//   println("Velocity:"+velocity);
// }

void controllerChange(int channel, int number, int value) {
  // Receive a controllerChange
  // println();
  // println("Controller Change:");
  // println("--------");
  // println("Channel:"+channel);
  // println("Number:"+number);
  // println("Value:"+value);
  if (number == 1) {
    // xP = map(value, 0, 127, 0, width);
  } else if (number == 2){
    xS = map(value, 0, 127, 0, grid);
  } else if (number == 3) {
    yS = map(value, 0, 127, 0, grid);
  } else if (number == 4) {
    // yP = map(value, 0, 127, 0, height);
  } else if (number == 5) {
    grid = map(value, 0, 127, 15, width/6);
  }
  println(value);
  // line(0, value, width, value);
}

// void delay(int time) {
//   int current = millis();
//   while (millis () < current+time) Thread.yield();
// }
