/* MathTrip, created by Luke Weber on 12/01/2015
 *    Uses Newtonian physics to render a universe of stars, planets, asteroids, and spaceships.
 *    Attempting to implement self-guided spaceship to start on one planet and
 *    end on a given target planet, given realistic safe landing velocities. Also working towards
 *    integrating fluid collision detection and missle destruction.
 *
 *    We'll see where this goes.
 */

/* TODO
      - Add trance audio
      - Have objects that allow things to move independently
      - Organize and comment code
      - Upload to GitHub
 */

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
var ROCKET_RADIUS = 5;
var ROCKET_VELOCITY = 10;
var ROCKET_COLOR = color(100, 0, 0);
var ROCKET_THRUST = 100;
var ROCKET_POWER = 20;
var ROCKET_DENSITY = 10;

// Ship
var TARGET_RADIUS = 5;
var TARGET_COLOR = color(255, 255, 255);
var MISSILE_COUNT = 100;
var SPACESHIP_R = 50;
var SPACESHIP_THRUST = 500; // Newtons

// Universe
var NUM_PLANETS = 20;
var NUM_ASTEROIDS = 20;
var NUM_STARS = 1;
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
var chartMode = true;
var velocityDragMode = false;
var gridMode = false;

// Canvas constructor
void setup() {
        // Big bang
        universe = new Universe(NUM_STARS, NUM_PLANETS, NUM_ASTEROIDS, CHAOS_LEVEL);

        // Create console with universe as member
        console = new Console(universe);

        // Set canvas and drawing properties
        background(color(255, 255, 255));
        size(CANVAS_WIDTH, CANVAS_HEIGHT);
        frameRate(FPS);
}

// Driver function for animations
void draw() {
        // Update universe time
        console.display();
};

// Base class for celestials: Star, Planet, Spaceship, etc.
function Celestial(x, y, r, velX, velY, density, aColor) {
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

function Missile(x, y, velX, velY) {
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
                noStroke();
                fill(this.color);
                ellipse(this.x, this.y, this.r*2, this.r*2);
        }

}

