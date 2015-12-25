/* Renders animations */

var ctx = $('#myCanvas').get(0).getContext('2d');
ctx.beginPath();
ctx.arc(95,50,40,0,2*Math.PI);
ctx.stroke();

/*

$.getScript("processing.js", function(){
   alert("Script loaded but not necessarily executed.");
});




var woahArr = ["...", "Woah...", "Math.", "That's...", "Cool.", "How'd..", "Yah..", "Do..", "That?" , "JS?", "Luke?", "Well.", "It's fast.", "Too fast.", "Pause?", "Please.", "Come on.", "Stop.", "Can't", "Read.", "Fuck.", "Shit.", "Tits.", "Cock.", "Ass.", "You must be very proud."];

var circleRadius = 1;
var angle = 0;
var centerX = width/2;
var centerY = height/2;
var x = 1000;
var y = 1000;
var pastX = 1000;
var pastY = 1000;
var maxLength = 500;
var length = 0;

// Controls rendering character
var angleIncr = 64/(4*3.1415926);var loc = window.location.pathname;
var dir = loc.substring(0, loc.lastIndexOf('/'));
var intensityIncr = 200;var loc = window.location.pathname;
var dir = loc.substring(0, loc.lastIndexOf('/'));
var randomness = 0;
var fps = 50000;
var stroked = true;
//var strokedWeight = 40;

// Temp
var pastColor = color(0, 0, 0);
var thisColor = color(0, 0, 0);
var woahInt = 0;
var stop = false;

// Use variables to set framerate
// and stroke.
frameRate(fps);
stroke(color(255, 255, 255));
if (stroked === false) { noStroke(); }

// Reset spiral center according to mouse position.
mouseMoved = function() {
    centerX = mouseX;
    centerY = mouseY;
};var loc = window.location.pathname;
var dir = loc.substring(0, loc.lastIndexOf('/'));

var getRandChristColor = function(intensity) {
    return color(random(intensity), random(intensity), random(intensity));
};

var spiral = function() {
    // Compute Color
    var intensity = (1 - (length / intensityIncr)) * 255;

    // Know when to stop drawing.
    if (maxLength < 0) { stop = true; return; }

    // Reset animation params or decrease length
    if (length < 0) {

        fill(255, 255, 255, 200);
        rect(0, 0, height, width);

        maxLength -= 8*3.1415926;
        length = maxLength;

        pastColor = thisColor;
        //thisColor = blendColor(thisColor, pastColor, ADD);
        thisColor = getRandChristColor(intensity);
        strokeWeight(random(5));
        angleIncr = (random(500))/(4*3.1415926);
        //stroke(thisColor);
        //playSound(getSound("rpg/giant-no"));

        woahInt++;
    }
    else { length--; }

    // Compute circle attributes
    circleRadius = length*Math.atan(angle)/2;//round(length) + random(0, randomness);

    pastX = x;
    pastY = y;
    x = centerX + length*Math.cos(angle) + random(0, randomness);
    y = centerY + length*Math.sin(angle) + random(0, randomness);

    // Draw circle
    fill(thisColor);
    ellipse(x + circleRadius, y, circleRadius, circleRadius);
    //triangle(x - circleRadius, y - circleRadius, x + circleRadius, y - circleRadius, x, y + circleRadius);
    //rect(x + circleRadius, y + circleRadius, circleRadius*2, circleRadius*2);
    //point(x, y);
    //curveVertex(x,  y);
    //ine(x, y, pastX, pastY);

    // Increment angle by 1/(2*pi) rad
    angle += angleIncr/(2*3.1415926);

    // Write text
    fill(0, 0, 0);
    textSize(100);
    text(woahArr[woahInt], 10, height - 10);
};

// Variables for gravity object
var objX = 0;
var objY = 0;
var objVelY = 0;
var objVelX = 0;
var objAcc = 200;
var objRun = false;
var t = 0; // seconds

// Set new gravity object
mouseClicked = function() {
    objX = mouseX;
    objY = mouseY;

    objVelX = random(10) - random(20);
    objVelY = random(10) - random(20) ;

    t = 0;

    objRun = true;
};

// Render gravity animation
var gravity = function() {
    fill(0, 0, 0);
    ellipse(objX, objY, circleRadius, circleRadius);

    //objVelY = objAcc * dt;
    objY += objVelY * t + 0.5 * objAcc * Math.pow(t, 2);
    objX += objVelX * t + 0.5 * objAcc * Math.pow(t, 2);
    t += 0.001;

    // Stop animation when object hits ground.
    if (objY - circleRadius > height) {
        objRun = false;
    }
};

// Driver function for animations.
var draw = function() {
    if (stop !== true) { spiral(); }
    if (objRun === true) { gravity(); }
};
*/
