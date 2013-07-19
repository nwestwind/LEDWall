// COULD USE A REWRITE

// Wall Setup
final int COLUMNS = 160;             // the amount of LEDs per column (x)
final int ROWS    = 80;              // the amount of LEDs per row (y)
final int TOTAL   = COLUMNS * ROWS;  // the total amount of LEDs on the wall

final int DEBUG_PIXEL_SIZE      = 2;  // size of each debug pixel
final int DEBUG_PIXEL_SPACING_X = 3;  // the X spacing for each debug pixel
final int DEBUG_PIXEL_SPACING_Y = 3;  // the X spacing for each debug pixel

final int DEBUG_REAL_PIXEL_SIZE_X = DEBUG_PIXEL_SIZE + DEBUG_PIXEL_SPACING_X; // the total X size of each debug pixel
final int DEBUG_REAL_PIXEL_SIZE_Y = DEBUG_PIXEL_SIZE + DEBUG_PIXEL_SPACING_Y; // the total Y size of each debug pixel

final int DEBUG_WINDOW_XSIZE = COLUMNS * DEBUG_REAL_PIXEL_SIZE_X;         // the x size of the debug window
final int DEBUG_WINDOW_YSIZE = 220;                                       // the y size of the debug window
final int DEBUG_TEXT_X = DEBUG_WINDOW_XSIZE - 200;

int DEBUG_WINDOW_START = DEBUG_REAL_PIXEL_SIZE_Y * ROWS;

int SEND_TIME = 9;

boolean DEBUG_SHOW_WALL  = false;  // show the wall on the computer screen wall?

VideoWall wall;

void setupWall() {
  wall = new VideoWall();     // create the wall
  println("WALL SETUP ...");
}

class VideoWall {
  PImage[] teensyImages = new PImage [10];
  PGraphics send_buffer;

  VideoWall() {
    send_buffer = createGraphics(ROWS, COLUMNS, JAVA2D);
    send_buffer.loadPixels(); // load the pixels to make sure the array is not set to null

    for (int i = 0; i < teensyImages.length; i++) {
      teensyImages[i] = createImage(80, 16, RGB);
      teensyImages[i].loadPixels();
    }
  }

  private void drawPixel(int x, int y, color c) {
    int screenX = (x * DEBUG_REAL_PIXEL_SIZE_X) + (DEBUG_REAL_PIXEL_SIZE_X / 2);
    int screenY = (y * DEBUG_REAL_PIXEL_SIZE_Y) + (DEBUG_REAL_PIXEL_SIZE_Y / 2);
    noStroke();
    fill(c);
    rectMode(CENTER);
    rect(screenX, screenY, DEBUG_PIXEL_SIZE, DEBUG_PIXEL_SIZE);
  }

  void display() {
    buffer.loadPixels(); // load the current pixels
    for (int i = 0; i < TOTAL; i++) {
      int x = i % COLUMNS; 
      int y = i / COLUMNS;
      drawPixel(x, y, buffer.pixels[i]);
    }
  }

  private void send() {
    // update the send buffer by adding the buffer image rotated for the led matrix
    send_buffer.beginDraw();
    send_buffer.pushMatrix();
    send_buffer.imageMode(CENTER);
    send_buffer.translate(send_buffer.width / 2, send_buffer.height / 2);
    send_buffer.rotate(radians(90));
    send_buffer.image(buffer.get(), 0, 0);
    send_buffer.popMatrix();
    send_buffer.endDraw();

    WALL_WATTS = 0;  // reset the wattage tracking
    
    
    // set the teensy image array
    int start_time = millis();
    for (int i = 0; i < teensyImages.length; i++) {
      arrayCopy(send_buffer.pixels, i * (80 * 16), teensyImages[i].pixels, 0, 80 * 16);
      teensyImages[i].updatePixels();

      if (i < TEENSY_TOTAL) {
        teensys[i].send();
        WALL_WATTS += teensys[i].watts;
      }
    }
    
    // send data again to simulate 10 teensy's
    for (int i = 0; i < teensys.length; i++) {
      teensys[i].send();
    }
    
    int end_time = millis();
    SEND_TIME = end_time - start_time;
    
    MAX_WATTS = max(MAX_WATTS, WALL_WATTS);
  }

  void draw() {
    //buffer.updatePixels();
    send();
    if (DEBUG_SHOW_WALL) display();
  }
}

