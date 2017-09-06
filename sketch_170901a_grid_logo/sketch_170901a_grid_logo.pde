
// GLOBAL VARS
// 14 rows - 10 cols
int rows = 16;
int cols = 22;

// total number of grids - can't be changed yet
int gCount = 3;

// offset of grid spaces on each side * 2
int gXoff = 12;
int gYoff = 6;

// noise
float nzOff = 0;
float[] nIncr = {0.4, 0.2, 0.001};  // noise incr: xoff, yoff, zoff

// 3D Array to save color information
int[][][] g = new int[gCount][cols][rows];

// 2D Array for grid width and height
float[][] gSize = new float[gCount][2]; // [number of grid][width, height]


void setup() {
  // DIN Seitenverhältnis 7:10
  size(1920, 1000);
  background(255);
  // noStroke();
  stroke(0);
  strokeWeight(0.5);

  // grid functions
  initGrid();

}

void draw() {
  fillGrid();
  mirrorGrid();
  showGrid();
}

void initGrid() {
  // // grid w and h for each grid
  for (int gNum = 0; gNum < gCount; gNum++) {
    gSize[gNum][0] = (float(width) - (calcSize(gNum, 0) * gXoff)) / cols;
    gSize[gNum][1] = (float(height) - (calcSize(gNum, 1) * gYoff)) / rows;
  }
}

float calcSize(int gSelect, int whSelect) {
  float[][] gSizeSum = new float[gCount][2]; // stores width[0] and height[1] of cells

  // if gridnumber is higher than 0, add up offsets for each grid
  for (int gNum = 0; gNum < gCount; gNum++) {
    if (gNum > 0) {
      for (int i = 0; i < gNum; i++) {
        // add everything to the sum (0 = w, 1 = h)
        gSizeSum[gNum][whSelect] += gSize[i][whSelect];
      }
    } else {
      gSizeSum[gNum][whSelect] = 0;
    }
  }

  // print warning if selector specified is out of range
  if ((whSelect > 1) || (whSelect < 0)) {
    println("wrong whSelect number. choose width[0] or height[1]");
  }
  if ((gSelect > gCount-1) || (gSelect < 0)) {
    println("wrong grid select number. choose number within range of gCount-1");
  }

  // sum of size of selected grid and width or height
  return gSizeSum[gSelect][whSelect];
}

void fillGrid() {
  // fill half grid with random numbers as color switches
  // for (int gNum = 0; gNum < gCount; gNum++) {
  //   for (int i = 0; i < cols/2; i++) {
  //     for (int j = 0; j < rows; j++) {
  //       g[gNum][i][j] = int(random(4));
  //     }
  //   }
  // }

  // fill half grid with noise values
  float nxOff = 0;
  for (int gNum = 0; gNum < gCount; gNum++) {
    for (int i = 0; i < cols/2; i++) {
      float nyOff = 0;
      for (int j = 0; j < rows; j++) {
        float n = noise(nxOff, nyOff, nzOff);

        if (n > 0.5) {
          n = 1;
        } else {
          n = 0;
        }

        g[gNum][i][j] = int(n);

        nyOff += nIncr[0];
      }
      nxOff += nIncr[1];
    }
    nzOff += nIncr[2];
  }



}

void mirrorGrid() {
  int[][][] gRev = new int[gCount][cols][rows];


  for (int gNum = 0; gNum < gCount; gNum++) {
    // mirror i var to go througSize array backwards
    int mi = cols / 2; // has to be reset after every grid so it doesn't become negative

    for (int i = 0; i < cols / 2; i++) {
      // mirror j var to go througSize array backwards
      int mj = rows;  // has to be reset after every column so it doesn't become negative
      mi--;

      for (int j = 0; j < rows; j++) {
        mj--;
        gRev[gNum][mi][mj] = g[gNum][i][j];
      }
    }
  }

  // append reversed array to grid array
  for (int gNum = 0; gNum < gCount; gNum++) {
    for (int i = 0; i < cols/2; i++) {
      for (int j = 0; j < rows; j++) {
        g[gNum][i + cols/2][j] = gRev[gNum][i][j];
      }
    }
  }
}

void showGrid() {
  // arrays to hold offset distances
  float[] xoff = new float[gCount];
  float[] yoff = new float[gCount];

  // iterate over all grids
  for (int gNum = 0; gNum < gCount; gNum++) {
    // sum up the offsets from previous grids
    // float[] gSizeSum = new float[2]; // stores width[0] and height[1] of cells
    xoff[0] = 0;
    yoff[0] = 0;

    if (gNum > 0) {
      // add the sum and multiply by number of cell offset / 2
      xoff[gNum] = calcSize(gNum, 0) * gXoff/2;
      yoff[gNum] = calcSize(gNum, 1) * gYoff/2;
    }

    // display all grids
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        if (g[gNum][i][j] == 1) fill(0);
        else fill(255);
        rect(i * gSize[gNum][0] + xoff[gNum], j * gSize[gNum][1] + yoff[gNum], gSize[gNum][0], gSize[gNum][1]);
      }
    }
  }
}

void mousePressed() {
  setup();
}
