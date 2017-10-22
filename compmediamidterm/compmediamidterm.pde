/* adapted from
https://processing.org/tutorials/sound/
*/

import de.voidplus.leapmotion.*;
import processing.sound.*;

float hue = 190;

color sketchBG = color(234,234,234);
color textColor = color(180,180,180);
PFont f;

PImage startImg1;
boolean startTheGame = false;
boolean pauseTheGame = false;

SinOsc[] sineWaves; // Array of sines
float[] sineFreq; // Array of frequencies
int numSines = 5; // Number of oscillators to use
float yoffset;
float frequency;
float detune;

LeapMotion leap;
ArrayList<PVector> pointsR = new ArrayList<PVector>(); // make an arraylist of pvectors

// setup
void setup () {
  size(1000, 1000);
  
  colorMode(HSB, 360);

  background(sketchBG);
  fill(255);
  strokeWeight(3);

  startImg1 = loadImage("instructions.jpg");

  f = createFont("Arial", 24);
  textFont(f);
  
  leap = new LeapMotion(this);
  
  sineWaves = new SinOsc[numSines]; // Initialize the oscillators
  sineFreq = new float[numSines]; // Initialize array for Frequencies

  for (int i = 0; i < numSines; i++) {
    float sineVolume = (1.0 / numSines) / (i + 1);
    sineWaves[i] = new SinOsc(this);
    sineWaves[i].play();
    sineWaves[i].amp(sineVolume);
  }
}

void draw() {
  if (startTheGame == false) {
    startScreen();
  }
  
  if (startTheGame == true) {
    theGame();
  }
  
  
}

void startScreen() {
  image(startImg1,0,0);
  if(keyPressed) {
    if ( key == 'l' || key == 'L') {
        startTheGame = true;
        println("start the Game");
        background(sketchBG);
    }
  }
}


void theGame() {
fill(sketchBG);
  noStroke();
  rect(0, 0,width,50);
  fill(textColor);
  textAlign(CENTER);
  text("No hands detected", width/2, 30);

  for (Hand hand : leap.getHands()) {
    
    // left hand "detunes"
    if (hand.isLeft()) {
      Finger index = hand.getIndexFinger();
      PVector posL= index.getPosition();
     
      detune = map(posL.x, 0, width, -0.5, 0.5);
    }
    
    // right hand changes frequency
    if (hand.isRight()) {
      Finger index = hand.getIndexFinger();
      PVector posR= index.getPosition();
      pointsR.add(new PVector(posR.x,posR.y));
      
      // draw the line    
      beginShape();
      for (PVector v : pointsR) {  
        fill(59,360,360);
        stroke(hue,360,360);
        vertex(v.x,v.y);  
      }
      endShape();

      yoffset = map(posR.y, 0, height, 0, 1);
      frequency = pow(1000, yoffset) + 150;

    }
    
    for (int i = 0; i < numSines; i++) { 
        sineFreq[i] = frequency * (i + 1 * detune);
        sineWaves[i].freq(sineFreq[i]);
    }
      
    // feedback
    noStroke();
    fill(sketchBG);
    rect(375,0,300,50);
    
    if (hand.isLeft()) {
        leftMsg("Left hand detected");
    } 
    if (hand.isRight()) {
        rightMsg("Right hand detected");
    } 
  }  
}


void leftMsg(String msg1) {
  fill(sketchBG);
  rect(0,0,250,50);
  fill(textColor);
  textAlign(LEFT);
  text(msg1, 10, 30);
}

void rightMsg(String msg2) {
  fill(sketchBG);
  rect(width-250,0,250,50);
  fill(textColor);
  textAlign(RIGHT);
  text(msg2, width-10, 30);
}