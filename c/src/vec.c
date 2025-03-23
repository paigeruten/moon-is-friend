#include <math.h>

#include "vec.h"

Vec vec_new(float x, float y) { return (Vec){x, y}; }

Vec vec_new_polar(float length, float angle) {
  float angle_rad = deg2rad(angle);
  return vec_new(cosf(angle_rad) * length, sinf(angle_rad) * length);
}

Vec vec_add(Vec a, Vec b) { return vec_new(a.x + b.x, a.y + b.y); }
