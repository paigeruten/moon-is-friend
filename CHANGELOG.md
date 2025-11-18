# Changelog

## [`v1.1.0`](https://github.com/paigeruten/moon-is-friend/releases/tag/v1.1.0) First Catalog release

### Major new features

* **Meteor paths** showing each meteor's current trajectory are now shown (can be turned off in settings)
* **Global scoreboards** are available for each of the Endless game modes (Catalog version only). These are shown in-game on the High Scores screen, and your global rank is shown on the Game Over screen in Endless.
* **Zen mode** can be enabled from the Endless mode menu, and disables any meteor collisions that would cause damage. It also lets you adjust the gravity of the Moon and Earth with the D-pad. Achievements and high scores are disabled in this mode.
* **3 difficulty levels** can be selected from when starting each mission, each one giving a different badge on completion:
    * **Normal** difficulty is basically what "Easy mode" used to be (and should have been)
    * **Hard** difficulty is basically what the default difficulty used to be
    * **One Heart** difficulty is the same as **Hard**, except you die in one hit

### Minor changes

#### Gameplay

* Increased the Moon's gravitation pull, and added slightly more distance between the Moon and the Earth. This made the game a bit easier overall, so the meteor spawn rate has been slightly increased across all missions to compensate.
* Meteor collisions in Endless Juggling now give +2 bonus points when you're at full health (collisions normally give you +1 health as a reward, but there was no reward for a collision at full health)
* Smaller and smaller meteors now spawn over time in Endless Juggling, to increase the difficulty the longer you survive
* All meteors on screen now explode as soon as the boss reaches 0 HP, to prevent unfair deaths
* Gravity booster can now be used anytime there is fuel available (previously you'd have to wait for it to fully refill before using it again)
* Endless mode now reaches max level at 5 minutes (previously was 7.5 minutes), and there are half as many levels displayed as before

#### Difficulty

* You now start with 0 bombs in missions on Hard / One Heart difficulty (you still start with 1 bomb in Normal difficulty)
* In "Colonize" missions, collisions between meteors and rockets are no longer penalized (no more "Oops! -1 rocket")
* In boss fights on Normal difficulty, meteors won't be headed directly towards Earth as often
* Damage to bosses is now the same in all difficulty modes, but bosses have more HP in Hard / One Heart mode

#### Achievements

* Reworded/renamed some achievements and added 5 new ones: **No more training wheels**, **Fully stocked**, **Bonus points!**, **Particle collider**, **No casualties**
* Meteors do a bit more damage now, so the "The Big One" achievement now requires doing 15 damage to a boss (and can be done on any difficulty level)
* "Flawless" achievements now require you to complete missions in One Heart mode (rather than not taking any damage in Hard mode)

#### Quality of Life

* When you restart a boss level, the boss intro animation is now skipped
* The A button can now be used as an alternative to the B button (to trigger bombs on some levels, and activate the gravity booster on other levels)
* Added **Local Stats** page to High Scores, that shows 10 different stats that are tracked over the course of all missions and Endless runs
* Added new **Settings** menu, where you can toggle **Meteor paths** and **Screen shake**
* Playdate system menu lets you toggle **Meteor paths** at any time, instead of **Screen shake**
* Endless mode menu persists your last selected options

#### Miscellaneous

* Endless/Zen mode with 1 moon is available from the start (you no longer have to complete the first mission to unlock it)
* Earth floats around a bit instead of being completely still
* New logo that's easier to read and doesn't just use the playdate system font

### Fixes

* Previously, a moon shield could only be given to the moon that caught the rocket. This resulted in a moon that already had a shield sometimes catching a rocket and nothing happening. Now when this happens, another random moon will get the shield.
* Don't show "Use the Crank!" after game over, or during the final cutscene if the player happens to dock the crank at those times

## [`v1.0.1`](https://github.com/paigeruten/moon-is-friend/releases/tag/v1.0.1) Achievement bugfix

* Bugfix to prevent "Endless hero" and "Endless addict" achievements from popping up endlessly after reaching them (your achievement progress is unaffected)

## [`v1.0.0`](https://github.com/paigeruten/moon-is-friend/releases/tag/v1.0.0) It's a real game!

* Added Mission/Story mode
* Added Endless mode
* Added achievements
* Many more changes (detailed changelog not available)

## [`v0.1.0`](https://github.com/paigeruten/moon-is-friend/releases/tag/v0.1.0) Game Jam release

Initial game jam version.
