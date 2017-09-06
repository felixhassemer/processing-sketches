
// GLOBAL VARS
// 14 rows - 10 cols
int rows = 16;
int cols = 22;

// total number of grids - can't be changed yet
int gCount = 3;

// offset of grid spaces on each side * 2
int gXoff = 6;
int gYoff = 6;

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
  fillGrid();
  mirrorGrid();
  showGrid();
}

void draw() {}

void initGrid() {
  // grid w and h for grid 0
  gSize[0][0] = float(width) /cols;
  gSize[0][1] = float(height)/rows;

  // grid w and h for grid 1
  gSize[1][0] = (float(width)  - gSize[0][0] * gXoff) / cols;
  gSize[1][1] = (float(height) - gSize[0][1] * gYoff) / rows;

  // grid w and h for grid 2
  gSize[2][0] = (float(width)  - (gSize[0][0] * gXoff) - (gSize[1][0] * gXoff)) / cols;
  gSize[2][1] = (float(height) - (gSize[0][1] * gYoff) - (gSize[1][1] * gYoff)) / rows;
}

void fillGrid() {
  // fill half grid with random numbers as color switches
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
    float[] gSizeSum = new float[2]; // stores width[0] and height[1] of cells
    xoff[0] = 0;
    yoff[0] = 0;

    // if gridnumber is higher than 0, add up offsets for each grid
    if (gNum > 0) {
      for (int i = 0; i < gNum; i++) {
        // add everything to the sum (0 = w, 1 = h)
        gSizeSum[0] += gSize[i][0];
        gSizeSum[1] += gSize[i][1];
      }
      // add the sum and multiply by number of cell offset / 2
      xoff[gNum] = gSizeSum[0] * gXoff/2;
      yoff[gNum] = gSizeSum[1] * gYoff/2;
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
