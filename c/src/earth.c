#include "earth.h"

#include "game.h"
#include "graphics.h"
#include "vec.h"

void earth_init(Earth *earth) {
  earth->pos = SCREEN_CENTER;
  earth->radius = EARTH_RADIUS;
}

void earth_draw(Earth *earth) {
  fillCircleAtPoint(pd, earth->pos.x, earth->pos.y, earth->radius, kColorWhite);
}
