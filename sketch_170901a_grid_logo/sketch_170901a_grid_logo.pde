int rows = 14;
int cols = 10;

int gNum = 3;
int gXoff = 4;
int gYoff = 4;

// 2D Array to save color information
int[][] g0 = new int[cols][rows];
int[][] g1 = new int[cols][rows];
int[][] g2 = new int[cols][rows];


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
  gW[0][0] = float(width) /cols;
  gH[0][1] = float(height)/rows;

  // grid w and h for grid 1
  gW[1][0] = (float(width)  - gW[0][0] * gXoff) / cols;
  gH[1][1] = (float(height) - gH[0][1] * gYoff) / rows;

  // grid w and h for grid 2
  gW[2][0] = (float(width)  - (gW[0][0] * gXoff) - (gW[1][0] * gXoff)) / cols;
  gH[2][1] = (float(height) - (gH[0][1] * gYoff) - (gH[1][1] * gYoff)) / rows;

  // fill grid with random numbers as color switches
  for (int i=0; i < cols; i++) {
    for (int j=0; j < rows; j++) {
      // g0[i][j] = int(random(2));
      // g1[i][j] = int(random(2));
      // g2[i][j] = int(random(2));
      g0[i][j] = 0;
      g1[i][j] = 0;
      g2[i][j] = 0;
    }
  }

  // draw grid 0
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (g0[i][j] == 1) fill(0);
      else fill(255);
      rect(i*gW[0][0], j*gH[0][1], gW[0][0], gH[0][1]);
    }
  }

  // draw grid 1
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (g1[i][j] == 1) fill(0);
      else fill(255);
      float xoff = gW[0][0] * gXoff/2;
      float yoff = gH[0][1] * gYoff/2;
      rect(i*gW[1][0] + xoff, j*gH[1][1] + yoff, gW[1][0], gH[1][1]);
    }
  }

  // draw grid 2
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (g2[i][j] == 1) fill(0);
      else fill(255);
      float xoff = (gW[0][0] * gXoff/2) + (gW[1][0] * gXoff/2);
      float yoff = (gH[0][1] * gXoff/2) + (gH[1][1] * gXoff/2);
      rect(i*gW[2][0] + xoff, j*gH[2][1] + yoff, gW[2][0], gH[2][1]);
    }
  }
}

void draw() {}


void mousePressed() {
  setup();
}
