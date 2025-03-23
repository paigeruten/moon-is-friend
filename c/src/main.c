#include "game.h"
#include "pd_api.h"

int eventHandler(PlaydateAPI *playdate, PDSystemEvent event, uint32_t arg) {
  if (event == kEventInit) {
    playdate->system->setUpdateCallback(update, NULL);
    init(playdate);
  }

  return 0;
}
