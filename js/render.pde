/* MathTrip, created by Luke Weber on 12/01/2015
 *
 *    Uses Newtonian physics to render a universe of stars, planets, asteroids, and spaceships.
 *    Attempting to implement self-guided spaceship to start on one planet and
 *    end on a given target planet, given realistic safe landing velocities. Also working towards
 *    integrating fluid collision detection and missle destruction.
 *
 *    We'll see where this goes.
 */

"use scrict";

// Audio effects
var backgroundMusic = new Audio("/res/audio/gothic_suburbia.mp3");
var shootSound = new Audio("/res/audio/ping.mp3");
var fragmentizeSound = new Audio("/res/audio/ping.mp3");
var thrustSound = new Audio("/res/audio/ping.mp3");

// Canvas
var CANVAS_WIDTH = window.innerWidth;
var CANVAS_HEIGHT = window.innerHeight;
var FPS = 50;
var CENTER_X = CANVAS_WIDTH / 2;
var CENTER_Y = CANVAS_HEIGHT / 2;
var FADE_LEVEL = 100;
var BG_COLOR = color(8, 12, 48, FADE_LEVEL);

// Celestials
var PLANET_COLOR = color(12, 22, 116);
var ASTEROID_COLOR = 0; // TODO
var STAR_COLOR = color(168, 123, 0);
var SHIP_COLOR = color(4, 71, 107);
var LABEL_COLOR = color(209, 198, 168, FADE_LEVEL);//color(48, 49, 61);
var GRID_COLOR = LABEL_COLOR;
var TARGET_COLOR = color(133, 40, 40);
var SHIP_CHART_COLOR = color(2, 48, 73, FADE_LEVEL);

// Missile
var ROCKET_RADIUS = 2;
var ROCKET_VELOCITY = 10;
var ROCKET_COLOR = color(100, 0, 0);
var ROCKET_THRUST = 100;
var ROCKET_POWER = 20;
var ROCKET_DENSITY = 10;
var ROCKET_FRAME_SPACE = 10; // frames

// Ship
var TARGET_RADIUS = 5;
var TARGET_COLOR = color(255, 255, 255);
var MISSILE_COUNT = 100;
var SPACESHIP_R = 10;
var SPACESHIP_THRUST = 500; // Newtons

// Universe
var NUM_PLANETS = 50;
var NUM_ASTEROIDS = 20;
var NUM_STARS = 0;
var CHAOS_LEVEL = 0.1;

/*
   var c=document.getElementById("thisCanvas");
   var ctx=c.getContext("2d");
   var img = new Image();
   img.src = "res/spaceship.png";
   img.onload = function() {
      // RUN EVERYTHING
   }Football
   var img=document.getElementById("res/spaceship.png");
   ctx.drawImage(img, 10, 10);
 */

/* Text display variables */

//var woahArr = ["...", "Woah...", "Math.", "That's...", "Cool.", "How'd..", "Yah..", "Do..", "That?", "JS?", "Luke?", "Well.", "It's fast.", "Too fast.", "Pause?", "Please.", "Fuck.", "Stop.", "Can't", "Read.", "Shit."];
//var woahInt = 0;

/* Music variables */

// A through G (Whole multiples of these notes are the notes themselves.)
/*
   var aMinor = [27.50, 30.87, 32.70, 36.71, 41.20, 43.65, 49.00];
   var note = 0;
   var octave = 200;
   var scale = aMinor;
 */

/* Spiral Properties */

/*
   var stop = false;Football
   // Maximum length any spiral can go
   var maxAbsLength = 500;
   // Max length current spiral can go
   var maxSpiralLength = maxAbsLength;
   var spiralVelMax = 5;
   // Length of current spiral's circle
   var length = 0;
   var circleRadius = 1;
   var angle = 0;
   // Initialize variables for spiral circle object
   var spiralX = 0;
   var spiralY = 0;
   var spiralVelY = 0;
   var spiralVelX = 0;
   var spiralAccY = 1;
   var spiralT = 0;
   // Spiral's current circle positioning
   var x = centerX;
   var y = centerY;
   var pastX = 1000;
   var pastY = 1000;
   // Circle colors
   var pastColor = color(0, 0, 0);
   var thisColor = color(0, 0, 0);
   var stroked = true;
   //var strokedWeight = 40;
   // Controls circle placement
   var angleIncr = 64 / (4 * Math.PI);
   var intensityIncr = 200;
   var randomness = 0;
 */

// TODO Make more efficient (for larger simulations)
// TODO Have universe mode which sets up random, stable solar systems.
// TODO Have AI bot that can start and land on the desired planets
// TODO Incorporate spiral into object and gravity!
// TODO OnClick() --> Display planets properties right next to it.
// TODO Update catalyze scale
// TODO General universe function for getting the net acceleration on a given celestial (not necessarily in array)?
// Static functions in javascript?
// TODO Implement terminal for giving autonomous spaceship instructions

// Display console
var console;

// Declare universe
var universe;

// Key controls
var spaceKeyDown = false;
var upKeyDown = false;
var downKeyDown = false;
var leftKeyDown = false;
var rightKeyDown = false;

// Mode controls
var gravityDisplayMode = false;
var chartMode = false;
var velocityDragMode = false;
var gridMode = false;

// Canvas constructor
void setup() {
        console.log("Fuck");

        // TODO: remove
        return;

        // Big bang
        //universe = new Universe(NUM_STARS, NUM_PLANETS, NUM_ASTEROIDS, CHAOS_LEVEL);

        // Create console with universe as member
        //console = new Console(universe);

        // Set canvas and drawing properties
        background(color(255, 255, 255));
        size(CANVAS_WIDTH, CANVAS_HEIGHT);
        frameRate(FPS);

        // Play music
        backgroundMusic.volume = 1.0;
        backgroundMusic.play();
}

// Driver function for animations
void draw() {
        // Update universe time
        // console.display();
};

// Base class for celestials: Star, Planet, Spaceship, etc.
function Celestial(x, y, r, velX, velY, density, aColor) {
        this.name = "Celestial";
        this.x = x;
        this.y = y;
        this.velX = velX;
        this.velY = velY;
        this.r = r;
        this.color = aColor;
        this.density = density;
        this.volume = (4/3) * Math.PI * Math.pow(this.r, 3);
        this.mass = this.density * this.volume;

        // Compute next position of planet given current
        // net acceleration from other celestials.
        this.move = function(acc) {
                var accX = acc[0];
                var accY = acc[1];

                this.velX += accX;
                this.velY += accY;

                this.x += this.velX;
                this.y += this.velY;
        };
        // On screen
        this.display = function() {
                fill(this.color);
                ellipse(this.x, this.y, this.r*2, this.r*2);
                fill(this.color + 20);
                ellipse(this.x, this.y, this.r*2/100, this.r*2/100);
        }
        this.destroy = function() {
        }
}

function Point(x, y) {
        this.x = x;
        this.y = y;
        this.r = TARGET_RADIUS;
        this.color = TARGET_COLOR;
        this.display = function() {
                noStroke();
                fill(this.color);
                ellipse(this.x, this.y, this.r*2, this.r*2);
        }
}

function NullCelestial() {
        this.name = "";
        this.x = 0;
        this.y = 0;
        this.velX = 0;
        this.velY = 0;
        this.r = 0;
        this.color = 0;
        this.density = 0;
        this.volume = 0;
        this.mass = 0;
        this.display = function() {
        };
        this.move = function(acc) {
        };
        this.destroy = function() {
        }
}

