/* MATHTRIP    */
/* Luke Weber  */
/* TODO
      - Add trance audio
      - Have objects that allow things to move independently
      - Organize and comment code
      - Upload to GitHub
*/
/* Window/canvas properties */
var w = window.innerWidth - 20;
var h = window.innerHeight - 20;
var centerX = w / 2;
var centerY = h / 2;
var fps = 50000;
var count = 0;

/* Text display variables */

var woahArr = ["...", "Woah...", "Math.", "That's...", "Cool.", "How'd..", "Yah..", "Do..", "That?", "JS?", "Luke?", "Well.", "It's fast.", "Too fast.", "Pause?", "Please.", "Fuck.", "Stop.", "Can't", "Read.", "Shit."];
var woahInt = 0;

/* Music variables */

// A through G (Whole multiples of these notes are the notes themselves.)
var aMinor = [27.50, 30.87, 32.70, 36.71, 41.20, 43.65, 49.00];
var note = 0;
var octave = 200;
var scale = aMinor;

/* Spiral Properties */

var stop = false;
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

// Create universe
var universe = new Universe();

/* Canvas constructor and animation driver */

void setup() {
    // Set framerate
    frameRate(fps);
    if (stroked === false) {
        noStroke();
    }
    // Set canvas background
    background(color(255, 255, 255));
    // Set canvas size to window size.
    size(w, h);
    // Prepare sprial
    hardResetSpiral();

    // Render planets
    universe.splatter();
}

// Driver function for animations.
void draw() {
    //spiral();
    //if (objRun === true) { gravity(); }

    // Set stroke of spiral circles
    //stroke(color(255, 255, 255));
    maskCanvas();

    // Update universe time
    universe.render();

    updateCount();
};

// Planet constuctor
function Planet(planetX, planetY, planetRadius, planetVelX, planetVelY, planetDensity, planetColor, maxRadius) {
      this.x = planetX;
      this.y = planetY;
      this.velX = planetVelX;
      this.velY = planetVelY;
      this.r = planetRadius;
      this.color = planetColor;
      this.density = planetDensity;
      this.volume = (4/3) * Math.PI * Math.pow(this.r, 3);
      this.mass = this.density * this.volume;
      // Render next frame of planet given current
      // net acceleration computed by universe.
      this.render = function(acc) {
            // Get acceleration components
            var accX = acc[0];
            var accY = acc[1];

            // Planet velocity
            this.velX += accX * universe.time;
            this.velY += accY * universe.time;

            // Planet next position
            this.x += this.velX * universe.time;
            this.y += this.velY * universe.time;

            // Planet draw!
            fill(this.color);
            ellipse(this.x, this.y, this.r, this.r);
            fill(this.color + 20);
            ellipse(this.x, this.y, this.r/100, this.r/100);
      };
}

// NOTE Both universe and planets have similar attributes. Namely, x, y, and mass.

