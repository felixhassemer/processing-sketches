class SideLine {
  float x1, y1, x2, y2;
  int canv;
  color col;
  AniSequence ani;
  PApplet parent;

  SideLine(PApplet parent, int canv, float x1, float y1, float x2, float y2, color col) {
    this.parent = parent;
    this.canv = canv;
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
    this.col = col;
  }

  void display() {
    canvas[canv].stroke(cOne);
    canvas[canv].strokeWeight(10);
    canvas[canv].noFill();
    canvas[canv].line(x1, y1, x2, y2);
  }

  void move() {
    // begin animation sequence towards centroid
    ani = new AniSequence(parent);
    ani.beginSequence();

    ani.beginStep();
    ani.add(Ani.to(this, 2, "x1", 0));
    ani.add(Ani.to(this, 2, "y1", 0));
    ani.add(Ani.to(this, 2, "x2", 0));
    ani.add(Ani.to(this, 2, "y2", 0));
    ani.endStep();

    ani.endSequence();

    ani.start();
  }
}