function Missile(x, y, velX, velY) {
        this.name = "Missle";
        this.x = x;
        this.y = y;
        this.velX = velX;
        this.velY = velY;
        this.color = ROCKET_COLOR;
        this.r = ROCKET_RADIUS;
        this.density = ROCKET_DENSITY;
        this.volume = (4/3) * Math.PI * Math.pow(this.r, 3);
        this.mass = this.density * this.volume;
        this.thrust = ROCKET_THRUST;
        this.power = ROCKET_POWER;

        // TODO?
        this.isSelfGuided = false;

        this.move = function(acc) {
                var accX = acc[0];
                var accY = acc[1];

                this.velX += accX;
                this.velY += accY;

                this.x += this.velX;
                this.y += this.velY;
        }
        this.display = function() {

                // Travel angle
                var theta = Math.atan(this.velY/this.velX) + 2 * Math.PI;
                if (this.velX < 0) { theta += Math.PI; }
                else if (this.velY < 0) { theta += 2 * Math.PI; }
                var vel = Math.sqrt(Math.pow(this.velX, 2) + Math.pow(this.velY, 2));
                theta += Math.PI;
                // Tail
                stroke(this.color);
                strokeWeight(3);
                line(this.x, this.y, this.x + 15 * Math.cos(theta), this.y + 15 * Math.sin(theta));
                // Head
                noStroke();
                fill(color(100, 200, 200));
                ellipse(this.x, this.y, this.r, this.r);
        }
        this.destroy = function() {
        }
}

// Object to be grouped/linked list with other friends
// Want to have them create random and interesting geometric structures and help you do tasks
// Each friend moves with respect to the next one
// TODO Move to being a double-linked list
function Friend(x, y, r, velX, velY, density, aColor) {
        this.name = "Friend";
        // Points to next friend in list
        this.next = null;
        this.previous = null;
        // TODO Decrement this every move, and send a "packet" to next when == 0!
        this.packetTimer = 100;

        this.x = x;
        this.y = y;
        this.velX = velX;
        this.velY = velY;
        this.color = color(20, 200, 20);
        this.r = r;
        this.density = density;
        this.volume = (4/3) * Math.PI * Math.pow(this.r, 3);
        this.mass = this.density * this.volume;

        this.move = function(acc) {
                // Get acceleration components
                var accX = acc[0];
                var accY = acc[1];

                // Follow next friend
                // TODO Fix the error of this.next being null
                if (this.next) {
                     accX += (this.next.x - this.x) / Math.pow(10, 5);
                     accY += (this.next.y - this.y) / Math.pow(10, 5);
                }

                // Velocity
                this.velX += accX;
                this.velY += accY;

                // Now move
                this.x += this.velX;
                this.y += this.velY;
        }
        this.display = function() {
                // Draw line to next, if we can
                if (this.next) {
                        stroke(color(255, 255, 255));
                        strokeWeight(1);
                        line(this.x, this.y, this.next.x, this.next.y);
                }
                // Draw them as squares
                strokeWeight(3);
                fill(this.color);
                rect(this.x - this.r / 2, this.y - this.r /2, this.r * 2, this.r * 2);
        }
        this.destroy = function() {
                if (this.previous) { this.previous.next = this.next; }
                // We are root
                else {

                }
        }
}