// Universe constructor
function Universe() {
      this.planets = [];
      this.time = .5;  // our time interval, in seconds
      // Planet stuff
      this.planetColor = getRandColor(255);
      this.planetDensity = 8;
      this.maxNumPlanets = 20;
      this.maxRadius = 800;
      this.maxInitVel = 3; // meters/sec
      // Asteroid stuff
      this.maxNumAsteroid = 40;
      this.maxAsteroidRadius = 8;
      this.maxAsteroidVelocity = this.maxInitVel + 5;
      this.asteroidColor = getRandColor(255);
      // Center of gravity stuff
      this.G = 6.674 * Math.pow(10, -11); // Gravitational constant
      this.mass = Math.pow(10, 13); // Mass of universal center of gravity
      this.x = centerX;
      this.y = centerY;
      this.indicatorRadius = 20;
      this.indicatorAngle = 0;
      //this.centerOfGravity = [this.G, this.mass, centerX, centerY];
      // Given two masses, compute the acceleration of the first.
      // Both must have x, y, and mass attributes.
      this.getPairAcc = function(planet, obj) {
            // Relation to planet
            var diffX = planet.x - obj.x;
            var diffY = planet.y - obj.y; // b/c Y is inverted
            var d = Math.sqrt(Math.pow(diffX, 2) + Math.pow(diffY, 2));

            // Compute angle
            var theta = Math.atan(diffY/diffX) + Math.PI;
            if (diffX < 0) {
                  theta += Math.PI;
            } else if (diffY < 0) {
                  theta += 2 * Math.PI;
            }

            // Planet acceleration
            var acc = this.G * obj.mass / Math.pow(d, 2);
            var accX = acc * Math.cos(theta);
            var accY = acc * Math.sin(theta);

            // While we're at it, let's draw a line!
            strokeWeight(Math.sqrt(acc*planet.mass/10000));
            stroke(255, 255, 255);
            //stroke(230, 230, 230);
            line(planet.x, planet.y, obj.x, obj.y);
            // Reset stroke
            stroke(255, 255, 255);
            //strokeWeight(1);

            return [accX, accY];
      }
      // Get net x and y accelerations of planet
      // with respect to universe cog and other planets.
      this.getNetAcc = function(planetIndex) {
            var netAcc = [0, 0];
            var planet = this.planets[planetIndex];

            // Add planets to net acceleration
            for(j = 0; j < this.planets.length; j++) {
                  if (j !== planetIndex) {
                        var otherPlanet = this.planets[j];
                        var acc = this.getPairAcc(planet, otherPlanet);
                        netAcc[0] += acc[0];
                        netAcc[1] += acc[1];
                  }
            }
            // Now add universes center of gravity! (Biggest)
            var acc = this.getPairAcc(planet, this);
            netAcc[0] += acc[0];
            netAcc[1] += acc[1];

            return netAcc;
      }
      // Initialize unique planet array in universe
      this.splatter = function() {
            var numPlanets = random(this.maxNumPlanets);
            var numAsteroid = random(this.maxNumAsteroid);
            for(i = 0; i < numPlanets; i++) {
                  this.addPlanet(random(w), random(h));
            }
            for(i = 0; i < numAsteroid; i++) {
                  this.addPlanetSpecific(random(w), random(h), random(this.maxAsteroidRadius), random(this.maxAsteroidVelocity), random(this.maxAsteroidVelocity));
            }
      }
      this.addPlanetSpecific = function(planetX, planetY, r, velX, velY) {
            this.planets.push(new Planet(planetX, planetY, r, velX, velY, this.planetDensity, this.planetColor, this.maxRadius));
      }
      this.addPlanet = function(planetX, planetY) {
            velX = random(this.maxInitVel) - this.maxInitVel / 2;
            velY = random(this.maxInitVel) - this.maxInitVel / 2;
            r = random(this.maxRadius);
            this.planets.push(new Planet(planetX, planetY, r, velX, velY, this.planetDensity, this.planetColor, this.maxRadius));
      }
      this.pulsateIndicator = function() {
            noStroke();
            fill(color(50, 50, 50));
            ellipse(this.x, this.y, Math.pow(this.indicatorRadius, 1.1), Math.pow(this.indicatorRadius, 1.1));
            fill(color(200, 200, 200));
            ellipse(this.x, this.y, this.indicatorRadius, this.indicatorRadius);

            this.indicatorRadius += 0.1 * Math.sin(this.indicatorAngle);
            this.indicatorAngle += 1/(32*Math.PI);
      }
      // Render frame in universe
      this.render = function() {
            // Render planets
            for(i = 0; i < this.planets.length; i++) {
                  var planetNetAcc = this.getNetAcc(i);
                  this.planets[i].render(planetNetAcc);
            }

            // Render center of gravity
            this.pulsateIndicator();
      }
}

// TODO Pulsate and collision detection (with planets, cog, and canvas boundary!)
// TODO Incorporate spiral into object and gravity!

// Pulsate planet
function pulsate(planet) {

}


// Update universe center of gravity on mouse movement.
mouseMoved = function() {
    universe.x = mouseX;
    universe.y = mouseY;
};

// Add new planet on mouse click
mouseClicked = function() {
    universe.addPlanet(mouseX, mouseY);
};

function getRandColor(intensity) {
    return color(random(intensity), random(intensity), random(intensity));
}

/* Music functions */

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

/* Manipulate spirals */

var moveSpiral() {
    spiralY += spiralVelY * spiralT + 0.5 * spiralAccY * Math.pow(spiralT, 2);
    spiralX += spiralVelX * spiralT + 0.5;
    spiralT += 0.001;
}

var softResetSpiral() {
    spiralX = w;
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

/* Fade past objects on canvas */

var maskCanvas() {
    fill(255, 255, 255, 200);
    rect(0, 0, w, h);
}

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
    ellipse(x + circleRadius, y, circleRadius, circleRadius);
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
/* Text display update */

var updateCount() {
    noStroke();
    fill(20, 20, 20);
    rect(10, h - 160, 600, 300);
    fill(255, 255, 255);
    textSize(200);
    text(count, 10, (h - 10));
    count++;
}

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
    if (objY - circleRadius > h) {
        objRun = false;
    }
};

*/
