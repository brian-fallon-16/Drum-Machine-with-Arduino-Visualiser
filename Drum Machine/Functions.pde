/*************************************************************
 MMT: Programming Digital Systems
 **************************************************************
 * 
 * Assignment 2: Interactive Project - Functions
 * 
 **************************************************************
 *
 * This sketch contains functions for event handling (keys or mouse pressed, controlP5 object changed)
 * as well as a function to contain all controlP5 object intialization and a stop() function.
 *
 * Brian Fallon - fallonb1@tcd.ie
 **************************************************************/

// Handle key presses - only dealing with left and right arrow keys
void keyPressed() {
  
  // Arrow keys cycle through presets in edit mode
  if(key == CODED && !playing) {
    
    if(keyCode == LEFT) {
      presetIdx--;
      if(presetIdx < 0)
        presetIdx = presets.length-1;   
      if(presetIdx == -1) presetIdx = 0;
    }
    if(keyCode == RIGHT) {
      presetIdx++;
      if(presetIdx > presets.length-1)
        presetIdx = 0;
    }
    if(presets.length > 0)
      port.write(presets[presetIdx]);
  }
}

// Handle mouse presses
void mousePressed() {
  // Check if a step on the sequencer needs to be switched on
  mySequencer.checkClick(mouseX, mouseY);
}
 
// Event handling function for controlP5 objects
void controlEvent(ControlEvent e)
{
  // Gets the ID of the parameter that's being activated
  int controlID = e.getId();
  
  // Get the value associated with the parameter being activated
  float controllerValue = e.getValue();
  
  switch(controlID) {
    
    // Play/Stop button
    case 0:
      masterOutput.pauseNotes();
      playing = !playing;
      if(playing)
        masterOutput.resumeNotes();
      else beat = -1;
    break;
    
    // Tempo control
    case 1:
      masterOutput.setTempo((int)controllerValue);
    break;
    
    // Clear pattern
    case 2:
      for(int i = 0; i < mySequencer.rows; i++)
      mySequencer.clearRow(i);
    break;
    
    // Mute button
    case 3:
      if(!masterOutput.isMuted()) {
        masterOutput.mute();
      }
      else masterOutput.unmute();
    break;
    
    // Master gain
    case 4:
        masterOutput.setGain(controllerValue);
    break;
  }
  if(controlID >= 5 && controlID < (3*mySequencer.rows) + 5)
  {
    switch((controlID-5)%3) {
      // pan control
      case 0:
        mySequencer.pans[(controlID-5)/3].setPan(controllerValue);
      break;
      
      // clear control
      case 1:
        mySequencer.clearRow((controlID-6)/3);
      break;
      
      // channel gain control
      case 2:
        mySequencer.channels[(controlID-7)/3].setValue(controllerValue);
      break;
    }
  }
  
  // Lissajous controls - disabled when playing patterns back
  if(controlID >= 127 && controlID <= 138 && !playing) {
    switch(controlID) {
        // DAC 0 controls
        case 127:
          f1 = (int)controllerValue;
        break;
          
        case 128:
          wave1 = (int)controllerValue;
        break;
        
        case 129:
          ringMod1 = (int)controllerValue;
        break;
        
        case 130:
          f3 = (int)controllerValue;
        break;
        
        case 131:
          wave3 = (int)controllerValue;
        break;
        
        // DAC1 controls
        case 132:
          f2 = (int)controllerValue;
        break;
          
        case 133:
          wave2 = (int)controllerValue;
        break;
        
        case 134:
          ringMod2 = (int)controllerValue;
        break;
        
        case 135:
          f4 = (int)controllerValue;
        break;
        
        case 136:
          wave4 = (int)controllerValue;
        break;
        
        // save figure
        case 137:
          presets = append(presets, str(f1)+","+str(wave1)+","+str(ringMod1)+","+str(f3)+","+str(wave3)+","+str(f2)+","+str(wave2)+","+str(ringMod2)+","+str(f4)+","+str(wave4)+",\n");
          //presetIdx++;
        break;
        // clear figure
        case 138:
          if(presets.length>0) presets[presetIdx] = "0,0,0,0,0,0,0,0,0,0,\n";
        break;
        
    }
    port.write(str(f1)+","+str(wave1)+","+str(ringMod1)+","+str(f3)+","+str(wave3)+","+str(f2)+","+str(wave2)+","+str(ringMod2)+","+str(f4)+","+str(wave4)+",\n");
  }
  
  if(controlID == 139) {
    switch((int)controllerValue) {
      case 1:
        presetCycleInterval = 8;
      break;
      
      case 2:
        presetCycleInterval = 4;
      break;
      
      case 3:
        presetCycleInterval = 2;
      break;
      
      case 4:
        presetCycleInterval = 1;
      break;
    }
  }
}

