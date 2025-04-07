import "vendor/pdfxr"

local pd = playdate
local gfx = pd.graphics

Assets = {
  fonts = {
    large = gfx.getSystemFont(),
    small = gfx.font.new("fonts/font-rains-1x")
  },
  sfx = {
    boop = pdfxr.synth.new("sounds/boop"),
    boom = pdfxr.synth.new("sounds/boom"),
    goodBoom = pdfxr.synth.new("sounds/good-boom"),
    point = pdfxr.synth.new("sounds/point"),
    powerup = pdfxr.synth.new("sounds/powerup"),
    shieldDown = pdfxr.synth.new("sounds/shield-down"),
    shieldUp = pdfxr.synth.new("sounds/shield-up")
  },
  gfx = {
    rocketNorth = gfx.image.new("images/rocket-orth"),
    rocketNorthEast = gfx.image.new("images/rocket-diag"),

    explosion = gfx.imagetable.new("images/explosion"),

    heart = gfx.image.new("images/heart"),
    heartEmpty = gfx.image.new("images/empty-heart"),
    bomb = gfx.image.new("images/bomb"),
    star = gfx.image.new("images/star"),

    arrowUp = gfx.image.new("images/arrow-up"),
    arrowRight = gfx.image.new("images/arrow-right"),

    missionIcons = {
      asteroids = gfx.image.new("images/mission-asteroids"),
      boss = gfx.image.new("images/mission-boss"),
      collide = gfx.image.new("images/mission-collide"),
      rocket = gfx.image.new("images/mission-rocket"),
      survive = gfx.image.new("images/mission-survive"),
    },

    checkmark = gfx.image.new("images/checkmark"),
    banner = gfx.image.new("images/banner")
  }
}
Assets.gfx.rocketEast = Assets.gfx.rocketNorth:rotatedImage(90)