// Spaceship constructor
function Spaceship(universe, x, y, r, velX, velY, density, aColor) {
        this.name = "Spaceship";
        // Awareness of universe
        this.universe = universe;
        // Array containing all of the other celestials
        // which affect our movement.
        this.celestials = [];

        this.x = x;
        this.y = y;
        this.velX = velX;
        this.velY = velY;
        this.color = SHIP_COLOR; //aColor;
        this.r = r;
        this.density = density;
        this.volume = (4/3) * Math.PI * Math.pow(this.r, 3);
        this.mass = this.density * this.volume;
        this.fuel = 100;
        this.thrust = SPACESHIP_THRUST;
        this.isThrustUp = false;
        this.isThrustDown = false;
        this.isThrustLeft = false;
        this.isThrustRight = false;
        this.missleCount = MISSILE_COUNT;
        this.missleGap = ROCKET_FRAME_SPACE;

        // Magnitude in meters/sec
        this.getVelocity = function() {
                return Math.round(Math.sqrt(Math.pow(this.velX, 2), Math.pow(this.velY, 2)));
        }
        this.getFuelPercentage = function() {
                return float(this.fuel / 100);
        }
        this.getMissleCount = function() {
                return this.missleCount;
        }
        this.getHeadAngle = function() {

        }
// Shoot shit
        this.fire = function() {
                // NOTE Create new missle with relative velocity
                if (this.missleCount <= 0) { return; }
                // Make sure we aren't shooting too fast
                if (this.missleGap != 0) { return; }

                // Timing between missile fires
                this.missleGap = ROCKET_FRAME_SPACE;

                // Travel angle
                var theta = Math.atan(this.velY/this.velX) + 2 * Math.PI;
                if (this.velX < 0) { theta += Math.PI; }
                else if (this.velY < 0) { theta += 2 * Math.PI; }

                // Add missle to universe
                this.universe.addCelestial(this.universe.CelestialeEnum.MISSLE, this.x, this.y, this.velX + ROCKET_VELOCITY * Math.cos(theta), this.velY + ROCKET_VELOCITY * Math.sin(theta), ROCKET_DENSITY, ROCKET_COLOR);

                // Update missle count
                this.missleCount--;

                // Play sound
                shootSound.play();
        }
        // Spaceship itself determines how it will move given
        // its surroundings, similar to actual conditions
        this.chart = function() {
                // Prediction "orb" kickoff properties
                var orbX = this.x;
                var orbY = this.y;
                var orbVelX = this.velX;
                var orbVelY = this.velY;
                var orbDensity = this.density;
                var orbColor = color(255, 255, 255);
                var orbR = 3;

                var pastShownOrbX = orbX;
                var pastShownOrbY = orbY;

                // Number of prediction orbs displayed
                var CAP = 200;
                var DESIRED_NUM_ORBS = 20;
                var i = 0; j = 0;
                while (i < CAP || j < DESIRED_NUM_ORBS) {
                        // NOTE Copied from Universe object => Redundancy!
                        // Current acceration on orb
                        var netAccX = 0, netAccY = 0;
                        int k = 0;
                        while (k < this.celestials.length) {
                                // Another celestial
                                var cel = this.celestials[k];

                                // Distance apart
                                var diffX = orbX - cel.x;
                                var diffY = orbY - cel.y;
                                var d = Math.sqrt(Math.pow(diffX, 2) + Math.pow(diffY, 2));

                                // Angle with respect to this
                                var theta = Math.atan(diffY/diffX) + Math.PI;
                                if (diffX < 0) { theta += Math.PI; }
                                else if (diffY < 0) { theta += 2 * Math.PI; }

                                // Acceleration
                                var acc = universe.G * cel.mass / Math.pow(d, 2);
                                var accX = acc * Math.cos(theta);
                                var accY = acc * Math.sin(theta);

                                // Accumulate
                                netAccX += accX;
                                netAccY += accY;

                                // NOTE: Assume for the entire prediction no other celestial is moving,
                                // so we have a snapshot of the universe. We render according to that,
                                // considering our spaceship is moving.

                                k++;
                        }

                        // Endpoint
                        if (j == (DESIRED_NUM_ORBS - 1)) {
                                stroke(TARGET_COLOR);
                                strokeWeight(2);
                                var dist = TARGET_RADIUS / Math.sqrt(2);
                                line(orbX - dist, orbY - dist, orbX + dist, orbY + dist);
                                line(orbX - dist, orbY + dist, orbX + dist, orbY - dist);

                                return;
                                // Innerpoint
                        } else {
                                // Distance between shown orbs must have a min spacing
                                var d = Math.sqrt(Math.pow((pastShownOrbX - orbX), 2) + Math.pow((pastShownOrbY - orbY), 2));
                                var MIN_ORB_DIFF = 30;

                                if (d > MIN_ORB_DIFF) {
                                        // Display
                                        noStroke();
                                        fill(orbColor);
                                        ellipse(orbX, orbY, orbR, orbR);

                                        // Repeat
                                        pastShownOrbX = orbX;
                                        pastShownOrbY = orbY;

                                        // Increment num orbs
                                        j++;
                                }
                                // Move
                                orbVelX += netAccX;
                                orbVelY += netAccY;

                                orbX += orbVelX;
                                orbY += orbVelY;
                        }
                        // Increment
                        i++;
                }
        }
        // Move spaceship
        this.move = function(acc) {
                // Get acceleration components
                var accX = acc[0];
                var accY = acc[1];

                // Spaceship velocity
                this.velX += accX;
                this.velY += accY;

                // Spaceship next position
                this.x += this.velX;
                this.y += this.velY;

                // Update missle fire gap
                if (this.missleGap > 0) { this.missleGap--; }

                // Play thrust sound
                if (this.isThrustUp === true || this.isThrustRight === true || this.isThrustDown === true || this.isThrustLeft === true) {
                        thrustSound.play();
                }
        };
        this.canThrust = function() {
                if (this.getFuelPercentage() <= 0) { return false; }
                return true;
        }
        this.thrustUp = function() {
                if (this.canThrust() == false) { return; }
                this.velY += -this.thrust / this.mass;
                this.isThrustUp = true;
        }
        this.thrustDown = function() {
                if (this.canThrust() == false) { return; }
                this.velY += this.thrust / this.mass;
                this.isThrustDown = true;
        }
        this.thrustLeft = function() {
                if (this.canThrust() == false) { return; }
                this.velX += -this.thrust / this.mass;
                this.isThrustLeft = true;
        }
        this.thrustRight = function() {
                if (this.canThrust() == false) { return; }
                this.velX += this.thrust / this.mass;
                this.isThrustRight = true;
        }
        // Display spaceship
        this.display = function() {

                // Predicted route
                if (chartMode == true) { this.chart(); }
                
                // TODO: Get rid of the bloody if-else statements!

                // Thrust
                noStroke();
                fill(237, 17, 7);
                var thrustAngle = -1; // Radians
                if (this.isThrustUp == true) {
                        if (this.isThrustRight == true) {
                                thrustAngle = Math.PI / 4;
                                ellipse(this.x - (this.r * 0.5), this.y + (this.r * 0.5), this.r * 2, this.r * 2);
                        } else if (this.isThrustLeft == true) {
                                thrustAngle = (3 / 4) * Math.PI;
                                ellipse(this.x + (this.r * 0.5), this.y + (this.r * 0.5), this.r * 2, this.r * 2);
                        } else {
                                thrustAngle = Math.PI / 2;
                                ellipse(this.x, this.y + (this.r * 0.5), this.r * 2, this.r * 2);
                        }
                } else if (this.isThrustDown == true) {
                        if (this.isThrustRight == true) {
                                thrustAngle = -Math.PI / 4;
                                ellipse(this.x - (this.r * 0.5), this.y - (this.r * 0.5), this.r * 2, this.r * 2);
                        } else if (this.isThrustLeft == true) {
                                thrustAngle = -(3 / 4) * Math.PI;
                                ellipse(this.x + (this.r * 0.5), this.y - (this.r * 0.5), this.r * 2, this.r * 2);
                        } else {
                                thrustAngle = -Math.PI / 2;
                                ellipse(this.x, this.y - (this.r * 0.5), this.r * 2, this.r * 2);
                        }
                } else {
                        if (this.isThrustLeft == true) {
                                thrustAngle = Math.PI;
                                ellipse(this.x + (this.r * 0.5), this.y, this.r * 2, this.r * 2);
                        } else if (this.isThrustRight == true) {
                                thrustAngle = 0;
                                ellipse(this.x - (this.r * 0.5), this.y, this.r * 2, this.r * 2);
                        }
                }
                // Check if fuel has been used
                if (thrustAngle != -1) { this.fuel -= 0.1; }

                // Spaceship head
                fill(color(255, 255, 255));
                ellipse(this.x, this.y, this.r*2, this.r*2);

                // Tail
                var theta = Math.atan(this.velY/this.velX) + Math.PI;
                if (this.velX < 0) { theta += Math.PI; }
                else if (this.velY < 0) { theta += 2 * Math.PI; }
                theta += Math.PI;
                fill(color(0, 191, 255));
                ellipse(this.x + this.r * Math.cos(theta), this.y + this.r * Math.sin(theta), this.r/2, this.r/2);

                // Reset thrusters
                this.isThrustUp = false;
                this.isThrustDown = false;
                this.isThrustLeft = false;
                this.isThrustRight = false;
        };

        this.destroy = function() {
        }
}

// Star constructor
function Star(x, y, r, velX, velY, density, aColor) {
        this.name = "Star";
        this.x = x;
        this.y = y;
        this.velX = velX;
        this.velY = velY;
        this.r = r;
        this.color = STAR_COLOR;
        this.density = density;
        this.volume = (4/3) * Math.PI * Math.pow(this.r, 3);
        this.mass = this.density * this.volume;
        this.pulseAngle = 0;

        // Star animation
        this.pulsate = function() {
                var radOne = this.r * Math.sin(this.pulseAngle);
                var radTwo = Math.pow(radOne, 1.5);
                noStroke();
                fill(color(radOne, radOne, radOne/2));
                ellipse(this.x, this.y, radOne, radOne);
                fill(color(radTwo, radTwo, radTwo/2));
                ellipse(this.x, this.y, radTwo, radTwo);
                // Sun's core
                fill(color(255, 255, 0));
                ellipse(this.x, this.y, this.r*2, this.r*2);

                this.pulseAngle += 1/(16*Math.PI);
        }
        this.move = function(acc) {
                // Acceleration components computed
                // but universe.
                var accX = acc[0];
                var accY = acc[1];

                // Star velocity
                this.velX += accX;
                this.velY += accY;

                // Star next position
                this.x += this.velX;
                this.y += this.velY;
        };
        this.display = function() {
                // Star draw
                //this.pulsate();
                noStroke();
                fill(this.color);
                ellipse(this.x, this.y, r*2, r*2);
        };

        this.destroy = function() {
        }
}

