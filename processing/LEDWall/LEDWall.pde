int DISPLAY_MODE = 1;
float xoff = 0.0;

final int DISPLAY_MODE_TEST    = 0;
final int DISPLAY_MODE_SHOWEQ  = 1;
final int DISPLAY_MODE_USERBG  = 2;
final int DISPLAY_MODE_WHEEL   = 3;
final int DISPLAY_MODE_BALLS   = 4;
final int DISPLAY_MODE_SPIN    = 5;
final int DISPLAY_MODE_PULSAR  = 6;
final int DISPLAY_MODE_CITY    = 7;
final int DISPLAY_MODE_ATARI   = 8;
final int DISPLAY_MODE_CLIPS   = 9;

boolean AUTOMODE = false;

final String[] DISPLAY_STR = { 
  "TEST", "EQ", "USER BG", "WHEEL", "BALLS", "SPIN", "PULSAR", "CITY", "ATARI", "CLIPS"
};


PImage smpte, test, wall_image;

void setup() {
  int x = DEBUG_WINDOW_XSIZE, y;
  if (DEBUG_SHOW_WALL) y = (ROWS * DEBUG_REAL_PIXEL_SIZE_Y) + DEBUG_WINDOW_YSIZE;
  else y = DEBUG_WINDOW_YSIZE;

  size(x, y, JAVA2D);

  smpte = loadImage("smpte_640x320.png");
  test  = loadImage("test_640x320.png");
  wall_image = createImage(COLUMNS, ROWS, RGB);

  setupBuffer();
  setupMinim();
  setupSerial();
  
  setupWall();
  setupKinect();
  
  setupWheel();
  setupEQ();
  
  
  setupParticles();
  setupCircles();
  setupAtari();
  setupClips();
  // must be last
  setupControl();
  frameRate(60);
  
  image_buffer = createImage(COLUMNS, ROWS, ARGB);
}

void autoMode() {
  if ( audio.beat.isOnset() ) {
    float test = random(1);
    if (test < 0.2) {
      int count = int(random(2, 10));
      DISPLAY_MODE = count;
      r.activate(count);
      println("MODE - " + DISPLAY_STR[count]);
    }
  }
}

void draw() {
  if (AUTOMODE) autoMode();
  doMode();
  //minimTest();
  wall.display();
  drawDebug();
  xoff += 0.2;
}

