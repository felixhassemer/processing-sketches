
// GLOBAL VARS
// 14 rows - 10 cols
int rows = 10;
int cols = 10;

// total number of grids - can't be changed yet
int gCount = 6;

// offset of grid spaces on each side * 2
int gXoff = 4;
int gYoff = 4;
boolean showLines = false;

// noise
float nzOff = 0;
float[] nIncr = {0.6, 0.2, 0.001};  // noise incr: xoff, yoff, zoff

// 3D Array to save color information
int[][][] g = new int[gCount][cols][rows];

// 2D Array for grid width and height
float[][] gSize = new float[gCount][2]; // [number of grid][width, height]

// colors
color bgndC = color(255);
color fillC = color(0);
color strokeC = color(0);
color gAccent = color(170, 55, 65);
int gridAccent = 0;


void setup() {
  // DIN Seitenverhältnis 7:10
  size(500, 350);
  // fullScreen();
  background(bgndC);
  strokeWeight(0.5);

  // grid functions
  initGrid();
}

void draw() {
  background(bgndC);
  fillGrid();
  mirrorGrid();
  showGrid();
}

void initGrid() {
  // // grid w and h for each grid
  for (int num = 0; num < gCount; num++) {
    gSize[num][0] = (float(width) - (calcSize(num, 0) * gXoff)) / cols;
    gSize[num][1] = (float(height) - (calcSize(num, 1) * gYoff)) / rows;
  }
}

float calcSize(int gSelect, int whSelect) {
  float[][] gSizeSum = new float[gCount][2]; // stores width[0] and height[1] of cells

  // if gridnumber is higher than 0, add up offsets for each grid
  for (int num = 0; num < gCount; num++) {
    if (num > 0) {
      for (int i = 0; i < num; i++) {
        // add everything to the sum (0 = w, 1 = h)
        gSizeSum[num][whSelect] += gSize[i][whSelect];
      }
    } else {
      gSizeSum[num][whSelect] = 0;
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
  // for (int num = 0; num < gCount; num++) {
  //   for (int i = 0; i < cols/2; i++) {
  //     for (int j = 0; j < rows; j++) {
  //       g[num][i][j] = int(random(4));
  //     }
  //   }
  // }

  // fill half grid with noise values
  float nxOff = 0;
  for (int num = 0; num < gCount; num++) {
    for (int i = 0; i < cols/2; i++) {
      float nyOff = 0;
      for (int j = 0; j < rows; j++) {
        float n = noise(nxOff, nyOff, nzOff);
        int c = 0;

        if (n > 0.5) {
          c = 1;
        } else {
          c = 0;
        }

        g[num][i][j] = c;

        nyOff += nIncr[0];
      }
      nxOff += nIncr[1];
    }
    nzOff += nIncr[2];
  }
}

void mirrorGrid() {
  int[][][] gRev = new int[gCount][cols][rows];


  for (int num = 0; num < gCount; num++) {
    // mirror i var to go througSize array backwards
    int mi = cols / 2; // has to be reset after every grid so it doesn't become negative

    for (int i = 0; i < cols / 2; i++) {
      // mirror j var to go througSize array backwards
      int mj = rows;  // has to be reset after every column so it doesn't become negative
      mi--;

      for (int j = 0; j < rows; j++) {
        mj--;
        gRev[num][mi][mj] = g[num][i][j];
      }
    }
  }

  // append reversed array to grid array
  for (int num = 0; num < gCount; num++) {
    for (int i = 0; i < cols/2; i++) {
      for (int j = 0; j < rows; j++) {
        g[num][i + cols/2][j] = gRev[num][i][j];
      }
    }
  }
}

void showGrid() {
  // arrays to hold offset distances
  float[] xoff = new float[gCount];
  float[] yoff = new float[gCount];

  // iterate over all grids
  for (int num = 0; num < gCount; num++) {
    // sum up the offsets from previous grids
    // float[] gSizeSum = new float[2]; // stores width[0] and height[1] of cells
    xoff[0] = 0;
    yoff[0] = 0;

    // color selected grid with accent color
    color tempFill;
    if (num == gridAccent) tempFill = gAccent;
    else tempFill = fillC;

    if (num > 0) {
      // add the sum and multiply by number of cell offset / 2
      xoff[num] = calcSize(num, 0) * gXoff/2;
      yoff[num] = calcSize(num, 1) * gYoff/2;
    }

    // display all grids
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        if (g[num][i][j] == 1) {
          fill(tempFill);
          if (showLines) stroke(bgndC);
          else stroke(tempFill);
        } else {
          fill(bgndC);
          if (showLines) stroke(tempFill);
          else stroke(bgndC);
        }

        rect(i * gSize[num][0] + xoff[num], j * gSize[num][1] + yoff[num], gSize[num][0], gSize[num][1]);
      }
    }
  }
}
