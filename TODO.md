# Todo

## For Catalog release

* [x] Asteroid paths
    * [x] Better way of toggling this (system menu + new settings menu)
    * [ ] Fix performance when there are 3+ asteroids
    * [ ] Add page to manual about paths, and how they impact performance
    * [x] Add achievement for winning a mission without showing asteroid paths ("Training wheels off")
* [x] Fidgety Earth
* [ ] Difficulty tweaks
    * [x] The "Easy mode" checkbox should be changed to "Hard mode", so that the old "Easy mode" becomes the default/standard.
    * [ ] Difficulty of each level can be tweaked/balanced from there.
    * [x] Stars should be earned by playing on "Hard mode" instead of playing flawlessly, and new achievement should be added for getting all stars. (Make star look more fancy if they played flawlessly?)
    * [ ] Make "Hard mode" checkbox more obvious? (Difficulty select dialog when you re-play a mission?)
    * [ ] "Hard mode" unlocks after beating the game for the first time?
    * [ ] In boss fights, don't make asteroids come directly from the left of Earth (maybe in hard mode...)
* [x] Global scoreboards
    * [ ] Final boss speedrun scoreboard?
* [x] Zen/Practice mode (constant difficulty, no damage, probably a setting within Endless mode)
* [ ] Performance tweaks
* [ ] Update story text
* [ ] Upload Catalog assets

## Old list

* [x] Collision
* [x] Screen shake on collision (respecting "reduce flashing" setting)
* [x] Variation in asteroid initial velocity (not always pointing directly at Earth)
* [x] Collision between asteroids?
* [x] Health
* [x] Game over screen
* [x] Stars in background
* [x] Rockets from Earth that repair the moon
* [x] Animations
    * [x] Asteroid collision explosions
    * [x] Rocket taking off particles
    * [x] Asteroid tail (like a comet?) animation/particles
* [x] Make everything bigger? (or just asteroids)
* [x] Proper title screen
* [x] Don't start the game until the crank is undocked
* [x] Tutorial/story
* [x] Game Over menu (Retry / Title Screen)
* [x] End goal (100 points = you get a star?)
* [x] Save high score
* [x] Bigger hearts
* [x] Launcher card
* [x] Screenshots / GIFs for itch and github
* [x] Pause menu (Restart / Title Screen)
* [x] Bombs
* [x] Sound effects
    * [x] Asteroid goes off screen
    * [x] Asteroids collide with each other
    * [x] Asteroid collides with moon or earth
    * [x] +1 HP / powerup
    * [x] Gain shield
    * [x] Asteroid takes out shield
* [x] Googly eyes on earth looking worriedly at the closest incoming asteroid?
* [x] Increase difficulty (more frequent asteroids)
* [x] Easy mode
    * [x] Lower boss HP, or scale up damage
    * [x] 5 hearts
    * [x] Add 25 to all asteroid spawn rates
    * [ ] i-frames (maybe the standard game should have this too though)
    * [x] Does not affect endless mode
    * [x] Flawless achievements require standard mode
* [x] Powerups
    * [x] +1 HP
    * [x] Moon shield
    * [x] Earth shield
    * [ ] Slow motion in moon's orbit (or time bombs?)
    * [x] Max health up (only when no other powerups applicable)
    * [x] +1 Bomb
    * [x] Limit bombs
