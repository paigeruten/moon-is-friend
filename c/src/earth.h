#ifndef earth_h
#define earth_h

#include "vec.h"

#define EARTH_RADIUS 14

typedef struct Earth {
  Vec pos;
  int radius;
} Earth;

void earth_init(Earth *earth);
void earth_draw(Earth *earth);

#endif
