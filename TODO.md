# Todo

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
* [ ] Powerups
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
* [ ] Missions/Campaign/Story
    * [x] Intro/Tutorial: Easy difficulty, divert 10 asteroids
    * [x] Survival (part 1): Medium difficulty, survive for 1 (or 2?) minutes
    * [x] Moon colonization (part 1): Medium difficulty, catch 15 rockets
    * [x] Juggling (part 1): 3 asteroids on screen at once, cause 3 collisions
    * [x] Double moon (part 1): "Easy" difficulty, survive for 1 minute
    * [ ] Boss fight (part 1): Hard difficulty, but no westward asteroids
    * [x] Survival (part 2): Hard difficulty, survive for 2 minutes
    * [x] Moon colonization (part 1): Hard difficulty, catch 20 rockets
    * [x] Juggling (part 2): 4 asteroids on screen at once, cause 5 collisions
    * [x] Double moon (part 2): Medium difficulty, survive for 90 seconds
    * [x] Survival (part 3): Ramp-up difficulty, survive for 5 minutes
    * [x] Triple moon: Medium difficulty, survive for 90 seconds
    * [ ] Boss fight (part 2): Expert difficulty, higher health, some other surprise(???)
* [x] Show win condition/progress in sidebar
* [ ] For survival missions, asteroid collisions should subtract time from the goal
* [ ] Optimize lua code
    * [ ] Less table allocations (especially for particles)
    * [ ] Pre-draw the moon/earth/asteroid/stars into images
* [ ] Menu with "Campaign" / "Endless" / "High scores" / "How to play"
    * [x] "Campaign" goes to mission selection tree
    * [ ] "Endless" goes to mode selection (survival vs. juggling vs. target practice, # of moons)
    * [ ] "High scores" shows high score for each endless mode (and each # of moons?)
* [ ] More legible font
* [ ] Music
* [ ] New sound for triggering bomb
* [ ] Quieter coin sound
* [ ] Explain bombs in "How to play"
* [ ] Light mode
* [ ] Achievements
    * [ ] X amount of asteroid-asteroid collisions
    * [ ] Revenge: Diverted asteroid got pulled back (after ~2 seconds) and hit moon/earth
    * [ ] Return to Sender: Asteroid was sent off the same side of the screen that it entered from
    * [ ] X amount of asteroids cleared at once from a bomb
* [ ] Possibly bad ideas
    * [ ] Roguelike mode? (randomized mission trees)
    * [ ] Moon colonization mode (goal is to catch every rocket which is full of people)
    * [x] Juggling mode (asteroids never despawn and always get pulled back, the only way to get rid of them is to make them collide with each other)
    * [ ] Slow motion mode (more of a puzzle game feel where a lot of asteroids are coming at you and you have to figure out how to divert all of them - either very slow motion, or turn-based somehow)
    * [ ] On harder levels, a comet (distinguished by being black with a white outline) comes by every once in a while - these are very fast and almost guaranteed to hit earth, and you're supposed to "parry" it by hitting A (or a d-pad button matching where the comet's coming from?) when it hits earth rather than diverting it with the moon
    * [ ] Allow asteroids to spawn quicker if they are spawning close to the previous ones?
    * [ ] Moon speed limit (subtly animate it instead of matching crank every frame? This might be annoying, not sure)
    * [ ] Make Moon orbit more of an ellipse?
    * [ ] Targets you have to try to hit on the edges of the screen (the default way to score points? Or like a boss fight where asteroids to damage against a giant planet just poking into one side of the screen?)
    * [ ] Minimap/radar
