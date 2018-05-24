/*************************************************************
 MMT: Programming Digital Systems
 **************************************************************
 * 
 * Assignment 2: Interactive Project - Serial_Stuff
 * 
 **************************************************************
 *
 * This sketch contains the waveform parameters used in the
 * formatted messages sent to the Arduino as well as some
 * other parameters relevant to the Lissajous figures display
 *
 * Brian Fallon - fallonb1@tcd.ie
 **************************************************************/

// A String array to hold messages corresponding to saved Lissajous patterns
// Presets in the following format: "f1,wave1,ringMod1,f3,wave3,f2,wave2,ringMod2,f4,wave4,\n"
String[] presets = {};

// Current index into the preset array
int presetIdx = 0;

// Variables that define the Lissajous pattern created
// These are set and then concatenated into a formatted string that is sent to the Arduino

// Waveform parameters for the output of DAC0
int f1 = 40;
int wave1 = 0;
int ringMod1 = 0;
int f3 = 0;
int wave3 = 0;

// Waveform parameters for the output of DAC1
int f2 = 21;
int wave2 = 0;
int ringMod2 = 0;
int f4 = 0;
int wave4 = 0;

// The speed at which presets are cycled through - by default every quarter note
int presetCycleInterval = 4;