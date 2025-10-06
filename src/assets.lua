import "vendor/pdfxr"

local pd = playdate
local gfx = pd.graphics

Assets = {
  fonts = {
    large = gfx.getSystemFont(),
    medium = gfx.font.new("fonts/Newsleak-Serif-Bold"),
    small = gfx.font.new("fonts/font-Cuberick-Bold"),
    menu = gfx.font.new("fonts/Roobert-10-Bold")
  },
  sfx = {
    boop = pdfxr.synth.new("sounds/boop"),
    boom = pdfxr.synth.new("sounds/boom"),
    goodBoom = pdfxr.synth.new("sounds/good-boom"),
    point = pdfxr.synth.new("sounds/point"),
    powerup = pdfxr.synth.new("sounds/powerup"),
    shieldDown = pdfxr.synth.new("sounds/shield-down"),
    shieldUp = pdfxr.synth.new("sounds/shield-up"),
    win = pdfxr.synth.new("sounds/win2"),
    lose = pdfxr.synth.new("sounds/lose"),
    omen = pdfxr.synth.new("sounds/omen"),
    suck = pdfxr.synth.new("sounds/suck"),
    achievement = pd.sound.sampleplayer.new("vendor/achievements/assets/toastSound"),
  },
  gfx = {
    logo = gfx.image.new("images/logo"),

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
    noCheckmark = gfx.image.new("images/no-checkmark"),
    starIcon = gfx.image.new("images/star-icon"),
    emptyCircle = gfx.image.new("images/empty-circle"),

    banner = gfx.image.new("images/banner"),
    endless = gfx.image.new("images/endless"),
    safeEyes = gfx.image.new("images/safe-eyes"),
    zeds = gfx.imagetable.new("images/zeds"),
    eyelid = gfx.image.new("images/eyelid"),
    hard = gfx.image.new("images/hard"),
    zen = gfx.image.new("images/zen"),

    labelMeteors = gfx.image.new("images/label-meteors"),
    labelRockets = gfx.image.new("images/label-rockets"),
    labelCollisions = gfx.image.new("images/label-collisions"),

    achievement = gfx.image.new("vendor/achievements/assets/default_icon")
  }
}
Assets.gfx.rocketEast = Assets.gfx.rocketNorth:rotatedImage(90)