// Planet constuctor
function Planet(x, y, r, velX, velY, density, aColor) {
        this.name = "Planet";
        this.x = x;
        this.y = y;
        this.velX = velX;
        this.velY = velY;
        this.r = r;
        this.color = PLANET_COLOR;//aColor;
        this.density = density;
        this.volume = (4/3) * Math.PI * Math.pow(this.r, 3);
        this.mass = this.density * this.volume;
        // Render next frame of planet given current
        // net acceleration computed by universe.
        this.move = function(acc) {
                // Get acceleration components
                var accX = acc[0];
                var accY = acc[1];

                // Planet velocity
                this.velX += accX;
                this.velY += accY;

                // Planet next position
                this.x += this.velX;
                this.y += this.velY;

        };
        this.display = function() {
                // Planet draw!
                noStroke();
                fill(this.color);
                ellipse(this.x, this.y, this.r*2, this.r*2);
                fill(this.color + 20);
                ellipse(this.x, this.y, this.r*2/100, this.r*2/100);
        };

        this.destroy = function() {
        }
}

// -- DUMP --
// TODO: Deeply integrate polymorphism and design patterns
// TODO Give Planet object shards[], which stores tiny planets broken off from
// a collision.
// TODO Give .move() functions an argument, with default argument as 1, representing Number
// of frames to project forwards
// TODO GetCelestialRelation() for universe which returns an associative array that gives all data
// currently needed between two celestials: distance, force, diffX, diffY, etc.
// TODO planetAdjust() that sets collided objects in a minimal safe space.
// TODO Render accurate collisions, with respect to contact angle.
// TODO Add generic addCelestial() function, b/c all this code looks redundant
// TODO Have all celestials inherit from Celestials object

// Skeleton for all simulations
function Simulation(argv) {
        this.getStats = function() {

        }
        this.move = function() {

        }
        this.display = function() {

        }
};

