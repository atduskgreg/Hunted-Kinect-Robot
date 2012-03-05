import java.awt.Robot;
import java.awt.event.KeyEvent;
import java.awt.event.InputEvent;

import SimpleOpenNI.*;

SimpleOpenNI kinect;
Robot robot;
PVector screenPosition;
PVector hand1Position;
PVector hand2Position;

int clapThreshold = 150;

int hand1;
int hand2;

boolean hand1Tracked = false;
boolean hand2Tracked = false;

boolean clapping = false;
boolean justClapping = false;

void setup() {
  size(640, 480); 

  screenPosition = new PVector();
  hand1Position = new PVector();
  hand2Position = new PVector();

  kinect = new SimpleOpenNI(this);
  kinect.setMirror(true);

  //enable depthMap generation 
  kinect.enableDepth();
  // enable hands + gesture generation <1>
  kinect.enableGesture();
  kinect.enableHands();

  kinect.addGesture("RaiseHand"); // <2>
  kinect.addGesture("Click");

  stroke(255, 0, 0);
  strokeWeight(2);

  try {
    robot = new Robot();
  } 
  catch (java.awt.AWTException ex) { 
    println("Problem initializing AWT Robot: " + ex.toString());
  }
}

boolean checkClap(){
  float d = 500;
  if(hand1Tracked && hand2Tracked){
    d = hand1Position.dist(hand2Position);
  }
  
  if(d < clapThreshold){
    clapping = true;
  } else {
    clapping = false;
  }

  boolean result = clapping && !justClapping;
  
  justClapping = clapping;
  
  return result;
}

void draw() {
  kinect.update();
  image(kinect.depthImage(), 0, 0);
  
   // println("hand1: " + hand1 + " hand2: " + hand2);

  
  noStroke();
  fill(255, 0, 0);
  ellipse(hand1Position.x, hand1Position.y, 10, 10);
  
  fill(0, 255, 0);
  ellipse(hand2Position.x, hand2Position.y, 10, 10);

  if(hand1Tracked && hand2Tracked){
    float d = hand1Position.dist(hand2Position);
    text(d, 10,10);  
  }

  screenPosition.x = map(hand1Position.x, 0, 640, 0, screenWidth);
  screenPosition.y = map(hand1Position.y, 0, 480, 0, screenHeight);

  robot.mouseMove((int)screenPosition.x, (int)screenPosition.y);
  
  if(checkClap()){
    fill(255);
    rect(width - 130, 0, 130, 60);
    fill(0);
    stroke(0);
    pushMatrix();
    scale(3);
    text("CLAP!", width/3 - 40, 10);
    popMatrix();
    
    robot.keyPress(KeyEvent.VK_T);
    robot.keyRelease(KeyEvent.VK_T);
  }
}

// -----------------------------------------------------------------
// hand events <5>
void onCreateHands(int handId, PVector position, float time) {
  if (!hand1Tracked) {
    hand1 = handId;
    hand1Tracked = true;
    kinect.convertRealWorldToProjective(position, hand1Position);
  }

  else if (!hand2Tracked) {
    hand2 = handId;
    hand2Tracked = true;
    kinect.convertRealWorldToProjective(position, hand2Position);
  }
}

void onUpdateHands(int handId, PVector position, float time) {
  if (handId == hand1) {
    kinect.convertRealWorldToProjective(position, hand1Position);
  }

  else if (handId == hand2) {
    kinect.convertRealWorldToProjective(position, hand2Position);
  }
}

void onDestroyHands(int handId, float time) {
  if(handId == hand1){
    hand1Tracked = false;
    hand1 = 0;
  } else if(handId == hand2) {
    hand2 = 0;
    hand2Tracked = false;
  }
  kinect.addGesture("RaiseHand");
}

// -----------------------------------------------------------------
// gesture events <4>
void onRecognizeGesture(String strGesture, 
PVector idPosition, 
PVector endPosition) {

  // println(strGesture + " " + strGesture.equals("Click"));

  if (strGesture.equals("Click")) {
    println(strGesture);
    robot.mousePress(InputEvent.BUTTON1_MASK);
    robot.mouseRelease(InputEvent.BUTTON1_MASK);
  } 
  else {
    kinect.startTrackingHands(endPosition);
    if (hand1Tracked && hand2Tracked) {
      kinect.removeGesture("RaiseHand");
    }
  }
}

