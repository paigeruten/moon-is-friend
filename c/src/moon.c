#include "moon.h"

#include "game.h"
#include "graphics.h"
#include "vec.h"

static void moon_update_pos(Moon *moon, Vec earth_pos, float crank_angle) {
  moon->pos =
      vec_add(earth_pos, vec_new_polar(MOON_DISTANCE_FROM_EARTH, crank_angle));
}

void moon_init(Moon *moon) {
  moon_update_pos(moon, SCREEN_CENTER, 270.0f);
  moon->radius = MOON_RADIUS;
}

void moon_update(Moon *moon) {
  moon_update_pos(moon, gs.earth.pos, pd->system->getCrankAngle() - 90.0f);
}

void moon_draw(Moon *moon) {
  fillCircleAtPoint(pd, moon->pos.x, moon->pos.y, moon->radius, kColorWhite);
}
