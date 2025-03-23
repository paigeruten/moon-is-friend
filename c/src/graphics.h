#ifndef graphics_h
#define graphics_h

#include "pd_api.h"

#define SCREEN_WIDTH 400
#define SCREEN_HEIGHT 240
#define SCREEN_CENTER ((Vec){SCREEN_WIDTH / 2.0f, SCREEN_HEIGHT / 2.0f})

void drawCircleAtPoint(PlaydateAPI *pd, int x, int y, int r, LCDColor color);
void fillCircleAtPoint(PlaydateAPI *pd, int x, int y, int r, LCDColor color);

#endif
