#ifndef game_h
#define game_h

#include "pd_api.h"

#include "earth.h"
#include "moon.h"

void init(PlaydateAPI *playdate);
int update(void *ud);

typedef struct GameState {
  Moon moon;
  Earth earth;
} GameState;

void gamestate_reset(void);

extern PlaydateAPI *pd;
extern GameState gs;

#endif
