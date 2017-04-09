class Indicator {
  float x, y, diameter;
  color col, onC, offC;

  // CONSTRUCTOR
  Indicator(float tempX, float tempY, float tempDiam, color tempOffC, color tempOnC) {
    x = tempX;
    y = tempY;
    diameter = tempDiam;
    onC = tempOnC;
    offC = tempOffC;
  }

  // Class Functions
  void flashKick(BeatDetect tempBeat) {
    if (tempBeat.isKick()) {
      col = onC;
    } else {
      col = offC;
    }
  }

  void flashSnare(BeatDetect tempBeat) {
    if (tempBeat.isSnare()) {
      col = onC;
    } else {
      col = offC;
    }
  }

  void flashHat(BeatDetect tempBeat) {
    if (tempBeat.isHat()) {
      col = onC;
    } else {
      col = offC;
    }
  }

  void display() {
    fill(col);
    ellipse(x, y, diameter, diameter);
  }
}


// if (beatType == "kick") {
//   if (tempBeat.isKick()) {
//     col = onC;
//   } else {
//     col = offC;
//   }
// } else if (beatType == "snare") {
//   if (tempBeat.isSnare()) {
//     col = onC;
//   } else {
//     col = offC;
//   }
// } else if (beatType == "hat") {
//   if (tempBeat.isHat()) {
//     col = onC;
//   } else {
//     col = offC;
//   }
// }
