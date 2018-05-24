/**************************************************************
 * 
 * INTERACTIVE ARDUINO WAVE GENERATOR
 * 
 **************************************************************
 * This program receives analog potentiometer readings
 * nd generates sine/triangle wave DAC outputs, as well
 * as ring modulated waveforms to be visualized as Lissajous 
 * figures using an oscilloscope set to XY mode
 * 
 * Waveforms are created via parallel interpolating wavetable
 * oscillators
 * 
 * Brian Fallon - fallonb16@gmail.com
 * 
 * N.B. - Arduino Due package must be downloaded and installed via the boards manager for this sketch to work
 * 
 * Serial comms code based on that found at:
 * https://forum.arduino.cc/index.php?topic=288234.0
 * 
 * Waveform generation based on sketch found at:
 * https://www.arduino.cc/en/Tutorial/DueSimpleWaveformGenerator
 * 
 **************************************************************/
#include "Waveforms.h"
#include <math.h>

// Interpolating wavetable oscillator parameters
// These consist of:
//    > The current index into the wavetable (index_n)
//    > The size of increment used to cycle through the wavetable (jumpSize_n)
//    > The waveform frequency (freq_n)
//    > The current sample value (sampleValue_n)
//    > The wave type (waveNum_n)
//    > In the case of waves 1 and 2 a flag to trigger ring modulation with waves 3 and 4 respectively (ringMod_n)

// Output parameters for waves 1 & 2 - the primary waves
// Wave 1 - DAC0
double index_1 = 0;
double jumpSize_1 = 1;
double freq_1 = 20;
int sampleValue_1;
volatile int waveNum_1 = 0;
bool ringMod_1 = false;

// Wave 2 - DAC1
double index_2 = 0;
double jumpSize_2 = 1;
double freq_2 = 20;
int sampleValue_2;
volatile int waveNum_2 = 0;
bool ringMod_2 = false;

// Output parameters for waves 3 & 4 - the waves that can be used to ring modulate waves 1 & 2 respectively
// Wave 3
double index_3 = 0;
double jumpSize_3 = 1;
double freq_3 = 80;
int sampleValue_3;
volatile int waveNum_3 = 0;

// Wave 4
double index_4 = 0;
double jumpSize_4 = 1;
double freq_4 = 100;
int sampleValue_4;
volatile int waveNum_4 = 0;


// Sampling rate variables

// Sampling rate set so that one sample time very roughly equals the time taken to complete one loop cycle
// This is so that the specified frequencies more or less correspond to the rendered waveforms
double fs = 16000;
// This value is calculated here once to avoid doing it multiple times within the main loop so that it runs as fast as possible
double lengthRateRatio = maxSamplesNum/fs;


// Serial data variables

// An array of chars is used (of size 32) to buffer incoming data
const byte numChars = 32;
char receivedBytes[numChars];
// A flag to indicate whether or not there is a new formatted message containing new parameter values
boolean stringComplete = false;


void setup()
{
  // Set the analog output resolution to 12 bits or 4096 levels
  analogWriteResolution(12);
  // Set baud rate for serial comms
  Serial.begin(9600);
}

