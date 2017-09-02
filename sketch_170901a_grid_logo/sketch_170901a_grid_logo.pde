
// GLOBAL VARS
int rows = 14;
int cols = 10;

int gCount = 3;
int gXoff = 4;
int gYoff = 6;

// 3D Array to save color information
int[][][] g = new int[gCount][cols][rows];

// 2D Array for grid width and height
float[][] gW = new float[gCount][2]; // [number of grid][width, height]
float[][] gH = new float[gCount][2]; // [number of grid][width, height]


void setup() {
  // DIN Seitenverhältnis 7:10
  size(350, 500);
  background(255);
  // noStroke();
  stroke(0);
  strokeWeight(0.5);

  // grid functions
  initGrid();
  fillGrid();
  mirrorGrid();
  showGrid();

}

void draw() {}

void initGrid() {
  // grid w and h for grid 0
  gW[0][0] = float(width) /cols;
  gH[0][1] = float(height)/rows;

  // grid w and h for grid 1
  gW[1][0] = (float(width)  - gW[0][0] * gXoff) / cols;
  gH[1][1] = (float(height) - gH[0][1] * gYoff) / rows;

  // grid w and h for grid 2
  gW[2][0] = (float(width)  - (gW[0][0] * gXoff) - (gW[1][0] * gXoff)) / cols;
  gH[2][1] = (float(height) - (gH[0][1] * gYoff) - (gH[1][1] * gYoff)) / rows;
}

void fillGrid() {
  // fill grid with random numbers as color switches
  for (int gNum = 0; gNum < gCount; gNum++) {
    for (int i = 0; i < cols/2; i++) {
      for (int j = 0; j < rows; j++) {
        g[gNum][i][j] = int(random(4));
      }
    }
  }
}

void mirrorGrid() {
  int[][][] gRev = new int[gCount][cols][rows];


  for (int gNum = 0; gNum < gCount; gNum++) {
    // mirror i var to go through array backwards
    int mi = cols / 2;

    for (int i = 0; i < cols / 2; i++) {
      // mirror j var to go through array backwards
      int mj = rows;
      mi--;
      // println("i, mi: " + i + " ," + mi);

      for (int j = 0; j < rows; j++) {
        mj--;
        // println("j, mj: " + j + " ," + mj);
        gRev[gNum][mi][mj] = g[gNum][i][j];
      }
    }
  }

  // for (int gNum = 0; gNum < gCount; gNum++) {
  //   for (int i = 0; i < cols; i++) {
  //     println(i + cols/2);
  //     for (int j = 0; j < rows; j++) {
  //       // g[gNum][i][j] = gRev[gNum][i][j];
  //     }
  //   }
  // }
}



void showGrid() {
  // draw grid 0
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (g[0][i][j] == 1) fill(0);
      else fill(255);
      rect(i*gW[0][0], j*gH[0][1], gW[0][0], gH[0][1]);
    }
  }

  // draw grid 1
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (g[1][i][j] == 1) fill(0);
      else fill(255);
      float xoff = gW[0][0] * gXoff/2;
      float yoff = gH[0][1] * gYoff/2;
      rect(i*gW[1][0] + xoff, j*gH[1][1] + yoff, gW[1][0], gH[1][1]);
    }
  }

  // draw grid 2
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (g[2][i][j] == 1) fill(0);
      else fill(255);
      float xoff = (gW[0][0] + gW[1][0]) * gXoff/2;
      float yoff = (gH[0][1] + gH[1][1]) * gYoff/2;
      rect(i*gW[2][0] + xoff, j*gH[2][1] + yoff, gW[2][0], gH[2][1]);
    }
  }
}

void mousePressed() {
  setup();
}