// Universe constructor
//    1) Declare variables
//    2) Declare functions
//    3) Populate universe
function Universe(numStars, numPlanets, numAsteroids, catalyze) {     // All else is randomized
        this.name = "Universe";

        // Stores our planets, asteroids, spaceships, and stars.
        this.celestials = [];
        // Just for looks
        this.backgroundStars = [];
        // Gravitational constant
        this.G = 6.674 * Math.pow(10, -11);

        // Constructor vars to member
        this.numStars = numStars;
        this.numPlanets = numPlanets;
        this.numAsteroids = numAsteroids;
        this.catalyze = catalyze;
        this.greatestMass = 0; // Sets the weighted force web context

        // Spaceship stuff
        this.spaceshipColor = color(0, 0, 0);
        this.spaceshipDensity = 1;
        this.spaceshipRadius = SPACESHIP_R; // baseline radius for star
        this.spaceshipVelocity = this.catalyze*8;
        // Star attributes
        this.starColor = color(255, 255, 0);
        this.starDensity = Math.pow(10, 8);
        this.starRadius = CANVAS_WIDTH/8; // baseline radius for star
        this.starVelocity = this.catalyze/2;
        // Planet atributes
        this.planetColor = getRandColor(255);
        this.planetDensity = 8;
        this.planetRadius = CANVAS_WIDTH/30;
        this.planetVelocity = this.catalyze*1.5; // in meters/sec
        // Asteroid attributes
        this.asteroidColor = color(150, 150, 150);
        this.asteroidDensity = 6;
        this.asteroidRadius = CANVAS_WIDTH/256;
        this.asteroidVelocity = this.catalyze*4;

        // Keep list of base celestials
        var CelestialEnum = {
            PLANET : 0,
            ASTEROID : 1,
            STAR : 2,
            SPACESHIP : 3,
            FRIEND : 4
            MISSLE : 5
        };
        // Declaring celestial factory
        function celestialFactory() {};
        celestialFactory.prototype.createCelestial = function createCelestial(options) {
            var parentClass = null;

            switch (options.type) {
            case CelestialEnum.PLANET: { parentClass = Planet; break; }
            case CelestialEnum.STAR: { parentClass = Star; break; }
            case CelestialEnum.SPACESHIP: { parentClass = Spaceship; break; }
            case CelestialEnum.FRIEND: { parentClass = Friend; break; }
            case CelestialEnum.MISSLE: { parentClass = Missle; break; }
            default: {
                alert("Error: case default!");
                return false;
            }
            }

            return new parentClass(options.x, options.y, options.r, options.velX, options.velY, options.density, options.color);
        };         
        // Instantiating celestial factory
        var factory = new celestialFactory();

        // Friend stuff
        this.rootFriend = null;

        // TODO : Assign each enum type with its corresponding velocity, radius, and color? (in form of JSON)

        this.addCelestial = function(celType, x, y, r, velX, velY, density, color) {
            // Create celestial with factory
                var celestial = factory.createCelestial({
                    type : celType,
                    r : r,
                    x : x,
                    y : y,
                    velX : velX,
                    velY : velY,
                    density : density,
                    color : color       
                });               

                // Add to universe
                this.celestials.push(celestial);
                this.updateGreatestMass(celestial);
        };
        // TODO Perhaps replace with some kind of template
        this.addRandomCelestial = function(celType, r, vel, density, color) {
                // Generate random variables
                // TODO: Rename for naming conflicts in JSON?
                var tempPos = this.getRandomPosition();
                var tempX = tempPos[0];
                var tempY = tempPos[1];
                var tempVelX = random(vel) - vel / 2;
                var tempVelY = random(vel) - vel / 2;
                var tempR = random(r);

                // Check if plausible placement
                if (this.canISpawn(tempX, tempY, tempR) === false) { return new NullCelestial(); }

                // Delegate adding to universe
                this.addCelestial(celType, tempX, tempY, tempVelX, tempVelY, density, color);

                // Return created celestial
                return celestial;
        }
        // For adding asteroids (which have slightly different properties from planets)
        this.addAsteroid = function() {
                /*
                var pos = this.getRandomPosition();
                var x = pos[0];
                var y = pos[1];
                velX = random(this.asteroidVelocity) - this.asteroidVelocity / 2;
                velY = random(this.asteroidVelocity) - this.asteroidVelocity / 2;
                r = random(this.asteroidRadius);
                // Check if plausible placement
                if (this.canISpawn(x, y, r) === false) { return; }
                var planet = new Planet(x, y, r, velX, velY, this.asteroidDensity, this.asteroidColor);
                this.celestials.push(planet);
                this.updateGreatestMass(planet);
                */
                // TODO: Something like this: "this.addRandomCelestial(CelestialEnum.PLANET, this.Asteroid.r, this.Asteroid.v, ...)", and a JSON type with this.Asteroid is passed to a function. I'm not thinking clearly, atm.
                this.addRandomCelestial(CelestialEnum.PLANET, this.asteroidRadius, this.asteroidVelocity, this.asteroidDensity, this.asteroidColor);
        }
        this.addPlanet = function() {
                /* PAST STUFF
                var pos = this.getRandomPosition();
                var x = pos[0];
                var y = pos[1];
                velX = random(this.planetVelocity) - this.planetVelocity / 2;
                velY = random(this.planetVelocity) - this.planetVelocity / 2;
                r = random(this.planetRadius);
                // Check if plausible placement
                if (this.canISpawn(x, y, r) === false) { return; }
                var asteroid = new Planet(x, y, r, velX, velY, this.planetDensity, this.planetColor);
                this.celestials.push(asteroid);
                this.updateGreatestMass(asteroid);
                */
                this.addRandomCelestial(CelestialEnum.PLANET, this.planetRadius, this.planetVelocity, this.planetDensity, this.planetColor);
        }
        this.addStar = function() {
                /*
                var pos = this.getRandomPosition();
                var x = pos[0];
                var y = pos[1];
                velX = random(this.starVelocity) - this.starVelocity / 2;
                velY = random(this.starVelocity) - this.starVelocity / 2;
                r = random(this.starRadius);
                // Check if plausible placement
                if (this.canISpawn(x, y, r) === false) { return; }
                var star = new Star(x, y, r, velX, velY, this.starDensity, this.starColor);
                this.celestials.push(star);
                this.updateGreatestMass(star);
                */
                this.addRandomCelestial(CelestialEnum.STAR, this.starRadius, this.starVelocity, this.starDensity, this.starColor);
        }
        this.addSpaceship = function() {
                /*
                var pos = this.getRandomPosition();
                var x = pos[0];
                var y = pos[1];
                velX = random(this.spaceshipVelocity) - this.spaceshipVelocity / 2;
                velY = random(this.spaceshipVelocity) - this.spaceshipVelocity / 2;
                r = this.spaceshipRadius;//random(this.spaceshipRadius);
                // Check if plausible placement
                if (this.canISpawn(x, y, r) === false) { return; }
                var spaceship = new Spaceship(this, x, y, r, velX, velY, this.spaceshipDensity, this.spaceshipColor);
                this.celestials.push(spaceship);
                this.updateGreatestMass(spaceship);
                */
                this.addRandomCelestial(CelestialEnum.SPACESHIP, this.spaceshipRadius, this.spaceshipVelocity, this.spaceshipDensity, this.spaceshipColor);
        }
        // NOTE Basing it off of spaceship for now
        this.addFriend = function() {
                /*
                var pos = this.getRandomPosition();
                var x = pos[0];
                var y = pos[1];
                velX = random(this.spaceshipVelocity) - this.spaceshipVelocity / 2;
                velY = random(this.spaceshipVelocity) - this.spaceshipVelocity / 2;
                r = this.spaceshipRadius;
                // Check if plausible placement
                if (this.canISpawn(x, y, r) === false) { return; }

                var newFriend = new Friend(x, y, r, velX, velY, this.spaceshipDensity, this.spaceshipColor);
                // Root case
                if (!this.rootFriend) { this.rootFriend = newFriend; }
                // Make sure linked list is maintained
                else {
                        var tempFriend = this.rootFriend;
                        // Get last friend in list
                        while (tempFriend.next) {
                                tempFriend = tempFriend.next;
                        }
                        // Add new friend to end of list
                        tempFriend.next = newFriend;
                        // Linkup new friend with previous friend
                        newFriend.previous = tempFriend;
                }
                // Add friend to universe now
                this.celestials.push(newFriend);
                this.updateGreatestMass(newFriend);
                */
                var newFriend = this.addRandomCelestial(CelestialEnum.FRIEND, this.spaceshipRadius, this.spaceshipVelocity, this.spaceshipDensity, this.spaceshipColor);
                // Root case
                if (!this.rootFriend) { this.rootFriend = newFriend; }
                // Make sure linked list is maintained
                else {
                        var tempFriend = this.rootFriend;
                        // Get last friend in list
                        while (tempFriend.next) {
                                tempFriend = tempFriend.next;
                        }
                        // Add new friend to end of list
                        tempFriend.next = newFriend;
                        // Linkup new friend with previous friend
                        newFriend.previous = tempFriend;
                }
        }
        // TODO If user clicks planet, set that as target planet
        this.getRandomPlanet = function() {

        };
        this.getSpaceship = function() {
                return this.celestials[0];
        }
        // Generic function for simulation to return array of stats for each frame
        this.getStats = function() {
                var stats = [];
                var ss = this.getSpaceship();

                stats.push(this.celestials.length + " celestials");
                stats.push(ss.getMissleCount() + " missles");
                stats.push(Math.round(ss.getFuelPercentage() * 100) + "% fuel");
                stats.push(ss.getVelocity() + " m/s");

                return stats;
        };
        // Greatest mass in universe
        this.updateGreatestMass = function(celestial) {
                if (this.greatestMass < celestial.mass) {
                        this.greatestMass = celestial.mass;
                }
        }
        // Two planets have collided. Get angle of planetB
        // with respect to planetA.
        this.getAngleBetween = function(planetA, planetB) {
                var d = this.getDistance(planetA, planetB);
                var diffX = planetA.x - planetB.x;
                var diffY = planetA.y - planetB.y;

                // Angle with respect to planetA.
                var theta = Math.atan(diffY/diffX) + Math.PI;
                if (diffX < 0) { theta += Math.PI; }
                else if (diffY < 0) { theta += 2 * Math.PI; }

                return theta;
        }
        // Spawning celestials
        this.getRandomPosition = function() {
                return [random(CANVAS_WIDTH), random(CANVAS_HEIGHT)];
        }
        // Space apart collided objects
        this.giveSpace = function(planetA, planetB) {
        }
        this.getDistance = function(planetA, planetB) {
                // Relation to planet
                var diffX = planetA.x - planetB.x;
                var diffY = planetA.y - planetB.y;
                var d = Math.sqrt(Math.pow(diffX, 2) + Math.pow(diffY, 2));

                return d;
        }
        // Checks if potential planet will overlap preexisting planets.
        this.canISpawn = function(planetX, planetY, planetRadius) {
                // Our test planet, which won't actually be used
                // if a planet with these properties is valid to
                // spawn.
                var testPlanet = new Planet(planetX, planetY, planetRadius, 0, 0, 0, 0);
                for (k = 0; k < this.celestials.length; k++) {
                        var existingPlanet = this.celestials[k];
                        if (this.collisionHandler(testPlanet, existingPlanet) === true) { return false; }
                }

                return true;
        }
        // Check if two planets have collided, returning one of the following:
        //  0) No collision
        //  1) Planet collision
        //  2) Boundary collision
        //  3) Missile collision
        //  4) Star collision
        this.collisionHandler = function(celestialA, celestialB) {
                // Boundary collision
                if (((celestialA.x + celestialA.r) > CANVAS_WIDTH)
                    || ((celestialA.x - celestialA.r) < 0)
                    || ((celestialA.y + celestialA.r) > CANVAS_HEIGHT)
                    || ((celestialA.y - celestialA.r) < 0)) {
                        /*
                           // Component differences
                           var diffX = planetA.x - planetB.x;
                           var diffY = planetA.y - planetB.y;

                           // Just invert the velocity
                           planetA.velX *= -1;
                           planetA.velY *= -1;

                           // Angle with respect to planetA.
                           var theta = Math.atan(diffY/diffX) + Math.PI;
                           if (diffX < 0) { theta += Math.PI; }
                           else if (diffY < 0) { theta += 2 * Math.PI; }

                           // Give safe space
                           var angle = this.getAngleBetween(planetA, planetB);
                           // According to this angle, push out planetA +5 the planetDist, using trig!
                           var pushDist = 1;
                           planetA.x += pushDist*cos(angle);
                           planetA.y += pushDist*sin(angle);
                         */
                        return 2;
                }

                // Celestial collision
                var d = this.getDistance(celestialA, celestialB);
                if ((d - celestialA.r - celestialB.r) < 0) {
                        // Missile collision
                        if (celestialA instanceof Missile)
                        {
                                // Missle doesn't affect spaceship itself
                                if (celestialB instanceof Spaceship) { return 0; }

                                return 3;
                        }
                        // Star collsion
                        if (celestialA instanceof Star) { return 4; }

                        // Angle to push other planet away
                        //var angle = this.getAngleBetween(planetA, planetB);
                        var diffX = celestialA.x - celestialB.x;
                        var diffY = celestialA.y - celestialB.y;

                        // Angle with respect to planetA.
                        var theta = Math.atan(diffY/diffX) + Math.PI;
                        if (diffX < 0) { theta += Math.PI; }
                        else if (diffY < 0) { theta += 2 * Math.PI; }

                        // Display push animation
                        fill(color(200, 100, 250));
                        ellipse(celestialB.x + (10 * Math.cos(theta)), celestialB.y + (10 * Math.sin(theta)), celestialB.r*2, celestialB.r*2);

                        // Push two celestials apart
                        var repulsiveForce = (celestialB.mass / Math.pow(10, 7));
                        celestialB.velX += repulsiveForce * Math.cos(theta);
                        celestialB.velY += repulsiveForce * Math.sin(theta);

                        // According to this angle, push out planetA +5 the planetDist, using trig!
                        // var pushDist = planetB.r;
                        // planetB.x += pushDist * cos(theta);
                        // planetB.y += pushDist * sin(theta);

                        // Elastic collision, momentum conserved
                        //planetA.velX = (planetA.velX * (planetA.mass - planetB.mass) + 2 * planetB.mass * planetB.velX) / (planetA.mass + planetB.mass);
                        //planetA.velY = (planetA.velY * (planetA.mass - planetB.mass) + 2 * planetB.mass * planetB.velY) / (planetA.mass + planetB.mass);

                        // Planet collision
                        return 1;
                }

                // No collision
                return 0;
        }
        this.debugLog = function() {
                for (var i = 0; i < this.celestials.length; i++)
                {
                        print(this.celestials[i].name + "\t");
                }
                println("\n--------------------------\n");

                return;
        };
        // Remove celestial from universe
        this.destroy = function(celestial) {
                // Don't destroy spaceship or star
                if (celestial instanceof Spaceship || celestial instanceof Star) { return; }
                // Search for celestial to destroy
                for (var i = 0; i < this.celestials.length; i++)
                {
                        if (this.celestials[i] === celestial) {
                                celestial.color = color(0, 255, 0);
                                // TODO Fix error with splicing
                                //this.celestials.splice(i, 1);
                                // Have celestial handle destruction cleanup
                                this.celestials[i].destroy();
                                // For now, we just nullify the celestial
                                this.celestials[i] = new NullCelestial();

                                return;
                        }
                }
        };
        // Turn celestial into lots of small bits
        this.fragmentize = function(celestial) {
                // Destroy really small celestials
                if (celestial.r < 5) { this.destroy(celestial); return; }

                var numFrags = random(5) + 2;

                // Copy celestial
                var celestialModel = jQuery.extend(true, {}, celestial);
                celestialModel.color = color(255, 0, 255);

                // Destroy original celestial
                this.destroy(celestial);

                // Generate fragments
                for (var i = 0; i < numFrags; i++) {
                        // Deep copy of original
                        var fragmentCelestial = jQuery.extend(true, {}, celestialModel);
                        // Modify
                        fragmentCelestial.r = celestialModel.r / numFrags;
                        fragmentCelestial.x += random(2) + 1;
                        fragmentCelestial.y += random(2) + 1;
                        // Initiate
                        this.celestials.push(fragmentCelestial);
                }
                                
                

                // Play sound
                fragmentizeSound.play();
        };
        // Given two masses, compute the acceleration of the first.
        this.getPairAcc = function(celestialA, celestialB) {
                // Distance apart
                var diffX = celestialA.x - celestialB.x;
                var diffY = celestialA.y - celestialB.y;
                var d = Math.sqrt(Math.pow(diffX, 2) + Math.pow(diffY, 2));

                // Angle with respect to first param
                var theta = Math.atan(diffY/diffX) + Math.PI;
                if (diffX < 0) { theta += Math.PI; }
                else if (diffY < 0) { theta += 2 * Math.PI; }

                // Planet acceleration
                var acc = this.G * celestialB.mass / Math.pow(d, 2);
                var accX = acc * Math.cos(theta);
                var accY = acc * Math.sin(theta);

                // Planet force!
                var force = acc * celestialA.mass;

                // Get type of collision (including "no colision")
                var collisionReport = this.collisionHandler(celestialA, celestialB);
                if (collisionReport === 1) { // Planet collision

                } else if (collisionReport === 2) { // Boundary collision
                        // Remove planets not in the canvas scope
                        if (!(celestialA instanceof Spaceship)) { this.destroy(celestialA); }
                        // Display spaceship boundary indicators
                        else {
                                // Position of indicator
                                var xIndicator, yIndicator;
                                // Width and height of indicator
                                var wIndicator, hIndicator;

                                // Y indicator location
                                if (celestialA.y > CANVAS_HEIGHT) {
                                        yIndicator = CANVAS_HEIGHT;
                                        // Make width proportional to distance off screen
                                        wIndicator = Math.abs(CANVAS_HEIGHT - celestialA.y);
                                } else if (celestialA.y < 0) {
                                        yIndicator = 0;
                                        wIndicator = Math.abs(0 - celestialA.y);
                                } else {
                                        yIndicator = celestialA.y;
                                        wIndicator = 10;
                                }

                                // X indicator location
                                if (celestialA.x > CANVAS_WIDTH) {
                                        xIndicator = CANVAS_WIDTH;
                                        hIndicator = Math.abs(CANVAS_WIDTH - celestialA.x);
                                } else if (celestialA.x < 0) {
                                        xIndicator = 0;
                                        hIndicator = Math.abs(0 - celestialA.x);
                                } else {
                                        xIndicator = celestialA.x;
                                        hIndicator = 10;
                                }

                                // TODO Fix edge cases

                                // Display indicator
                                fill(color(255, (50 - 0), (50 - 0)));
                                rect(xIndicator - (wIndicator / 2), yIndicator - (hIndicator / 2), wIndicator, hIndicator);
                        }
                } else if (collisionReport === 3) { // Explosive collision
                        // Visual debugging
                        fill(color(100, 50, 20));
                        ellipse(celestialA.x, celestialA.y, celestialA.r*4, celestialA.r*4);

                        // Destroy celestialA (missile)
                        this.destroy(celestialA);

                        // Breakup celestialB (collided planet) into randomized fragments
                        this.fragmentize(celestialB);

                        // Display explosion animation
                        fill(color(180, 70, 70));
                        var explRad = random(100);
                        ellipse(celestialA.x, celestialA.y, explRad, explRad);

                } else if (collisionReport == 4) { // Star collision
                        // Destroy celestialB (celestial)
                        this.destroy(celestialB);

                        // Grow sun... for fun
                        celestialA.r++;
                }

                // Display weighted gravity web, if mode is on
                if (gravityDisplayMode == true) {
                        // Line between weighted with magnitude of force
                        stroke(230, 230, 230);
                        strokeWeight(Math.pow(force, 1/4));
                        line(celestialA.x, celestialA.y, celestialB.x, celestialB.y);

                        // Reset stroke
                        stroke(255, 255, 255);
                        strokeWeight(1);
                }

                return [accX, accY];
        }
        // Get net x and y accelerations of planet
        // with respect to universe cog and other planets.
        this.getNetAcc = function(celestialIndex) {
                var netAcc = [0, 0];
                var celestial = this.celestials[celestialIndex];

                // Skip nulls
                if (celestial instanceof NullCelestial) { return; }

                // Add planets to net acceleration
                for (j = 0; j < this.celestials.length; j++) {
                        if (j !== celestialIndex) {
                                var otherCelestial = this.celestials[j];

                                if (otherCelestial instanceof NullCelestial) { continue; }

                                var acc = this.getPairAcc(celestial, otherCelestial);
                                netAcc[0] += acc[0];
                                netAcc[1] += acc[1];
                        }
                }

                return netAcc;
        }
        // Create random background of stars
        this.generateBackground = function() {
                // Spawn 10 to 30 stars
                for (var i = 0; i < (random(20) + 10); i++) {
                        var randPos = this.getRandomPosition();
                        var randRad = random(2) + 1;
                        this.backgroundStars.push(new Star(randPos[0], randPos[1], randRad, 0, 0, 0, (BG_COLOR + 10)));
                }
        }
        // Render frame in universe
        this.move = function() {
                // Render background stars
                for (var i = 0; i < this.backgroundStars.length; i++) {
                        this.backgroundStars[i].display();
                }

                // Log stuff
                //this.debugLog();

                var spaceship = this.celestials[0];
                var spaceshipNetAcc = this.getNetAcc(0);
                // Update spaceship's awareness of other celestials
                spaceship.celestials = this.celestials.slice(1, this.celestials.length);

/*
            fill(255, 0, 0);
            stroke(255, 0, 0);
            strokeWeight(5);

            // Weighted masses
            var sumMass = 0, iGravityX = 0, iGravityY = 0;

            for (var i = 0; i < this.celestials.length; i++) {
                  var cel = this.celestials[i];
                  sumMass += cel.mass;
            }

            for (var i = 0; i < this.celestials.length; i++) {
                  var cel = this.celestials[i];
                  iGravityX += (cel.mass / sumMass) * cel.x;
                  iGravityY += (cel.mass / sumMass) * cel.y;
            }

            ellipse(iX, iY, 20, 20);
            line(spaceship.x, spaceship.y, iGravityX, iGravityY);
            fill(0, 0, 255);
            stroke(0, 0, 255);

            var accX = spaceshipNetAcc[0];
            var accY = spaceshipNetAcc[1];
            var forceX = spaceship.mass * accX;
            var forceY = spaceship.mass * accY;

            var iX = spaceship.x + forceX;
            var iY = spaceship.y + forceY;

            ellipse(iX, iY, 20, 20);
            line(spaceship.x, spaceship.y, iX, iY);

            noStroke();
            fill(255, 102, 0);

            // Example 1
            var nextX = spaceship.x;
            var nextY = spaceship.y;
            var nextVelX = spaceship.velX;
            var nextVelY = spaceship.velY;
            for (var i = 0; i <= 100; i++) {
                  // Projected velecity for given frame i
                  nextVelX += accX*2;
                  nextVelY += accY*2;

                  // Projected position
                  nextX += nextVelX;
                  nextY += nextVelY;

                  if ((i % (100 / 10)) == 0) {
                        ellipse(nextX, nextY, spaceship.r/2, spaceship.r/2);
                  }
                  else {
                        ellipse(nextX, nextY, spaceship.r/4, spaceship.r/4);
                  }
            }

            // Example 2
            nextX = spaceship.x;
            nextY = spaceship.y;
            nextVelX = spaceship.velX;
            nextVelY = spaceship.velY;
            for (var i = 0; i <= 100; i++) {
                  // Projected velecity for given frame i
                  nextVelX += accX*2;
                  nextVelY += accY*2;

                  // Projected position
                  nextX += nextVelX;
                  nextY += nextVelY;

                  if ((i % (100 / 10)) == 0) {
                        ellipse(nextX, nextY, spaceship.r/2, spaceship.r/2);
                  }
                  else {
                        ellipse(nextX, nextY, spaceship.r/4, spaceship.r/4);
                  }
            }

 */
                // Mission stuff
                this.targetPlanet = this.getRandomPlanet();

                // Handle shooting
                if (spaceKeyDown == true) {
                        spaceship.fire();
                }
                // Handle spaceship thrust
                if (upKeyDown == true && downKeyDown == false) {
                        spaceship.thrustUp();
                }
                if (downKeyDown == true && upKeyDown == false) {
                        spaceship.thrustDown();
                }
                if (leftKeyDown == true && rightKeyDown == false) {
                        spaceship.thrustLeft();
                }
                if (rightKeyDown == true && leftKeyDown == false) {
                        spaceship.thrustRight();
                }

                // Render spaceship
                spaceship.move(spaceshipNetAcc);
                spaceship.display();

                // Project course
                var velPullX = (spaceship.x + spaceship.velX) * 1;
                var velPullY = (spaceship.y + spaceship.velY) * 1;
                var forcePullX = spaceship.x + spaceshipNetAcc[0];
                var forcePullY = spaceship.y + spaceshipNetAcc[1];

                // stroke(255, 102, 0);
                //bezier(spaceship.x, spaceship.y, velPullX, velPullY, velPullX, velPullY, forcePullX, forcePullY);
                // curve(spaceship.x, spaceship.y, velPullX/2, velPullY/2, velPullX*3/4, velPullY*3/4, forcePullX, forcePullY);

                // DEBUG
                // fill(0, 255, 0);
                // line(spaceship.x, spaceship.y, forcePullX, forcePullY);
                // fill(255, 0, 0);
                // line(spaceship.x, spaceship.y, velPullX, velPullY);

                //bezier(planet.x, planet.y, otherPlanet.x, otherPlanet.y, 80);
                // fill(0);
                // int steps = 30;
                // for (int i = 0; i <= steps; i++) {
                // float t = i / float(steps);
                // float x = bezierPoint(planet.x, 0, otherPlanet.x, 0, t);
                // float y = bezierPoint(planet.y, 0, otherPlanet.y, 0, t);
                // ellipse(x, y, 5, 5);
                //

                // Render all celestials
                for (i = 1; i < this.celestials.length; i++) {
                        var celestial = this.celestials[i];
                        // TODO Update to getNetAcc(celestial)
                        var planetNetAcc = this.getNetAcc(i);
                        celestial.move(planetNetAcc);
                        celestial.display();
                }

                // TODO replace with legit end planet
                var startPlanet = this.celestials[0];
                var endPlanet = this.celestials[this.celestials.length - 1];

                // Update stats in HTML console
                /*
                   var ss = this.celestials[0];
                   text("(" + Math.round(ss.x) + ", " + Math.round(ss.y) + ")");
                   $("#statistics #velocity").text(ss.getVelocity());
                   $("#statistics #time").text(jQuery.now());

                   updateMissleDisplay(ss.missleCount);
                   updateFuelDisplay(ss.getFuelPercentage());
                 */

                //$("#statistics #fuel").text(ss.getFuelPercentage());
        };
        this.display = function() {
                // TODO
        }

        // Add spaceship
        this.addSpaceship();
        // Add friends
        for (var i = 0; i < 10; i++) {
                this.addFriend();
        }
        // Generate unique background of stars
        this.generateBackground();
        // Add stars
        for (var i = 0; i < this.numStars; i++) {
                this.addStar();
        }
        // Add planets
        for (var i = 0; i < this.numPlanets; i++) {
                this.addPlanet();
        }
        // Add asteroids
        for (var i = 0; i < this.numAsteroids; i++) {
                this.addAsteroid();
        }
}