* [x] Asteroids collide with rockets
* [x] Press A for super gravity (for throwing things?)
* [x] Bomb shockwave animation
* [x] Start with 1 or 2 bombs
* [x] Arrows showing where asteroids are about to enter the screen
* [x] Make earth look like earth and moon look like moon
* [x] Missions/Campaign/Story
    * [x] Intro/Tutorial: Easy difficulty, divert 10 asteroids
    * [x] Survival (part 1): Medium difficulty, survive for 1 (or 2?) minutes
    * [x] Moon colonization (part 1): Medium difficulty, catch 15 rockets
    * [x] Juggling (part 1): 3 asteroids on screen at once, cause 3 collisions
    * [x] Double moon (part 1): "Easy" difficulty, survive for 1 minute
    * [x] Boss fight (part 1): Harder difficulty, but no westward asteroids
        * [x] Ominous intro animation
        * [x] Victory animation (lots of explosions and/or boss asteroid breaking apart)
        * [x] Boss launches asteroids at earth
    * [x] Survival (part 2): Hard difficulty, survive for 2 minutes
    * [x] Moon colonization (part 1): Hard difficulty, catch 20 rockets
    * [x] Juggling (part 2): 4 asteroids on screen at once, cause 5 collisions
    * [x] Double moon (part 2): Medium difficulty, survive for 90 seconds
    * [x] Survival (part 3): Ramp-up difficulty, survive for 5 minutes
    * [x] Triple moon: Medium difficulty, survive for 90 seconds
    * [x] Boss fight (part 2): Expert difficulty, higher health, some other surprise(???)
        * [ ] Minion shield that becomes projectiles
        * [ ] Shield that blocks low-velocity asteroids
* [x] Show win condition/progress in sidebar
* [x] For survival missions, asteroid collisions should subtract time from the goal
* [x] Optimize lua code
    * [x] Less table allocations (especially for particles)
    * [ ] Pre-draw the moon/earth/asteroid/stars into images
* [x] Menu with "Missions" / "Endless" / "High scores" / "How to play"
    * [x] "Campaign" goes to mission selection tree
    * [x] "Endless" goes to mode selection (survival vs. juggling vs. target practice, # of moons)
    * [x] "High scores" shows high score for each endless mode (and each # of moons?)
* [ ] Fix target splode slowdown
* [ ] Flawless juggling should be allowed on easy mode
* [x] Can hardly see the gravity booster circle
* [x] More legible font
* [ ] Music
* [ ] New sound for triggering bomb
* [x] Quieter coin sound
* [ ] Achievements
    * [x] Create card image for trophy case
    * [x] Beat the first boss
    * [ ] Revenge: Diverted asteroid got pulled back (after ~2 seconds) and hit moon/earth
    * [ ] Return to Sender: Asteroid was sent off the same side of the screen that it entered from
    * [x] Get 100 points in each endless mode
    * [x] Complete every mission without taking damage
    * [x] X amount of asteroid-asteroid collisions
    * [x] X amount of asteroids cleared at once from a bomb
    * [x] Max out damage done to boss (large asteroid + high velocity)
    * [x] Asteroid collided with rocket
    * [x] Complete each mission without taking damage
    * [x] Beat the game (complete 6-B)
    * [x] Complete every mission
    * [x] Double Shield: Have 2 shields up at once (between moon(s) and Earth)
    * [x] Triple Shield: Have 3 shields up at once (between moon(s) and Earth)
    * [x] Quadruple Shield: Have 4 shields up at once (between moon(s) and Earth)
* [ ] Possibly bad ideas
    * [ ] Roguelike mode? (randomized mission trees)
    * [x] Moon colonization mode (goal is to catch every rocket which is full of people)
    * [x] Juggling mode (asteroids never despawn and always get pulled back, the only way to get rid of them is to make them collide with each other)
    * [ ] Slow motion mode (more of a puzzle game feel where a lot of asteroids are coming at you and you have to figure out how to divert all of them - either very slow motion, or turn-based somehow)
    * [ ] On harder levels, a comet (distinguished by being black with a white outline) comes by every once in a while - these are very fast and almost guaranteed to hit earth, and you're supposed to "parry" it by hitting A (or a d-pad button matching where the comet's coming from?) when it hits earth rather than diverting it with the moon
    * [ ] Allow asteroids to spawn quicker if they are spawning close to the previous ones?
    * [ ] Moon speed limit (subtly animate it instead of matching crank every frame? This might be annoying, not sure)
    * [ ] Make Moon orbit more of an ellipse?
    * [x] Targets you have to try to hit on the edges of the screen (the default way to score points? Or like a boss fight where asteroids to damage against a giant planet just poking into one side of the screen?)
    * [ ] Minimap/radar
    * [ ] Randomly double/triple up asteroids sometimes
    * [ ] Light mode
