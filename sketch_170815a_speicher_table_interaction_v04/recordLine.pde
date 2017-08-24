class RecordLine {
  AniSequence seq;
  // int[][] pt = { {0, 0}, {0, 100}, {100, 100}, {100, 0} };
  Easing ease = Ani.LINEAR;
  int index = 0;
  int duration = 2;
  int x, y;
  PVector[] pts = new PVector[4];
  PVector target;
  PVector current;



  RecordLine(PApplet parent, int[][] p) {
    this.seq = new AniSequence(parent);
    this.pts[0] = new PVector(p[0][0], p[0][1]);
    this.pts[1] = new PVector(p[1][0], p[1][1]);
    this.pts[2] = new PVector(p[2][0], p[2][1]);
    this.pts[3] = new PVector(p[3][0], p[3][1]);
    this.current = new PVector(p[0][0], p[0][1]);
    this.target = this.pts[1];

  }

  void display(color c, int sW) {
    stroke(c);
    strokeWeight(sW);

    // ellipse(current.x, current.y, 20, 20);
  }

  void move() {
    seq.beginSequence();

    seq.beginStep();
    seq.add(Ani.to(current, duration, "x", pts[1].x, ease));
    seq.add(Ani.to(current, duration, "y", pts[1].y, ease));
    seq.endStep();

    seq.beginStep();
    seq.add(Ani.to(current, duration, "x", pts[2].x, ease));
    seq.add(Ani.to(current, duration, "y", pts[2].y, ease));
    seq.endStep();

    seq.beginStep();
    seq.add(Ani.to(current, duration, "x", pts[3].x, ease));
    seq.add(Ani.to(current, duration, "y", pts[3].y, ease));
    seq.endStep();

    seq.beginStep();
    seq.add(Ani.to(current, duration, "x", pts[0].x, ease));
    seq.add(Ani.to(current, duration, "y", pts[0].y, ease));
    seq.endStep();

    seq.endSequence();
    seq.start();
  }
}