// Button base object
function Button(label, aColor, r, x, y, pressAction) {
        this.label = label;
        this.color = aColor;
        this.r = r;
        this.x = x;
        this.y = y;
        this.borderR = 20;

        // Perform some action
        this.pressed = function() {
                pressAction();
        }

        // Display the button
        this.display = function() {
                fill(this.color);
                noStroke();
                rect(this.x - this.r, this.y - this.r, this.r * 2, this.r * 2, this.borderR, this.borderR, this.borderR, this.borderR);
        }
}

/*
      _________________________________
 | | *        *               *| |
 | |   o               *       | |
 | |     **         *          | |
 | |  *      [Universe]    **  | |
 | |     ~  *           ****   | |
 | |  *             O    **    | |
      _________________________________
 | 21:16:34   | Space Console    |
 | 01.01.2016 | Distance/Speed/. |
      _________________________________
 */
function Console(simulation) {

        this.W = CANVAS_WIDTH;
        this.H = CANVAS_HEIGHT;

        this.controls = [];
        this.simulation = simulation;
        this.gridCols = 10;
        this.gridRows = 10;
        this.buttonR = 20;

        // TODO Finish UI controls

        // Add controls
        this.controls.push(new Button("GravityDisplay", color(90, 20, 0), this.buttonR,
                                      this.W - (2 * this.buttonR + 10), (2 * this.buttonR + 10),
                                      function() {
                // Toggle gravity display mode
                gravityDisplayMode = !gravityDisplayMode;
        }));
        this.controls.push(new Button("ChartDisplay", color(0, 90, 20), this.buttonR,
                                      this.W - (2 * this.buttonR + 10), (4 * this.buttonR + 20),
                                      function() {
                chartMode = !chartMode;
        }));
        this.controls.push(new Button("VelocityDisplay", color(20, 0, 90), this.buttonR,
                                      this.W - (2 * this.buttonR + 10), (6 * this.buttonR + 30),
                                      function() {
                velocityDragMode = !velocityDragMode;
        }));
        this.controls.push(new Button("AddPlanet", color(10, 100, 90), this.buttonR,
                                      this.W - (2 * this.buttonR + 10), (8 * this.buttonR + 40),
                                      function() {
                universe.addPlanet();
        }));
        this.controls.push(new Button("DisplayGrid", color(100, 200, 50), this.buttonR,
                                      this.W - (2 * this.buttonR + 10), (10 * this.buttonR + 50),
                                      function() {
                gridMode = !gridMode;
        }));

        // Is point inside object?
        this.isInside = function(x, y, obj) {
                if ((x < (obj.x - obj.r)) || (x > (obj.x + obj.r))) { return false; }
                if ((y < (obj.y - obj.r)) || (y > (obj.y + obj.r))) { return false; }
                return true;
        }
        // Called when user clicks screen
        this.clicked = function(x, y) {
                // NOTE Loop by caching the length of array
                for (var i = 0, len = this.controls.length; i < len; i++) {
                        if (this.isInside(x, y, this.controls[i])) {
                                this.controls[i].pressed();
                                return;
                        }
                }
        }

        // Spaceship info
        this.showStats = function() {
                var stats = this.simulation.getStats();
                var fontHeight = 30;
                var fontWidth = fontHeight / 2; // NOTE Estimate
                var cushionWidth = 20;

                textSize(fontHeight);
                fill(255, 255, 255);

                for (var i = 0; i < stats.length; i++) {
                        var txt = stats[i];
                        text(txt, this.W - (txt.length * fontWidth) - cushionWidth,
                             this.H - ((stats.length - i) * fontHeight));
                }
        }

        this.drawGrid = function() {
                var horSpacing = this.W / this.gridCols;
                var vertSpacing = this.H / this.gridRows;
                var subHorSpacing = horSpacing / this.gridCols;
                var subVertSpacing = vertSpacing / this.gridRows;

                // Line label
                fill(LABEL_COLOR);
                // Grid lines
                stroke(GRID_COLOR);

                // Draw columnsrowY
                for (var i = 0; i < this.gridCols; i++) {
                        var colX = horSpacing * i;
                        // Column label
                        text(colX, colX + (horSpacing * 0.2), 20);
                        // Column line
                        strokeWeight(4);
                        line(colX, 0, colX, this.H);

                        // Draw subcolumns
                        for (var j = 0; j < this.gridCols; j++) {
                                var subColX = colX + (subHorSpacing * j);
                                strokeWeight(1);
                                line(subColX, 0, subColX, this.H);
                        }
                }
                // Draw rows
                for (var i = 0; i < this.gridRows; i++) {
                        var rowY = vertSpacing * i;
                        text(rowY, 10, rowY + (vertSpacing * 0.5));
                        strokeWeight(4);
                        line(0, rowY, this.W, rowY);

                        // Draw subcolumns
                        for (var j = 0; j < this.gridRows; j++) {
                                var subRowY = rowY + (subVertSpacing * j);
                                strokeWeight(1);
                                line(0, subRowY, this.W, subRowY);
                        }
                }
        }

        // Clear whole console with dark gray
        this.clear = function() {
                fill(BG_COLOR);
                rect(0, 0, this.W, this.H); }
        this.display = function() {
                // Hide past frame
                this.clear();

                // Display grid
                if (gridMode == true) { this.drawGrid(); }

                // Display UI controls
                for (var i = 0; i < this.controls.length; i++) { this.controls[i].display(); }

                // Run physics frame
                this.simulation.move();
                this.simulation.display();

                // Display stats to screen
                this.showStats();
        }
}

