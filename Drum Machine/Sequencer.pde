/*************************************************************
 MMT: Programming Digital Systems
 **************************************************************
 * 
 * Assignment 2: Interactive Project - Sequencer
 * 
 **************************************************************
 *
 * This sketch contains the implementation of the "Sequencer" class central to this project.
 * The sequencer contains an array of samples, each patched to its own pan and gain control.
 * These individual channels are all then patched to a supplied master output.
 *
 **************************************************************/

// Sequencer class implements "Instrument" so it can be "played" using playNote()
class Sequencer implements Instrument
{
  // Physical properties
  private int rows, cols;
  private float x_pos, y_pos;
  private float stepWidth, stepHeight;
  // Object arrays
  private Step[][] steps;
  private Sampler[] samples;
  private String[] sampleNames;
  public Gain[] channels;
  public Pan[] pans;
    
  // Step sequencer constructor
  public Sequencer(int rows_, int cols_, float x_pos_, float y_pos_, float stepWidth_, float stepHeight_, String[] sampleNames_) {
    // Copy sequencer parameters
    rows = rows_;
    cols = cols_;
    x_pos = x_pos_;
    y_pos = y_pos_;
    stepWidth = stepWidth_;
    stepHeight = stepHeight_;
    
    // Intialize and copy sample names - only copy as many as there are samples/rows
    sampleNames = new String[rows];
    arrayCopy(sampleNames_, sampleNames, sampleNames.length);
    
    // Initialize the steps with size and position
    steps = new Step[cols][rows];     
    for(int j = 0; j < rows; j++)
    {
      for(int i = 0; i < cols; i++) {
        steps[i][j] = new Step(false, x_pos+(i*stepWidth), y_pos+(j*stepHeight), stepWidth, stepHeight);
      }
    }
    
    // Initialize array of Sample objects
    samples = new Sampler[rows];
    
    // Intialize channel with gain and panning for each sample
    channels = new Gain[rows];
    pans = new Pan[rows];
    // Set gain to 0 dB and pan to centre by default
    for(int i = 0; i < rows; i++) {
      channels[i] = new Gain(0.f);
      pans[i] = new Pan(0);
    }
  }
  
  // Load samples
  public void loadSamples(AudioOutput out) {
      for(int i = 0; i < rows; i++) {
        // Load new sample according to naming convention - "sample_n.wav"
        samples[i] = new Sampler("samples/sample_"+(i+1)+".wav", 4, myMinim);
        // Patch new sample to the specified AudioOutput via its own channel (a gain and a pan control)
        samples[i].patch(channels[i]).patch(pans[i]).patch(out);
      }
  }
    
  // Draw the seqeuncer step array
  public void drawSequencer() {
    // print names, draw steps and blink if playing, row by row
    for(int j = 0; j < rows; j++) {
      
      // Print sample names to the left of the rows
      fill(0);
      textAlign(CENTER);
      textFont(loadFont("TwCenMT-Italic-48.vlw"), 0.75*cols);
      text(sampleNames[j], x_pos-(stepWidth*0.7), y_pos+((j+0.8)*stepHeight));
      
      // Draw the steps
      for(int i = 0; i < cols; i++) {
        steps[i][j].drawStep();
        
        // Print button number text
        text(i+1, (x_pos+((i+0.5)*stepWidth)), y_pos+((j+0.8)*stepHeight));
      }
      
      // Blink if playing
      if(playing)
        if(beat < 0) steps[0][j].blink(); else steps[beat][j].blink();
    }
  }
  
  // Check if the click should trigger a sample
  public void checkClick(float mouse_x, float mouse_y) {
    
    // Check if mouse click is within the sequencer bounds
    if(mouse_x > x_pos && mouse_y > y_pos && mouse_x < x_pos + (cols*stepWidth) && mouse_y < y_pos + (rows*stepHeight)) {
      
      // Check that it's within the gray area of the step
      if((mouse_x - x_pos)%stepWidth > 0.133*stepWidth && (mouse_x - x_pos)%stepWidth < stepWidth*0.867) {
        if((mouse_y - y_pos)%stepHeight > 0.133*stepHeight && (mouse_y - y_pos)%stepHeight < stepHeight*0.867) {
          
          // Turn on the cell the mouse click was within & ignore clicks outside of the gray areas
              int x_ = (int)((mouse_x - x_pos)/stepWidth);
              int y_ = (int)((mouse_y - y_pos)/stepHeight);
              // NOT operation toggles state
              steps[x_][y_].setState(!steps[x_][y_].getState());
        }
      }
    }
  }
  
  // Clear a row of button states
  public void clearRow(int row) {
    for(int i = 0; i < cols; i++) {
      steps[i][row].setState(false);
    }
  }
  
  // Close all samples
  public void closeSamples() {
    for(int i = 0; i < rows; i++) {
        samples[i].stop();
      }
  }
  
  
  // Instrument methods implementation
  
  // Note On - trigger samples
  void noteOn(float dur) {
    for(int i = 0; i < rows; i++) {
        if(steps[beat][i].getState()) {
          samples[i].stop();
        }
    }
    // Advance beat here - this is so that once stopped, the beat is set to -1 and immediately incremented to zero on starting again.
    // This ensures the first cell (if set) is always sounded when resumed
    beat = (beat+1)%16;
    
    // Trigger samples for set buttons for current beat
    for(int i = 0; i < rows; i++) {
        if(steps[beat][i].getState()) {
          samples[i].trigger();
        }
    }
    // Write a randomly selected (from presets[]) Lissajous pattern message to the serial port at the specified interval,
    // provided at least one preset has been saved
    if(beat%presetCycleInterval == 0 && presets.length > 0) {
      port.write(presets[(int)random(presets.length)]);
    }
  }
  // Note Off - queue next note
  void noteOff() { 
    
    // Replay the same instance of the instrument - a new note begins once one has ended
    masterOutput.playNote(0, 0.25f, this);
  }
}