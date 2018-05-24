/*************************************************************
 MMT: Programming Digital Systems
 **************************************************************
 * 
 * Assignment 2: Interactive Project - Step
 * 
 **************************************************************
 *
 * This sketch contains the implementation of the "Step" class.
 * These are the buttons that the sequencer is comprised of.
 *
 * Brian Fallon - fallonb1@tcd.ie
 **************************************************************/

// Step class for sequencer
class Step 
{
  // class attributes
  private Boolean isOn;
  private float xPos, yPos;
  private float stepW, stepH;
  
  // constructor
  Step(Boolean initState, float xPos_, float yPos_, float stepW_, float stepH_) {
    // Copy variables
    isOn = initState;
    xPos = xPos_;
    yPos = yPos_;
    stepW = stepW_;
    stepH = stepH_;
  }
  
  // draw the step
  void drawStep() {
    // Draw the rectangle and lines that make up the button
    strokeWeight(0.08*stepW);
    stroke(255);
    fill(150);
    rect(xPos+0.5*(stepW), yPos+0.5*(stepH), stepW*0.85, stepH*0.85);
    
    // If the step is on, draw a red circle, otherwise black
    if(isOn) fill(#E83838); else fill(0); 

    strokeWeight(0.0667*stepW);
    ellipse(xPos+0.5*(stepW), yPos+0.3*(stepH), 0.3*stepW, 0.3*stepW);
  }
  
  // Blink the step if it is on i.e. whiten the current colour by drawing a slightly opaque white circle
  void blink() {
    fill(255, 150);
    strokeWeight(0.0667*stepW);
    stroke(255);
    ellipse(xPos+0.5*(stepW), yPos+0.3*(stepH), 0.3*stepW, 0.3*stepW);
  }
    
  // Return the current state
  Boolean getState() {
    return isOn;
  }
    
  // Set the state
  void setState(Boolean newState) {
    isOn = newState;
  }
}