void drawDebug() {
  textSize(11);
  // fill debug window dary grey
  fill(#313131);
  rectMode(CORNER);
  rect(0, DEBUG_WINDOW_START, DEBUG_WINDOW_XSIZE, DEBUG_WINDOW_START + DEBUG_WINDOW_YSIZE);
  
  // fill text display background
  fill(#212121);
  rect(5, DEBUG_WINDOW_START + 5, 200, 210);
  
  fill(255);
  text("FPS: " + String.format("%.2f", frameRate), 10, DEBUG_WINDOW_START + 20);
  text("Display Mode:  " + DISPLAY_STR[DISPLAY_MODE] , 10, DEBUG_WINDOW_START + 35);
  
  text("BPM: " + audio.BPM + "  count: " + audio.bpm_count + "  secs: " + audio.sec_count, 10, DEBUG_WINDOW_START + 65);
  text("BASS: " + audio.BASS, 10, DEBUG_WINDOW_START + 80); 
  text("MIDS: " + audio.MIDS, 70, DEBUG_WINDOW_START + 80);
  text("TREB: " + audio.TREB, 140, DEBUG_WINDOW_START + 80);
  
  //text("GAIN: " + audio.in.gain(), 10, DEBUG_WINDOW_START + 95);
  
  //text("RAW: " + audio.volume.value, 10, DEBUG_WINDOW_START + 95);
  //text("PEAK: " + audio.volume.peak, 70, DEBUG_WINDOW_START + 95);
  //text("MAX PEAK: " + String.format("%.2f", audio.volume.max_peak), 140, DEBUG_WINDOW_START + 95);
  text("dB: " + String.format("%.2f", audio.volume.dB), 10, DEBUG_WINDOW_START + 95);
  
  if (buffer.wattage > 3000) fill(255,0,0);
  text("WATTS: " + String.format("%.2f", buffer.wattage), 10, DEBUG_WINDOW_START + 125);
  text("Max: "   + String.format("%.2f", buffer.max_watts), 115, DEBUG_WINDOW_START + 125);
  fill(255);
  //text("Brightness: " + String.format("%.2f", brightness(audio.COLOR)), 10, DEBUG_WINDOW_START + 140);
  //text("Sat: " + String.format("%.2f", saturation(audio.COLOR)), 120, DEBUG_WINDOW_START + 140);
  text("R: " + audio.RED, 10, DEBUG_WINDOW_START + 140);
  text("G: " + audio.GREEN, 50, DEBUG_WINDOW_START + 140);
  text("B: " + audio.BLUE, 90, DEBUG_WINDOW_START + 140);
  
  //text("atari - x:" + atari.alist[0].x + "  y:" + atari.alist[0].y + " s:" + atari.alist[0].stroke_weight, 10, DEBUG_WINDOW_START + 155);

  //text("kinect user  X: " + String.format("%.2f", kinect.user_center.x) + "  Y: " + String.format("%.2f", kinect.user_center.y), 10, DEBUG_WINDOW_START + 170);
  
  
  
  //image(buffer, DEBUG_WINDOW_XSIZE - (buffer.width + 10) - 170, DEBUG_WINDOW_START + 10);
  //image(buffer, width - 270, DEBUG_WINDOW_START + 10);
  
  fill(#212121);
  rectMode(CORNER);
  rect(DEBUG_WINDOW_XSIZE - 150, DEBUG_WINDOW_START + 5, 145, 210);
  for(int i = 0; i < wall.teensyImages.length; i++) {
    pushMatrix();
    int y = DEBUG_WINDOW_START + 14 + (i * 16);
    
    String temp = "Teensy " + i;
    fill(255);
    text(temp, DEBUG_WINDOW_XSIZE - 90 - textWidth(temp) - 5, y + (i * 4) + 12);
    
    translate(DEBUG_WINDOW_XSIZE - 90, y + (i * 4));
    
    //rotateZ(radians(90));
    //rotateX(radians(-180));
    image(wall.teensyImages[i], 0, 0);
    popMatrix();
  }
}

void doMode() {
  if (DISPLAY_MODE == DISPLAY_MODE_TEST)    doTest();
  if (DISPLAY_MODE == DISPLAY_MODE_SHOWEQ)  doEQ();
  if (DISPLAY_MODE == DISPLAY_MODE_USERBG)  doUserBg();
  if (DISPLAY_MODE == DISPLAY_MODE_BALLS)   doParticles(); 
  if (DISPLAY_MODE == DISPLAY_MODE_SPIN)    doCircles();
  if (DISPLAY_MODE == DISPLAY_MODE_PULSAR)  doPulsar();
  if (DISPLAY_MODE == DISPLAY_MODE_CITY)    doCity();
  if (DISPLAY_MODE == DISPLAY_MODE_WHEEL)   doWheel();
  if (DISPLAY_MODE == DISPLAY_MODE_ATARI)   doAtari();
  if (DISPLAY_MODE == DISPLAY_MODE_CLIPS)   doClips();
}

void exit() {
  println("CLOSING DOWN!!!");
  buffer.beginDraw();
  buffer.background(0);
  buffer.endDraw();
  wall.display();
  
  kinect.close();
  
  // always close Minim audio classes when you are done with them
  audio.close();
  minim.stop();
  
  
  
  super.exit();
}

void keyPressed() {
  //println("keyPressed: " + key);
  //if (key == CODED) {
  //  if (keyCode == UP) {
   //   COLOR_MODE++;
   //   if (COLOR_MODE > 3) COLOR_MODE = 0;
   // } 
   // else if (keyCode == DOWN) {
   //   COLOR_MODE--;
   //   if (COLOR_MODE < 0) COLOR_MODE = 3;
   // }
   // println("Color set to " + COLOR_STR[COLOR_MODE] + " mode ...");
  //}
  
  if (key == '0') DISPLAY_MODE = DISPLAY_MODE_TEST;
  if (key == '1') DISPLAY_MODE = DISPLAY_MODE_SHOWEQ;
  if (key == '2') DISPLAY_MODE = DISPLAY_MODE_USERBG;
  if (key == '3') DISPLAY_MODE = DISPLAY_MODE_WHEEL;
  if (key == '4') DISPLAY_MODE = DISPLAY_MODE_BALLS;
  if (key == '5') DISPLAY_MODE = DISPLAY_MODE_SPIN;
  if (key == '6') DISPLAY_MODE = DISPLAY_MODE_PULSAR;
  if (key == '7') DISPLAY_MODE = DISPLAY_MODE_CITY;
  if (key == '8') DISPLAY_MODE = DISPLAY_MODE_ATARI;
  if (key == '9') DISPLAY_MODE = DISPLAY_MODE_CLIPS;



  //if (key == 'r') {
  //  AUDIO_MODE = AUDIO_MODE_RAW;
  //  println("Audio set to RAW mode ...");
  //}
  //if (key == 's') {
  //  AUDIO_MODE = AUDIO_MODE_SMOOTHED;
  //  println("Audio set to SMOOTHED mode ...");
  //}
  //if (key == 'b') {
  //  AUDIO_MODE = AUDIO_MODE_BALANCED;
  //  println("Audio set to BALANCED mode ...");
  //}
  
  //if (key == ',') kinect.moveKinect(0.5);
}


    


  
