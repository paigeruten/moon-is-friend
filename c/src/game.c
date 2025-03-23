#include "game.h"

#include "moon.h"

PlaydateAPI *pd = NULL;
GameState gs;

void init(PlaydateAPI *playdate) {
  pd = playdate;
  srand(pd->system->getSecondsSinceEpoch(NULL));
  pd->display->setRefreshRate(50.0f);
  pd->graphics->setBackgroundColor(kColorBlack);
  gamestate_reset();
}

void gamestate_reset(void) {
  moon_init(&gs.moon);
  earth_init(&gs.earth);
}

int update(void *ud) {
  if (!pd->system->isCrankDocked()) {
    moon_update(&gs.moon);
  }

  pd->graphics->clear(kColorBlack);
  moon_draw(&gs.moon);
  earth_draw(&gs.earth);

  return 1;
}