// add buttons and sliders and knobs
void setUpControls()
{  
  cp5.addButton("Play/Stop")
   .setPosition(165, mySequencer.y_pos+(mySequencer.rows*mySequencer.stepHeight)-120)
     .setSize(50,50)
       .setColorActive(color(220))
         .setColorBackground(color(70))
           .setColorForeground(color(#E83838))
             .setId(0);
  
  cp5.addKnob("Tempo")
    .setPosition(235, mySequencer.y_pos+(mySequencer.rows*mySequencer.stepHeight)-120)
      .setSize(50,50)   
        .setColorActive(color(#E83838))
          .setColorForeground(color(220))
            .setColorBackground(color(70))
              .setNumberOfTickMarks(18)
                .setDragDirection(Knob.VERTICAL)
                  .setResolution(180)
                    .setRange(60, 240)
                      .setValue(120)
                        .setId(1);
                      
  cp5.addButton("Clear")
     .setPosition(165, mySequencer.y_pos+(mySequencer.rows*mySequencer.stepHeight)-50)
       .setSize(50,50)
         .setColorActive(color(220))
           .setColorBackground(color(70))
             .setColorForeground(color(#E83838))
               .setId(2);
               
  cp5.addToggle("Mute")
     .setPosition(235, mySequencer.y_pos+(mySequencer.rows*mySequencer.stepHeight)-50)
       .setSize(50,50)
         .setColorActive(color(#E83838))
           .setColorBackground(color(70))
             .setColorForeground(color(220))
               .setId(3);
               
  cp5.addSlider("Master Volume")
    .setPosition(85, mySequencer.y_pos+(mySequencer.rows*mySequencer.stepHeight)-120)
      .setSize(20,120)   
        .setColorActive(color(#E83838))
          .setColorForeground(color(220))
            .setColorBackground(color(70))
              .setRange(-80, 0)
                .setValue(-6)
                  .setId(4);
                  
  // Add individual channel controls for a variable number of rows
  for(int i = 0; i < mySequencer.rows; i++) {
    
      // only display "Pan" for final knob - looks cluttered otherwise
      String panLabel;
      if(i == mySequencer.rows-1)
        panLabel = "Pans";
      else panLabel = "";
       
      cp5.addKnob("Pan"+i)
        .setCaptionLabel(panLabel)
          .setPosition(mySequencer.x_pos + mySequencer.stepWidth*(0.25+mySequencer.cols), mySequencer.y_pos+((i+0.2)*stepHeight))
            .setSize((int)stepWidth,(int)stepWidth)   
              .setColorActive(color(#E83838))
                .setColorForeground(color(220))
                  .setColorBackground(color(70))
                    .setDragDirection(Knob.VERTICAL)
                      .setRange(-1.0, 1.0)
                        .setValue(0.0)
                          .setId((i*3)+5);
                                                    
      cp5.addButton("Clear"+i)
        .setCaptionLabel("Clear")
         .setPosition(mySequencer.x_pos + mySequencer.stepWidth*(1.5+mySequencer.cols), mySequencer.y_pos+((i+0.2)*stepHeight))
           .setSize((int)stepWidth,(int)stepWidth)
             .setColorActive(color(220))
               .setColorBackground(color(70))
                 .setColorForeground(color(#E83838))
                   .setId((i*3)+6);
                   
      cp5.addSlider("Gain"+i)
        .setCaptionLabel(sampleNames[i]+" Gain")
        .setPosition(mySequencer.x_pos + mySequencer.stepWidth*(3.5+mySequencer.cols), mySequencer.y_pos+((i+0.2)*stepHeight))
          .setSize((int)stepWidth*4,(int)stepWidth)
            .setColorActive(color(#E83838))
              .setColorBackground(color(70))
                .setColorForeground(color(220))
                  .setRange(-80, 0)
                    .setValue(-6)
                      .setId((i*3)+7);                 
    }
    
   
 cp5.addKnob("Freq1")
  .setPosition(70, mySequencer.y_pos+40)
    .setSize(30,30)   
      .setColorActive(color(#E83838))
        .setColorForeground(color(220))
          .setColorBackground(color(70))
            .setDragDirection(Knob.VERTICAL)
              .setRange(20, 200)
                .setValue(20)
                  .setId(127);
                        
 cp5.addToggle("Wave1")
   .setPosition(120, mySequencer.y_pos+40)
     .setSize(30,30)
       .setColorActive(color(220))
         .setColorBackground(color(70))
           .setColorForeground(color(#E83838))
             .setId(128);
             
  cp5.addToggle("RingMod1")
   .setPosition(170, mySequencer.y_pos+40)
     .setSize(30,30)
       .setColorActive(color(220))
         .setColorBackground(color(70))
           .setColorForeground(color(#E83838))
             .setId(129);
             
   cp5.addKnob("RMF1")
    .setPosition(220, mySequencer.y_pos+40)
      .setSize(30,30)   
        .setColorActive(color(#E83838))
          .setColorForeground(color(220))
            .setColorBackground(color(70))
              .setDragDirection(Knob.VERTICAL)
                .setRange(1, 400)
                  .setValue(20)
                    .setId(130);
                    
  cp5.addToggle("RMW1")
   .setPosition(270, mySequencer.y_pos+40)
     .setSize(30,30)
       .setColorActive(color(220))
         .setColorBackground(color(70))
           .setColorForeground(color(#E83838))
             .setId(131);
             
             
 cp5.addKnob("Freq2")
  .setPosition(70, mySequencer.y_pos+90)
    .setSize(30,30)   
      .setColorActive(color(#E83838))
        .setColorForeground(color(220))
          .setColorBackground(color(70))
            .setDragDirection(Knob.VERTICAL)
              .setRange(20, 200)
                .setValue(20)
                  .setId(132);
                        
 cp5.addToggle("Wave2")
   .setPosition(120, mySequencer.y_pos+90)
     .setSize(30,30)
       .setColorActive(color(220))
         .setColorBackground(color(70))
           .setColorForeground(color(#E83838))
             .setId(133);
             
  cp5.addToggle("RingMod2")
   .setPosition(170, mySequencer.y_pos+90)
     .setSize(30,30)
       .setColorActive(color(220))
         .setColorBackground(color(70))
           .setColorForeground(color(#E83838))
             .setId(134);
             
  cp5.addKnob("RMF2")
    .setPosition(220, mySequencer.y_pos+90)
      .setSize(30,30)   
        .setColorActive(color(#E83838))
          .setColorForeground(color(220))
            .setColorBackground(color(70))
              .setDragDirection(Knob.VERTICAL)
                .setRange(1, 400)
                  .setValue(20)
                    .setId(135);
                    
  cp5.addToggle("RMW2")
   .setPosition(270, mySequencer.y_pos+90)
     .setSize(30,30)
       .setColorActive(color(220))
         .setColorBackground(color(70))
           .setColorForeground(color(#E83838))
             .setId(136);
                       
  cp5.addButton("Save Figure")
   .setPosition(70, mySequencer.y_pos+160)
     .setSize(40,40)
       .setColorActive(color(220))
         .setColorBackground(color(70))
           .setColorForeground(color(#E83838))
             .setId(137);
             
  cp5.addButton("Clear Figure")
   .setPosition(165, mySequencer.y_pos+160)
     .setSize(40,40)
       .setColorActive(color(220))
         .setColorBackground(color(70))
           .setColorForeground(color(#E83838))
             .setId(138);
             
  cp5.addKnob("Speed")
    .setPosition(260, mySequencer.y_pos+160)
      .setSize(40,40)   
        .setColorActive(color(#E83838))
          .setColorForeground(color(220))
            .setColorBackground(color(70))
              .setDragDirection(Knob.VERTICAL)
              .setNumberOfTickMarks(3)
                .snapToTickMarks(true)
                  .setRange(1, 4)
                    .setValue(2)
                      .setId(139);
}


// The function called on exiting the program
void stop() {
  // Close all the samples associated with the sequencer
  mySequencer.closeSamples();
  // Stop the Minim instance
  myMinim.stop();
  // Close the serial port
  port.stop();
  // Exit the program
  exit(); 
}