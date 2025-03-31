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
* [ ] Waves/levels
    * [ ] Progress bar at bottom divided into 5 sections (levels), showing how close you are to getting to the next level
    * [ ] Small breather in between levels where you get a free powerup or two
    * [ ] Each level will have a higher asteroid spawn rate, and higher average asteroid velocity
    * [ ] Level 1: Basic game
    * [ ] Level 2: Larger asteroids have a chance of spawning
    * [ ] Level 3: Meteor showers
    * [ ] Level 4: Comets
    * [ ] Level 5: Boss fight
    * [ ] Goes into endless mode after the boss fight with a slow but never- ending ramp up in asteroid spawn rate
* [ ] Optimize lua code
    * [ ] Less table allocations (especially for particles)
    * [ ] Pre-draw the moon/earth/asteroid/stars into images
* [ ] Menu with "Start" / "High scores" / "How to play"
* [ ] More legible font
* [ ] Music
* [ ] New sound for triggering bomb
* [ ] Quieter coin sound
* [ ] Explain bombs in "How to play"
* [ ] Light mode
* [ ] Possibly bad ideas
    * [ ] Moon colonization mode (goal is to catch every rocket which is full of people)
    * [x] Juggling mode (asteroids never despawn and always get pulled back, the only way to get rid of them is to make them collide with each other)
    * [ ] Slow motion mode (more of a puzzle game feel where a lot of asteroids are coming at you and you have to figure out how to divert all of them - either very slow motion, or turn-based somehow)
    * [ ] On harder levels, a comet (distinguished by being black with a white outline) comes by every once in a while - these are very fast and almost guaranteed to hit earth, and you're supposed to "parry" it by hitting A (or a d-pad button matching where the comet's coming from?) when it hits earth rather than diverting it with the moon
    * [ ] Allow asteroids to spawn quicker if they are spawning close to the previous ones?
    * [ ] Moon speed limit (subtly animate it instead of matching crank every frame? This might be annoying, not sure)
    * [ ] Make Moon orbit more of an ellipse?
    * [ ] Targets you have to try to hit on the edges of the screen (the default way to score points? Or like a boss fight where asteroids to damage against a giant planet just poking into one side of the screen?)
    * [ ] Minimap/radar
