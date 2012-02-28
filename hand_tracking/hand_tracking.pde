import java.awt.Robot;
import java.awt.event.KeyEvent;
import java.awt.event.InputEvent;

import SimpleOpenNI.*;

SimpleOpenNI kinect;
Robot robot;
PVector mousePosition;
  PVector screenPosition; 

void setup() {
  size(640, 480); 

  mousePosition = new PVector();
  screenPosition = new PVector();

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
  
  try{
    robot = new Robot(); 
  } catch (java.awt.AWTException ex) { 
    println("Problem initializing AWT Robot: " + ex.toString()); 
  }
}

void draw() {
  kinect.update();
  image(kinect.depthImage(), 0, 0);
  fill(255,0,0);
  ellipse(mousePosition.x, mousePosition.y, 10, 10);
  
  screenPosition.x = map(mousePosition.x, 0, 640, 0, screenWidth);
  screenPosition.y = map(mousePosition.y, 0, 480, 0, screenHeight);
  
  robot.mouseMove((int)screenPosition.x, (int)screenPosition.y);
  
}

// -----------------------------------------------------------------
// hand events <5>
void onCreateHands(int handId, PVector position, float time) {
  kinect.convertRealWorldToProjective(position, mousePosition);
}

void onUpdateHands(int handId, PVector position, float time) {
  kinect.convertRealWorldToProjective(position, mousePosition);
}

void onDestroyHands(int handId, float time) {
  kinect.addGesture("RaiseHand");
}

// -----------------------------------------------------------------
// gesture events <4>
void onRecognizeGesture(String strGesture, 
                        PVector idPosition, 
                        PVector endPosition) {
   
  // println(strGesture + " " + strGesture.equals("Click"));
                          
  if(strGesture.equals("Click")){
    println(strGesture);
    robot.mousePress(InputEvent.BUTTON1_MASK);
    robot.mouseRelease(InputEvent.BUTTON1_MASK);
    
  } else {
    kinect.startTrackingHands(endPosition);
    kinect.removeGesture("RaiseHand"); 
  }
}
