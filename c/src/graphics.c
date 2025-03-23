#include "graphics.h"

void drawCircleAtPoint(PlaydateAPI *pd, int x, int y, int r, LCDColor color) {
  int d = r * 2;
  pd->graphics->drawEllipse(x - r, y - r, d, d, 1, 0.0f, 0.0f, color);
}

void fillCircleAtPoint(PlaydateAPI *pd, int x, int y, int r, LCDColor color) {
  int d = r * 2;
  pd->graphics->fillEllipse(x - r, y - r, d, d, 0.0f, 0.0f, color);
}
