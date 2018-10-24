
// class Point {
//   float x, y;
//
//   Point(float _x, float _y) {
//     this.x = _x;
//     this.y = _y;
//   }
// }

class Rectangle {
  float x, y, w, h;

  Rectangle(float _x, float _y, float _w, float _h) {
    this.x = _x;
    this.y = _y;
    this.w = _w;
    this.h = _h;
  }

  boolean contains(Boid boid) {
    return (boid.position.x >= this.x &&
            boid.position.x <= this.x + this.w &&
            boid.position.y >= this.y &&
            boid.position.y <= this.y + this.h);
  }

  boolean intersects(Rectangle range) {
    return !( range.x > this.x + this.w   ||
              range.x + range.w < this.x  ||
              range.y > this.y + this.h   ||
              range.y + range.h < this.y);
  }
}

class Circle {
  float x, y, r, rSquared;
  Rectangle bbox;

  Circle(float _x, float _y, float _r) {
    this.x = _x;
    this.y = _y;
    this.r = _r;
    this.rSquared = r * r;
    this.bbox = new Rectangle(this.x - this.r, this.y - this.r, this.r * 2, this.r * 2);
  }

  boolean contains(Boid boid) {
    // check if the point is in the circle by checking if the euclidean distance of
    // the point and the center of the circle is smaller or equal to the radius of
    // the circle
    float d = (float)Math.pow((boid.position.x - this.x), 2) + (float)Math.pow((boid.position.y - this.y), 2);
    return d <= this.rSquared;
  }

  boolean intersects(Rectangle range) {
    // test for intersection with bounding box
    return !( range.x > this.bbox.x + this.bbox.w   ||
              range.x + range.w < this.bbox.x       ||
              range.y > this.bbox.y + this.bbox.h   ||
              range.y + range.h < this.bbox.y);
  }
}


class QuadTree{
  Rectangle boundary;
  int capacity;
  ArrayList<Boid> points;
  boolean divided;
  QuadTree northeast, northwest, southeast, southwest;


  QuadTree(Rectangle _boundary, int _capacity) {
    this.boundary = _boundary;
    this.capacity = _capacity >= 1 ? _capacity : 1; // fallback in case it's below 1
    this.points = new ArrayList<Boid>();
    this.divided = false;
  }

  void subdivide() {
    float x = this.boundary.x;
    float y = this.boundary.y;
    float w = this.boundary.w / 2;
    float h = this.boundary.h / 2;

    Rectangle ne = new Rectangle(x+w, y, w, h);
    Rectangle se = new Rectangle(x+w, y+h, w, h);
    Rectangle sw = new Rectangle(x, y+h, w, h);
    Rectangle nw = new Rectangle(x, y, w, h);

    this.northeast = new QuadTree(ne, capacity);
    this.southeast = new QuadTree(se, capacity);
    this.southwest = new QuadTree(sw, capacity);
    this.northwest = new QuadTree(nw, capacity);

    this.divided = true;
  }

  boolean insert(Boid boid) {
    if (!this.boundary.contains(boid)) return false;

    if (this.points.size() < this.capacity) {
      this.points.add(boid);
      return true;
    }

    if (!this.divided) {
      this.subdivide();
    }

    return (northeast.insert(boid) || northwest.insert(boid) ||
            southeast.insert(boid) || southwest.insert(boid));
  }


  ArrayList query(Rectangle range, ArrayList<Boid> found) {
    if (found == null) {
      found = new ArrayList<Boid>();
    }

    if (!range.intersects(this.boundary)) {
      return found;
    }

    for (Boid boid : this.points) {
      if (range.contains(boid)) {
        found.add(boid);
      }
    }
    if (this.divided) {
      this.northwest.query(range, found);
      this.northeast.query(range, found);
      this.southwest.query(range, found);
      this.southeast.query(range, found);
    }
    return found;
  }

  ArrayList query(Circle range, ArrayList<Boid> found) {
    if (found == null) {
      found = new ArrayList<Boid>();
    }

    if (!range.intersects(this.boundary)) {
      return found;
    }

    for (Boid boid : this.points) {
      if (range.contains(boid)) {
        found.add(boid);
      }
    }
    if (this.divided) {
      this.northwest.query(range, found);
      this.northeast.query(range, found);
      this.southwest.query(range, found);
      this.southeast.query(range, found);
    }
    return found;
  }
}