void loop()
{
  // Go to custom serial event handler if there is data to be read on the port
  // This method was chosen over using serialEvent() as it turned out to be faster
  // This meant more responsive and in-time visuals
  //if(Serial.available())
    mySerialEvent();

  // Process the newly received formatted message and extract the new parameter values if one exists
  //if(stringComplete)
  //{
    //parseData();
  //}
  
  // Calculate sample values for both DACs
  // Interpolate a new sample value if the index is between sample values i.e. if it is something like 4.26
  // Interpolation function used is y = y1+(index%1)*(y2-y1)
  sampleValue_1 = (int)(waveformsTable[waveNum_1][(int)index_1] + fmod(index_1,1)*(waveformsTable[waveNum_1][((int)index_1)+1]-waveformsTable[waveNum_1][(int)index_1]));
  sampleValue_2 = (int)(waveformsTable[waveNum_2][(int)index_2] + fmod(index_2,1)*(waveformsTable[waveNum_2][((int)index_2)+1]-waveformsTable[waveNum_2][(int)index_2]));

  // Calculate modulated value for sampleValue_1 is ringMod flag is set
  if(ringMod_1)
  {
      // Calculate sampleValue_3
      sampleValue_3 = (int)(waveformsTable[waveNum_3][(int)index_3] + fmod(index_3,1)*(waveformsTable[waveNum_3][((int)index_3)+1]-waveformsTable[waveNum_3][(int)index_3]));
      // Offsetting by -2^(bitResolution/2) before multiplication is necessary as sample values are currently not bipolar
      // Multiplication of unipolar waves results in lopsided waveforms - visually undesirable
      sampleValue_1 -=2048;
      sampleValue_3 -=2048;
      // Scale result to prevent distortion of result
      sampleValue_1 = (sampleValue_3*sampleValue_1)/2048;
      // Fix the offset to make value unipolar again for writing to DAC
      sampleValue_1 +=2048;
      //sampleValue_3 +=2048;
  }
  
  // Calculate modulated value for sampleValue_2 is ringMod flag is set
  if(ringMod_2)
  {
      // Calculate sampleValue_4
      sampleValue_4 = (int)(waveformsTable[waveNum_4][(int)index_4] + fmod(index_4,1)*(waveformsTable[waveNum_4][((int)index_4)+1]-waveformsTable[waveNum_4][(int)index_4]));
      sampleValue_2 -=2048;
      sampleValue_4 -=2048;
      sampleValue_2 = (sampleValue_4*sampleValue_2)/2048;
      sampleValue_2 +=2048;
      //sampleValue_4 +=2048;
  }
  
  // Write new sample values to DACs
  analogWrite(DAC1, sampleValue_1);
  analogWrite(DAC0, sampleValue_2);


  // Calculate new jump sizes
  // This is done within the loop repeatedly to allow smooth frequency modulation from the Processing sketch
  
  // Calculate jump size for first wave
  jumpSize_1 = lengthRateRatio*freq_1;
  // Increment the index
  index_1 += jumpSize_1;
  // If the index is beyond the length of the wavetable decrease the index by the wavetable length to wrap it around to 
  if(index_1 >= maxSamplesNum)
    index_1 -= maxSamplesNum;

  // Calculate jump size and index for second wave
  jumpSize_2 = lengthRateRatio*freq_2;
  index_2 += jumpSize_2;
  if(index_2 >= maxSamplesNum)
    index_2 -= maxSamplesNum;
    
  // Calculate jump size and index for third wave if ring modulation is on for wave 1
  if(ringMod_1 > 0)
  {
    jumpSize_3 = lengthRateRatio*freq_3; 
    index_3 += jumpSize_3;
    if(index_3 >= maxSamplesNum)
      index_3 -= maxSamplesNum;
  }
  
  // Calculate jump size and index for fourth wave if ring modulation is on for wave 2
  if(ringMod_2 > 0)
  {
    jumpSize_4 = lengthRateRatio*freq_4; 
    index_4 += jumpSize_4;
    if(index_4 >= maxSamplesNum)
      index_4 -= maxSamplesNum;
  }
}


// Custom serial event handler
void mySerialEvent() 
{
  Serial.println(analogRead(0));
}

// Function to parse input string
// Received messaged are of the format: "freq_1,waveNum_1,ringMod_1,freq_3,waveNum_3,freq_2,waveNum_2,ringMod_2,freq_4,waveNum_4,\n"
void parseData()
{
    // This is used by strtok() as an index
    char * strtokIndx;

    // Set new DAC0 output parameters

    // Get the first parameter value
    strtokIndx = strtok(receivedBytes,",");
    freq_1 = atoi(strtokIndx);

    // This continues where the previous call left off and so on until the end of the message
    strtokIndx = strtok(NULL, ",");
    waveNum_1 = atoi(strtokIndx);

    strtokIndx = strtok(NULL, ",");
    ringMod_1 = atoi(strtokIndx);

    strtokIndx = strtok(NULL, ",");
    freq_3 = atoi(strtokIndx);

    strtokIndx = strtok(NULL, ",");
    waveNum_3 = atoi(strtokIndx);


    // Set new DAC1 output parameters
    
    strtokIndx = strtok(NULL, ",");
    freq_2 = atoi(strtokIndx);

    strtokIndx = strtok(NULL, ",");
    waveNum_2 = atoi(strtokIndx);

    strtokIndx = strtok(NULL, ",");
    ringMod_2 = atoi(strtokIndx);

    strtokIndx = strtok(NULL, ",");
    freq_4 = atoi(strtokIndx);

    strtokIndx = strtok(NULL, ",");
    waveNum_4 = atoi(strtokIndx);

    // Set stringComplete flag to false so that this if-statement will not
    // be entered again until a new string has been received
    stringComplete = false;
}