// Spaceship constructor
function Spaceship(universe, x, y, r, velX, velY, density, aColor) {
        // Awareness of universe
        this.universe = universe;
        // Array containing all of the other celestials
        // which affect our movement.
        this.celestials = [];

        this.x = x;
        this.y = y;
        this.velX = velX;
        this.velY = velY;
        this.color = SHIP_COLOR;//aColor;
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

                // Travel angle
                var theta = Math.atan(this.velY/this.velX) + 2 * Math.PI;
                if (this.velX < 0) { theta += Math.PI; }
                else if (this.velY < 0) { theta += 2 * Math.PI; }

                var missile = new Missile(this.x, this.y, this.velX + ROCKET_VELOCITY * Math.cos(theta), this.velY + ROCKET_VELOCITY * Math.sin(theta));
                this.universe.addCelestial(missile);
                this.missleCount--;
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

                                // NOTE Assume for the entire prediction no other celestial is moving,
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
        };
        this.canThrust = function() {
                if (Math.round(this.getFuelPercentage()) == 0) { return false; }
                return true;
        }
        this.thrustUp = function() {
                if (this.canThrust() == false) { return; }
                this.move([0, -this.thrust/this.mass]);
                this.isThrustUp = true;
        }
        this.thrustDown = function() {
                if (this.canThrust() == false) { return; }
                this.move([0, this.thrust/this.mass]);
                this.isThrustDown = true;
        }
        this.thrustLeft = function() {
                if (this.canThrust() == false) { return; }
                this.move([-this.thrust/this.mass, 0]);
                this.isThrustLeft = true;
        }
        this.thrustRight = function() {
                if (this.canThrust() == false) { return; }
                this.move([this.thrust/this.mass, 0]);
                this.isThrustRight = true;
        }
        // Display spaceship
        this.display = function() {

                // Predicted route
                if (chartMode == true) { this.chart(); }

                // Thrust
                noStroke();
                fill(237, 17, 7);
                var thrustAngle = -1; // Radians
                if (this.isThrustUp == true) {
                        if (this.isThrustRight == true) {
                                thrustAngle = Math.PI / 4;
                                //text((thrustAngle / Math.PI) + "π", this.x + 20, this.y + 20);
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
}

// Star constructor
function Star(x, y, r, velX, velY, density, aColor) {
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
}

// Planet constuctor
function Planet(x, y, r, velX, velY, density, aColor) {
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
}

// -- DUMP --
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

        // Stores our planets, asteroids, spaceships, and stars.
        this.celestials = [];
        // Gravitational constant
        this.G = 6.674 * Math.pow(10, -11);

        // Constructor vars to member
        this.numStars = numStars;
        this.numPlanets = numPlanets;
        this.numAsteroids = numAsteroids;
        this.catalyze = catalyze;
        this.greatestMass = 0; // Sets the force drawing

        // Spaceship stuff
        this.spaceshipColor = color(0, 0, 0);
        this.spaceshipDensity = 1;
        this.spaceshipRadius = SPACESHIP_R;//CANVAS_WIDTH/56;  // baseline radius for star
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

        this.getSpaceship = function() {
                return this.celestials[0];
        }
        // Generic function for simulation to return array of stats for each frame
        this.getStats = function() {
                var stats = [];
                var ss = this.getSpaceship();

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
        // Check if two planets have collided.
        this.collisionHandler = function(planetA, planetB) {
                // Boundary collision
                if (((planetA.x + planetA.r) > CANVAS_WIDTH)
                    || ((planetA.x - planetA.r) < 0)
                    || ((planetA.y + planetA.r) > CANVAS_HEIGHT)
                    || ((planetA.y - planetA.r) < 0)) {
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

                // Planet collision
                var planetsDist = this.getDistance(planetA, planetB);
                if ((planetsDist - planetA.r - planetB.r) < 0) {
                        // Give safe space
                        var angle = this.getAngleBetween(planetA, planetB);
                        // According to this angle, push out planetA +5 the planetDist, using trig!
                        var pushDist = 5;
                        //planetA.x += pushDist*cos(angle);
                        //planetA.y += pushDist*sin(angle);

                        // Elastic collision, momentum conserved
                        //planetA.velX = (planetA.velX * (planetA.mass - planetB.mass) + 2 * planetB.mass * planetB.velX) / (planetA.mass + planetB.mass);
                        //planetA.velY = (planetA.velY * (planetA.mass - planetB.mass) + 2 * planetB.mass * planetB.velY) / (planetA.mass + planetB.mass);

                        return 1;
                }

                // No collision
                return 0;
        }
        // Given two masses, compute the acceleration of the first.
        this.getPairAcc = function(planet, obj) {
                // Distance apart
                var diffX = planet.x - obj.x;
                var diffY = planet.y - obj.y;
                var d = Math.sqrt(Math.pow(diffX, 2) + Math.pow(diffY, 2));

                // Angle with respect to first param
                var theta = Math.atan(diffY/diffX) + Math.PI;
                if (diffX < 0) { theta += Math.PI; }
                else if (diffY < 0) { theta += 2 * Math.PI; }

                // Planet acceleration
                var acc = this.G * obj.mass / Math.pow(d, 2);
                var accX = acc * Math.cos(theta);
                var accY = acc * Math.sin(theta);

                // Planet force!
                var force = acc * planet.mass;

                // Get type of collision (including "no colision")
                var collisionReport = this.collisionHandler(planet, obj);

                // Planet collision
                if (collisionReport === 1) {
                        // Boundary collision
                } else if (collisionReport === 2) {
                        // Explosive collision
                } else {
                }

                if (gravityDisplayMode == true) {
                        // Line between weighted with magnitude of force
                        stroke(230, 230, 230);
                        strokeWeight(Math.pow(force, 1/4));
                        line(planet.x, planet.y, obj.x, obj.y);

                        // Reset stroke
                        stroke(255, 255, 255);
                        strokeWeight(1);
                }

                return [accX, accY];
        }
        // Get net x and y accelerations of planet
        // with respect to universe cog and other planets.
        this.getNetAcc = function(planetIndex) {
                var netAcc = [0, 0];
                var planet = this.celestials[planetIndex];

                // TODO replace with legit end planet
                var startPlanet = this.celestials[0];
                var endPlanet = this.celestials[this.celestials.length - 1];

                //startPlanet.color = color(0, 0, 0);
                //endPlanet.color = color(0, 0, 0);

                // Draw first bezier point at startPlanet
                // float x = bezierPoint(planet.x, 0, otherPlanet.x, 0, t);
                // float y = bezierPoint(planet.y, 0, otherPlanet.y, 0, t);
                // ellipse(x, y, 5, 5);

                // noFill();
                // stroke(getRandColor(255));

                // Add planets to net acceleration
                for (j = 0; j < this.celestials.length; j++) {
                        if (j !== planetIndex) {
                                var otherPlanet = this.celestials[j];
                                var acc = this.getPairAcc(planet, otherPlanet);
                                netAcc[0] += acc[0];
                                netAcc[1] += acc[1];

                                if (otherPlanet !== startPlanet && otherPlanet !== endPlanet) {

                                        // noStroke();
                                        // stroke(getRandColor(255));

                                        // strokeWeight(1);
                                        // line(startPlanet.x, startPlanet.y, otherPlanet.x, otherPlanet.y);
                                        // line(endPlanet.x, endPlanet.y, otherPlanet.x, otherPlanet.y);

                                        // strokeWeight(5);
                                        // bezier(startPlanet.x, startPlanet.y, Math.sqrt(otherPlanet.x*otherPlanet.mass), Math.sqrt(otherPlanet.y*otherPlanet.mass),
                                        // Math.sqrt(otherPlanet.x*otherPlanet.mass), Math.sqrt(otherPlanet.y*otherPlanet.mass), endPlanet.x, endPlanet.y);
                                        //bezierVertex(startPlanet.x, startPlanet.y, Math.sqrt(otherPlanet.mass)/4, endPlanet.x, endPlanet.y, Math.sqrt(otherPlanet.mass)/4);

                                        // strokeWeight(1);
                                }

/*
                        noFill();
                        stroke(255, 102, 0);
                        line(planet.x, planet.y, otherPlanet.x, otherPlanet.y);
                        stroke(getRandColor(255));

                        bezier(planet.x, planet.y, otherPlanet.x, otherPlanet.y, otherPlanet.x, otherPlanet.y, 0, 0);
                        //bezier(planet.x, planet.y, otherPlanet.x, otherPlanet.y, 80);
                        fill(0);
                        int steps = 30;
                        for (int i = 0; i <= steps; i++) {
                              float t = i / float(steps);
                              float x = bezierPoint(planet.x, 0, otherPlanet.x, 0, t);
                              float y = bezierPoint(planet.y, 0, otherPlanet.y, 0, t);
                              ellipse(x, y, 5, 5);
                        }
                        //--
 */
                        }
                }

                return netAcc;
        }
        this.addCelestial = function(cel) {
                this.celestials.push(cel);
        }
        // For adding asteroids (which have slightly different properties from planets)
        this.addAsteroid = function() {
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
        }
        this.addPlanet = function() {
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
        }
        this.addStar = function() {
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
        }
        this.addSpaceship = function() {
                var pos = this.getRandomPosition();
                var x = pos[0];
                var y = pos[1];
                velX = random(this.spaceshipVelocity) - this.spaceshipVelocity / 2;
                velY = random(this.spaceshipVelocity) - this.spaceshipVelocity / 2;
                r = random(this.spaceshipRadius);
                // Check if plausible placement
                if (this.canISpawn(x, y, r) === false) { return; }
                var spaceship = new Spaceship(this, x, y, r, velX, velY, this.spaceshipDensity, this.spaceshipColor);
                this.celestials.push(spaceship);
                this.updateGreatestMass(spaceship);
        }

        // Render frame in universe
        this.move = function() {

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
                // }

                // Render all celestials
                for (i = 1; i < this.celestials.length; i++) {
                        var planetNetAcc = this.getNetAcc(i);
                        this.celestials[i].move(planetNetAcc);
                        this.celestials[i].display();
                }

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
                rect(0, 0, this.W, this.H);
        }
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
                noLoop();
                // Show pause
                textSize(200);
                fill(255);
                text("||", 10, 170);
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

/*

   /* Music functions

   var playLong() {
    T.pause();
    var freq = T("pulse", {
        freq: random(500),
        add: 880,
        mul: 20
    }).kr();
    T("sin", {
        freq: freq,
        mul: 0.5
    }).play();
   }

   var nextNote() {
    // Increase octave everytime we reach
    // the 7th note.
    if (note == 7) {
        octave++;
    }
    // Keep note within bounds of scale
    note = (note + 1) % scale.length;
   }

   var resetNote() {
    note = 0;
    octave = 1;
   }

   var playShort() {
    // Get current frequency.
    //var f = scale[note] * octave;
    //var f = 27.5 * 10;
    var sine1 = T("sin", {
        freq: ((maxSpiralLength - length) / random(3)),
        mul: 0.5
    });
    T("perc", {
        r: 500
    }, sine1).on("ended", function() {
        this.pause();
    }).bang().play();
    nextNote();
   }

   /* Manipulate spirals

   var moveSpiral() {
    spiralY += spiralVelY * spiralT + 0.5 * spiralAccY * Math.pow(spiralT, 2);
    spiralX += spiralVelX * spiralT + 0.5;
    spiralT += 0.001;
   }

   var softResetSpiral() {
    spiralX = CANVAS_WIDTH;
    spiralY = 0;

    spiralVelX = -random(spiralVelMax / 2) - spiralVelMax;
    spiralVelY = 0; //random(spiralVelMax) - random(spiralVelMax*5) ;

    cirT = 0;

    resetNote();
   }

   var hardResetSpiral() {
    background(color(255, 255, 255));

    softResetSpiral();
    maxSpiralLength = maxAbsLength;
    length = maxSpiralLength;
    angle = 0;
    count = 0;
   }

   /* Fade past objects on canvas

   var spiral = function() {
    // Play sound in intervals!
    //playShort();
    //if ((length % 10) === 0) {  }

    // Translate spiral location
    moveSpiral();

    // TODO Figure out how to stop resetting stroke.
    stroke(255, 255, 255);

    // Compute Color
    var intensity = (1 - (length / intensityIncr)) * 255;

    // Know when to stop drawing, and reset whole thing.
    if (maxSpiralLength < -10) {
        hardResetSpiral();
        return;
    }

    // Reset animation params or decrease length
    if (length < 0) {
        //playLong();
        // Do some cool shit.
        //startObj();

        softResetSpiral();

        maskCanvas();

        //splatter(pastColor);

        maxSpiralLength -= 8 * 3.1415926;
        length = maxSpiralLength;

        pastColor = thisColor;
        //thisColor = blendColor(thisColor, pastColor, ADD);
        thisColor = getRandColor(intensity);
        strokeWeight(1 + random(5));
        angleIncr = (random(500)) / (4 * 3.1415926);
        //stroke(thisColor);

        //woahInt++;
    } else {
        length--;
    }

    // Compute circle attributes
    circleRadius = length * Math.atan(angle) / 2; //round(length) + random(0, randomness);

    pastX = x;
    pastY = y;
    x = spiralX + length * Math.cos(angle) + random(0, randomness);
    y = spiralY + length * Math.sin(angle) + random(0, randomness);

    // Draw circle
    fill(thisColor);
    ellipse(x + circleRadius, y, circleRadius*2, circleRadius*2);
    //triangle(x - circleRadius, y - circleRadius, x + circleRadius, y - circleRadius, x, y + circleRadius);
    //rect(x + circleRadius, y + circleRadius, circleRadius*2, circleRadius*2);
    //point(x, y);
    //curveVertex(x,  y);
    //line(x, y, pastX, pastY);

    // Increment angle by 1/(2*pi) rad
    angle += angleIncr / (2 * 3.1415926);

    // Write text
    updateCount();

    //background(color(random(255), random(255), random(255)));
   };

   /*

   // Variables for gravity object
   var objX = 0;
   var objY = 0;
   var objVelY = 0;
   var objVelX = 0;
   var objAcc = 200;
   var objRun = false;
   var t = 0; // seconds

   var startObj = function() {
    objX = centerX;
    objY = centerY;

    objVelX = random(10) - random(20);
    objVelY = random(10) - random(10);

    t = 0;

    objRun = true;
   }
 */

/* Gravity play */

/*

   // Set new gravity object
   mouseClicked = function() {
    //startObj();
   };

   // Render gravity animation
   var gravity = function() {
    fill(0, 0, 0);
    ellipse(objX, objY, circleRadius, circleRadius);

    //objVelY = objAcc * dt;
    objY += objVelY * t + 0.5 * objAcc * Math.pow(t, 2);
    objX += objVelX * t + 0.5;
    t += 0.001;

    // Stop animation when object hits ground.
    if (objY - circleRadius > CANVAS_HEIGHT) {
        objRun = false;
    }
   };

 */
