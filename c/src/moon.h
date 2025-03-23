#ifndef moon_h
#define moon_h

#include "vec.h"

#define MOON_RADIUS 7
#define MOON_DISTANCE_FROM_EARTH 70.0f

typedef struct Moon {
  Vec pos;
  int radius;
} Moon;

void moon_init(Moon *moon);
void moon_update(Moon *moon);
void moon_draw(Moon *moon);

#endif
