/*************************************************************
 MMT: Programming Digital Systems
 **************************************************************
 * 
 * Assignment 2: Interactive Project - Sequencer_Parameters
 * 
 **************************************************************
 *
 * This sketch contains the parameters that define the Sequencer.
 * Sample names are placed in order corresponding to the samples in the "samples/" folder.
 * It is up to the designer to ensure the names correspond to the correct sample 
 * if the default samples are replaced.
 *
 * Brian Fallon - fallonb1@tcd.ie
 **************************************************************/

// Sequencer parameters
// Rows and columns
int seqRows = 11;
int seqCols = 16;
// Step width and height
float stepWidth = 30;
float stepHeight = 40;
// X and Y position
float seqX = (1200-(seqCols*stepWidth))/2;
float seqY = (600-(seqRows*stepHeight))/2;
// Names of the samples
String[] sampleNames = {"Kick", "Snare", "LT", "MT", "HT", "Rim", "Clap", "Cowbell", "Cymbal", "OHH", "CHH"};