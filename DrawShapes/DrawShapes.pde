import toxi.math.conversion.*;
import toxi.geom.*;

import toxi.color.*;
import toxi.processing.*;

ToxiclibsSupport gfx;

List<Polygon> polygons = new ArrayList<Polygon>();

void setup() {
  size(640, 360);
  smooth();
  gfx = new ToxiclibsSupport(this);
}

void draw() {
  background(255);
  handleCollisions();

  for (Polygon polygon : polygons) {
    polygon.move();
    polygon.draw();
  }
}

void mousePressed() {
  Vec2D mouseVec = new Vec2D(mouseX, mouseY);
  Polygon clickedPolygon = findPolygonContainingPoint(mouseVec);
  if (clickedPolygon == null) {
    Polygon polygon = new Polygon();
    polygon.add(mouseVec);
    polygons.add(polygon);
  } 
  else {
    clickedPolygon.selected = true;
    clickedPolygon.anchor = mouseVec;
  }
}

void mouseDragged() {
  if (polygons.isEmpty()) {
    return;
  }
  Polygon selectedPolygon = getSelectedPolygon();
  if (selectedPolygon != null) {
    selectedPolygon.move(new Vec2D(mouseX - selectedPolygon.anchor.x, mouseY - selectedPolygon.anchor.y));
  } else {
    Polygon currentPolygon = polygons.get(polygons.size() - 1);
    Vec2D mouseVec = new Vec2D(mouseX, mouseY);
    if (mouseVec.distanceToSquared(currentPolygon.vertices.get(currentPolygon.vertices.size() - 1)) > 36) {
      currentPolygon.add(new Vec2D(mouseX, mouseY));
    }
  }
}

void mouseReleased() {
  if (polygons.isEmpty()) {
    return;
  }
  Polygon currentPolygon = polygons.get(polygons.size() - 1);
  if (currentPolygon.vertices.size() < 2) {
    polygons.remove(currentPolygon);
  } else if (!currentPolygon.finished) {
    currentPolygon.finish();
  }
  for (Polygon polygon : polygons) {
    polygon.selected = false;
  }
}

void handleCollisions() {
  for (int ia = 0; ia < polygons.size(); ia++) {
    for (int ib = ia + 1; ib < polygons.size(); ib++) {
      Polygon pa = polygons.get(ia);
      Polygon pb = polygons.get(ib);
      if (pa.intersectsPolygon(pb)) {
        pa.velocity.x = pa.velocity.y = pb.velocity.x = pb.velocity.y = 0;
      }
    }
  }
}

Polygon getSelectedPolygon() {
  for (Polygon polygon : polygons) {
    if (polygon.selected) {
      return polygon;
    }
  }
  return null;
}

Polygon findPolygonContainingPoint(Vec2D point) {
  for (Polygon polygon : polygons) {
    if (polygon.containsPoint(point)) {
      return polygon;
    }
  }
  return null;
}

