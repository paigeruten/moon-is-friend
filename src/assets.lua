import "vendor/pdfxr"

local pd = playdate
local gfx = pd.graphics
local screenWidth, screenHeight = SCREEN_WIDTH, SCREEN_HEIGHT

Assets = {
  fonts = {},
  sfx = {},
  gfx = {
    missionIcons = {}
  }
}

local assetsToLoad = {
  { 'font',       'medium',          'fonts/Newsleak-Serif-Bold' },
  { 'font',       'small',           'fonts/font-Cuberick-Bold' },
  { 'font',       'menu',            'fonts/Roobert-10-Bold' },
  { 'pdfxr',      'boop',            'sounds/boop' },
  { 'pdfxr',      'boom',            'sounds/boom' },
  { 'pdfxr',      'goodBoom',        'sounds/good-boom' },
  { 'pdfxr',      'point',           'sounds/point' },
  { 'pdfxr',      'powerup',         'sounds/powerup' },
  { 'pdfxr',      'shieldDown',      'sounds/shield-down' },
  { 'pdfxr',      'shieldUp',        'sounds/shield-up' },
  { 'pdfxr',      'win',             'sounds/win2' },
  { 'pdfxr',      'lose',            'sounds/lose' },
  { 'pdfxr',      'omen',            'sounds/omen' },
  { 'pdfxr',      'suck',            'sounds/suck' },
  { 'sample',     'achievement',     'vendor/achievements/assets/toastSound' },
  { 'image',      'logo',            'images/logo' },
  { 'image',      'rocketNorth',     'images/rocket-orth' },
  { 'image',      'rocketNorthEast', 'images/rocket-diag' },
  { 'imagetable', 'explosion',       'images/explosion' },
  { 'image',      'heart',           'images/heart' },
  { 'image',      'heartEmpty',      'images/empty-heart' },
  { 'image',      'bomb',            'images/bomb' },
  { 'image',      'star',            'images/star' },
  { 'image',      'arrowUp',         'images/arrow-up' },
  { 'image',      'arrowRight',      'images/arrow-right' },
  { 'mission',    'asteroids',       'images/mission-asteroids' },
  { 'mission',    'boss',            'images/mission-boss' },
  { 'mission',    'collide',         'images/mission-collide' },
  { 'mission',    'rocket',          'images/mission-rocket' },
  { 'mission',    'survive',         'images/mission-survive' },
  { 'image',      'checkmark',       'images/checkmark' },
  { 'image',      'noCheckmark',     'images/no-checkmark' },
  { 'image',      'starIcon',        'images/star-icon' },
  { 'image',      'flawlessIcon',    'images/flawless-icon' },
  { 'image',      'emptyCircle',     'images/empty-circle' },
  { 'image',      'banner',          'images/banner' },
  { 'image',      'endless',         'images/endless' },
  { 'image',      'safeEyes',        'images/safe-eyes' },
  { 'imagetable', 'zeds',            'images/zeds' },
  { 'image',      'eyelid',          'images/eyelid' },
  { 'image',      'hard',            'images/hard' },
  { 'image',      'oneHeart',        'images/one-heart' },
  { 'image',      'zen',             'images/zen' },
  { 'image',      'rubdubdub',       'images/rubdubdub' },
  { 'image',      'labelMeteors',    'images/label-meteors' },
  { 'image',      'labelRockets',    'images/label-rockets' },
  { 'image',      'labelCollisions', 'images/label-collisions' },
  { 'image',      'achievement',     'vendor/achievements/assets/default_icon' },
}

function Assets.load()
  gfx.setColor(gfx.kColorBlack)
  gfx.fillRect(0, 0, screenWidth, screenHeight)

  coroutine.yield()

  Assets.fonts.large = gfx.getSystemFont()

  for progress, assetInfo in ipairs(assetsToLoad) do
    local type, name, path = assetInfo[1], assetInfo[2], assetInfo[3]
    local base, asset
    if type == 'font' then
      base = Assets.fonts
      asset = gfx.font.new(path)
    elseif type == 'pdfxr' then
      base = Assets.sfx
      asset = pdfxr.synth.new(path)
    elseif type == 'sample' then
      base = Assets.sfx
      asset = pd.sound.sampleplayer.new(path)
    elseif type == 'image' then
      base = Assets.gfx
      asset = gfx.image.new(path)
    elseif type == 'imagetable' then
      base = Assets.gfx
      asset = gfx.imagetable.new(path)
    elseif type == 'mission' then
      base = Assets.gfx.missionIcons
      asset = gfx.image.new(path)
    else
      error('unhandled asset type')
    end

    if not base or not asset then
      error('could not load asset: ' .. type .. '|' .. name .. '|' .. path)
    end

    base[name] = asset

    local percentage = math.floor(progress * 100 / #assetsToLoad)
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
    gfx.fillRect(0, 239, percentage * 4, 1)

    if progress % 4 == 0 then
      coroutine.yield()
    end
  end

  Assets.gfx.rocketEast = Assets.gfx.rocketNorth:rotatedImage(90)
end
