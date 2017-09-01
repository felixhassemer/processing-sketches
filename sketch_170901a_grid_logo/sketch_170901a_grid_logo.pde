int rows = 14;
int cols = 10;

int gNum = 3;
int gOff = 4;



// 2D Array to save color information
int[][] g0 = new int[cols][rows];
int[][] g1 = new int[cols][rows];

// 2D Array for grid width and height
float[][] gW = new float[gNum][2]; // [number of grid][width, height]
float[][] gH = new float[gNum][2]; // [number of grid][width, height]

// 2D Array to save rect positions
// int[][] g0Pos = new int[cols][rows];
// int[][] g1Pos = new int[cols][rows];


void setup() {
  // DIN Seitenverhältnis 7:10
  size(350, 500);
  background(255);
  // noStroke();
  stroke(0);
  strokeWeight(0.5);

  // grid w and h for grid 0
  gW[0][0] = float(width)/cols;
  gH[0][1] = float(height)/rows;

  // grid w and h for grid 1
  gW[1][0] = (float(width)  - (gW[0][0] * gOff)) / cols;
  gH[1][1] = (float(height) - (gH[0][1] * gOff)) / rows;

  // fill grid with random numbers as color switches
  for (int i=0; i < cols; i++) {
    for (int j=0; j < rows; j++) {
      g0[i][j] = int(random(2));
    }
  }

  // draw the grid
  for (int i=0; i < cols; i++) {
    for (int j=0; j < rows; j++) {
      if (g0[i][j] == 1) fill(0);
      else fill(255);
      rect(i*gW[0][0], j*gH[0][1], gW[0][0], gH[0][1]);
    }
  }
}

void draw() {}


void mousePressed() {
  setup();
}