/* HANDLE USER CONTROLS */
$("body").keydown(function(event) {
        var aKey = event["keyCode"];
        //window.alert(aKey);
        // Spacebar and arrows
        if (aKey == 32) {
                spaceKeyDown = true;
        } else if (aKey == 37) {
                leftKeyDown = true;
        } else if (aKey == 38) {
                upKeyDown = true;
        } else if (aKey == 39) {
                rightKeyDown = true;
        } else if (aKey == 40) {
                downKeyDown = true;
        } else {
                // Stop animating
                noLoop();

                // Show pause
                textSize(200);
                fill(255);
                text("||", 10, 170);

                // Stop music
                backgroundMusic.pause();
        }
});
$("body").keyup(function(event) {
        var aKey = event["keyCode"];
        if (aKey == 32) {
                spaceKeyDown = false;
        } else if (aKey == 37) {
                leftKeyDown = false;
        } else if (aKey == 38) {
                upKeyDown = false;
        } else if (aKey == 39) {
                rightKeyDown = false;
        } else if (aKey == 40) {
                downKeyDown = false;
        } else {
                loop();
                backgroundMusic.play();
        }
});



// Add new planet on mouse click
mouseClicked = function() {
        console.clicked(mouseX, mouseY);
};

// Get random color!
function getRandColor(intensity) {
        return color(random(intensity), random(intensity), random(intensity));
}
