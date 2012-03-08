/**
 * Frame Differencing 
 * by Golan Levin. 
 *
 * GSVideo version by Andres Colubri.  
 * 
 * Quantify the amount of movement in the video frame using frame-differencing.
 */ 


import codeanticode.gsvideo.*;

float DAMP = .1;
int numPixels;
int[] previousFrame;
GSCapture video;

void setup() {
  size(640, 480); // Change size to 320 x 240 if too slow at 640 x 480
  // Uses the default video input, see the reference if this causes an error
  video = new GSCapture(this, width, height);
  video.start();  
  numPixels = video.width * video.height;
  // Create an array to store the previously captured frame
  previousFrame = new int[numPixels];
  loadPixels();
}

void draw() {
  if (video.available()) {
    // When using video to manipulate the screen, use video.available() and
    // video.read() inside the draw() method so that it's safe to draw to the screen
    video.read(); // Read the new frame from the camera
    video.loadPixels(); // Make its pixels[] array available
    
    int movementSum = 0; // Amount of movement in the frame
    for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
      color currColor = video.pixels[i];
      color prevColor = previousFrame[i];
      // Extract the red, green, and blue components from current pixel
      int currR = (currColor >> 16) & 0xFF; // Like red(), but faster
      int currG = (currColor >> 8) & 0xFF;
      int currB = currColor & 0xFF;
      // Extract red, green, and blue components from previous pixel
      int prevR = (prevColor >> 16) & 0xFF;
      int prevG = (prevColor >> 8) & 0xFF;
      int prevB = prevColor & 0xFF;
      // Compute the difference of the red, green, and blue values
      int diffR = abs(currR - prevR);
      int diffG = abs(currG - prevG);
      int diffB = abs(currB - prevB);
      // Add these differences to the running tally
      int sum = diffR + diffG + diffB;
      movementSum += sum;
      // Render the difference image to the screen
      if (sum > 100)
        pixels[i] = color(currR, currG, currB);
      else {
        color pix = pixels[i];
        int pixR = (pix >> 16) & 0xFF; // Like red(), but faster
        int pixG = (pix >> 8) & 0xFF;
        int pixB = pix & 0xFF;
        int r = pixR > currR ? pixR - 1: pixR + 1;
        int g = pixG > currG ? pixG - 1 : pixG + 1;
        int b = pixB > currB ? pixB - 1 : pixB + 1;

        pixels[i] = color(r + 3, g + 3, b + 3);
      }     
      // The following line is much faster, but more confusing to read
      //pixels[i] = 0xff000000 | (diffR << 16) | (diffG << 8) | diffB;
      // Save the current color into the 'previous' buffer
      previousFrame[i] = currColor;
    }
    // To prevent flicker from frames that are all black (no movement),
    // only update the screen if the image has changed.
    if (movementSum > 0)
      updatePixels();
  }
}