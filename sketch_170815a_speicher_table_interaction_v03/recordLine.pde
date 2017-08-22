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



  RecordLine(PApplet parent, PVector[] pts) {
    this.seq = new AniSequence(parent);
    this.pts[0] = new PVector(0, 0);
    this.pts[1] = new PVector(0, 100);
    this.pts[2] = new PVector(100, 100);
    this.pts[3] = new PVector(100, 0);
    this.current = new PVector(0, 0);
    this.target = pts[1];

  }

  void display() {
    stroke(255);
    strokeWeight(3);
    translate(50, 50);

    // line(pt[0][0], pt[0][1], //p1
    //     pt[1][0], pt[1][1]); //p2
    // line(pt[1][0], pt[1][1], //p2
    //     pt[2][0], pt[2][1]); //p3
    // line(pt[2][0], pt[2][1], //p3
    //     pt[3][0], pt[3][1]); //p4
    // line(pt[3][0], pt[3][1], //p4
    //     pt[0][0], pt[0][1]); //p1
    println(current);

    ellipse(current.x, current.y, 20, 20);
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
