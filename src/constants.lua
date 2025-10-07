CATALOG_BUILD = true
VERSION = '1.0.1' .. (CATALOG_BUILD and 'c' or 'i')
SCOREBOARDS_ENABLED = CATALOG_BUILD

SCREEN_WIDTH, SCREEN_HEIGHT = playdate.display.getSize()
SIDEBAR_WIDTH = 52
MOON_DISTANCE_FROM_EARTH = 70
MAX_RAMP_UP_DIFFICULTY = 120
MIN_RAMP_UP_DIFFICULTY = 40

-- Asteroid paths are divided into segments, so that only 1 segment of the path
-- needs to be calculated per frame. At least one of these values must be a
-- multiple of 3!
PATH_SEGMENTS = 4
PATH_SEGMENT_LENGTH = 12

-- Calculating paths is expensive, so calculate slightly smaller paths over more
-- frames when connected to Mirror. At least one of these values must be a
-- multiple of 3!
MIRROR_PATH_SEGMENTS = 4
MIRROR_PATH_SEGMENT_LENGTH = 9
