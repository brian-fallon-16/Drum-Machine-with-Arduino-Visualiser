/*************************************************************
 MMT: Programming Digital Systems
 **************************************************************
 * 
 * Assignment 2: Interactive Project - Master_Parameters
 * 
 **************************************************************
 *
 * This sketch contains the master parameters and objects
 * that are central to the sketch operation.
 *
 * Brian Fallon - fallonb1@tcd.ie
 **************************************************************/
 
 // Global Objects
ControlP5 cp5;
Serial port;
Minim myMinim;
AudioOutput masterOutput;
Sequencer mySequencer;

// Master control parameters
// Beat counter (intially -1 to ensure first sample is actually triggered when notes are resumed)
int beat = -1;
// Global BPM - initially 120
int bpm = 120;
// Flag to indicate whether or not sequence is playing
// This is useful for disabling Lissajous programming while drums are playing and for the start/stop mechanism
Boolean playing = false;