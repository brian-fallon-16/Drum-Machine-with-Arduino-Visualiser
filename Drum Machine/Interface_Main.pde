 /**************************************************************
 * 808-like 16-step drum sequencer with programmable Lissajous figure output
 * Formatted messages are sent to Arduino over serial comms.
 * These determine the waveforms created by the Ardunio.
 *
 * The sequencer is a standard layout, with individual volume, pan and clear controls
 * for each sample as well as master volume, mute, clear and tempo.
 * Number of rows and columns can be flexibly altered provided there are enough samples.
 * This can lead to problems with the master and lissajous controls however - to be fixed in a later revision.
 * 
 * The Lissajous figures can be controlled using the "Lissajous Controls".
 * Patterns can be saved as presets using the save button and cleared using the clear button.
 * Left and right arrow keys can be used to cycle through these presets.
 * The interval at which a new random pattern is selected from the presets can be controlled using the speed knob.
 * This interval varies from every half note, every quarter note, every eighth note and every sixteenth note.
 *
 * This sketch handles all initialization and the drawing of the interface.
 * 
 * N.B. - Minim and ControlP5 must be downloaded and installed for this project to run
 * 
 * Brian Fallon - fallonb16@gmail.com
 **************************************************************/

// Import the necessary libraries
import ddf.minim.*;
import ddf.minim.ugens.*;
import processing.serial.*;
import controlP5.*;

// Had to use a settings() function as size() threw an error when within setup()
void settings()
{
    size(1200, 600);
}

void setup()
{
  // Set draw modes for shapes
  rectMode(CENTER);
  ellipseMode(CENTER);
  // Set a high framerate - raster effect becomes noticeable when slower with blinking of steps left to right
  frameRate(100);
  
  // Uncomment to see list of ports
  //println(port.list()[2]);
  // Open the port that the DUE is connected to and use the same speed (9600 bps)
  port = new Serial(this, port.list()[2], 9600);
  
  // Insantiate new Minim and ControlP5 objects
  // Necessary for sound processing and interactive knobs, sliders etc.
  myMinim = new Minim(this);
  cp5 = new ControlP5(this);
  // Get an AudioOutput object for control of the master channel (level, mute etc.)
  masterOutput = myMinim.getLineOut(Minim.STEREO);
    
  // Initialize the sequencer with the specified parameters
  mySequencer = new Sequencer(seqRows, seqCols, seqX, seqY, stepWidth, stepHeight, sampleNames);
  mySequencer.loadSamples(masterOutput);
  
  // Set up knobs and sliders etc.
  setUpControls();
  
  // Set the global tempo to the specified BPM
  masterOutput.setTempo(bpm);
  // Pause notes before queueing to avoid timing errors relative to start/stop button
  masterOutput.pauseNotes();
  // Queue initial note
  masterOutput.playNote(0, 0.25f, mySequencer);
}

// Draw function
void draw()
{
  // Redraw background
  background(100);
  
  // Draw interface lines
  line(65, 0, 65, height);
  line(305, 0, 305, height);
  line(seqX + (seqCols*stepWidth)+90, 0, seqX + (seqCols*stepWidth)+90, height);
  line(seqX, seqY-5, seqX + (seqCols*stepWidth), seqY-5);
  line(seqX, seqY+(seqRows*stepHeight)+5, seqX + (seqCols*stepWidth), seqY+(seqRows*stepHeight)+5);
  line(80, seqY + (seqRows*stepHeight)-135, 290, seqY+(seqRows*stepHeight)-135);
  line(80, seqY + (seqRows*stepHeight)-205, 290, seqY+(seqRows*stepHeight)-205);
  line(80, seqY + (seqRows*stepHeight)+25, 290, seqY+(seqRows*stepHeight)+25);
  line(80, seqY+15, 290, seqY+15);
  
  // Draw display text
  fill(220);
  textFont(loadFont("TwCenMT-Italic-48.vlw"), 30);
  text("Lissajous Controls", 185, seqY);
  text("Master Controls", 185, seqY+(seqRows*stepHeight)-160);
  
  // Redraw sequencer
  mySequencer.drawSequencer();
}
