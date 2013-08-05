// COULD USE A REWRITE

Rainbow rainbow;
Slider rSpeed;

final String[] RAINBOW_STR = { 
  "WHEEL", "TUNNEL"
};

void setupRainbow() {
  rainbow = new Rainbow();
  
  int x = TAB_START + 10;
  int y = WINDOW_YSIZE - 80;
  
  // controler name, min, max, value, x, y, width, height, label, handle size, text size, type, move to tab
  rSpeed = 
    createSlider("doRspeed", 50, 150, rainbow.cycle_time, x, y, TAB_MAX_WIDTH + 20, 40, "Speed", 20, lFont, Slider.FLEXIBLE, DISPLAY_STR[DISPLAY_MODE_RAINBOW]);

  // controll name, text name, x, y, width, height, text size, value, move 2 tab
  createToggle("allowRBPM", "Audio", TAB_START + 20, DEBUG_WINDOW_START + 50, 50, 50, mFont, ControlP5.DEFAULT, rainbow.bpmOn, DISPLAY_STR[DISPLAY_MODE_RAINBOW]);

  createTextfield("setMinRSpeed", "min speed", TAB_MAX_WIDTH + 10, DEBUG_WINDOW_START+55, 50, 20, nf(rainbow.speedMin, 1), sFont, ControlP5.INTEGER, DISPLAY_STR[DISPLAY_MODE_RAINBOW]);
  cp5.getController("setMinRSpeed").captionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE);
  createTextfield("setMaxRSpeed", "max speed", TAB_MAX_WIDTH + 10, DEBUG_WINDOW_START+80, 50, 20, nf(rainbow.speedMax, 1), sFont, ControlP5.INTEGER, DISPLAY_STR[DISPLAY_MODE_RAINBOW]);
  
  println("RAINBOW SETUP ...");
}

void doRSpeed(int v) {
  if (!rainbow.bpmOn) rainbow.setCycle(v);
}

void allowRBPM(boolean b) {
  rainbow.bpmOn = b;
}

void setMinRSpeed(String valueString) {
  int minSpeed  = int(valueString);
  rainbow.speedMin = minSpeed;
  rSpeed.setMax(minSpeed);
  rSpeed.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(5);
  rSpeed.getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(5);
}

void setMaxRSpeed(String valueString) {
  int maxSpeed  = int(valueString);
  rainbow.speedMax = maxSpeed;
  rSpeed.setMax(maxSpeed);
  rSpeed.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(5);
  rSpeed.getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(5);
}

void doRainbow() {
  PVector kinectUser = getSingleUser();
  rainbow.setLocation(kinectUser.x, kinectUser.y);
  if (rainbow.bpmOn) rainbow.setCycle(audio.BPM);
  buffer.blendMode(BLEND);
  buffer.background(0);
  rainbow.display();
}


class Rainbow {
  final int MODE_WHEEL  = 0;
  final int MODE_TUNNEL = 1;
  final int TOTAL_MODES = 2;
  int speedMin = 150;
  int speedMax = 300;
  float horizontal = 0;
  float vertical = 0;
  float random_test = 0;
  int mode = 1;
  boolean bpmOn = true;
  PVector location;                       // the location of the center of the wheel
  PVector size;
  PVector last_size;
  int last_cycle, bi;                           // the last time the colors were cycled
  int cycle_time = 100;                // the time between cycling colors
  color[] colors = new color [8];
  color[] default_colors = {
    color(255, 0, 0), color(255, 127, 0), color(255, 127, 0), color(127, 255, 0), 
    color(0, 255, 0), color(0, 255, 127), color(0, 127, 255), color(0, 0, 255)
  };


  Rainbow() {
    location = new PVector();
    size = new PVector();
    last_size = new PVector();
    resetColors();
    resetSize();
    last_cycle = millis();
    //use_audio = false;
  }

  void resetSize() {
    size.set(buffer.width*3, buffer.height*6);
    last_size.set(size.x*1.1, size.y*1.1);
  }

  void setCycle(int t) {
    cycle_time = round(map(t, 0, 130, speedMax, speedMin));
    if (bpmOn)  rSpeed.setValue(cycle_time); 
  }

  private void cycleColors() {
    color saved = colors[0];
    for (int i = 0; i < (colors.length - 1); i++) {
      colors[i] = colors[i + 1];
    }
    colors[colors.length - 1] = saved;
  }

  private void cycleColors(color c) {
    for (int i = 0; i < (colors.length - 1); i++) {
      colors[i] = colors[i + 1];
    }
    colors[colors.length - 1] = c;
  }

  void resetColors() {
    arrayCopy(default_colors, colors);
  }

  void setLocation(float x, float y) {
    location.x = round(x);
    location.y = round(y);
    //location.z = round(z);
  }
  
  /*
  void audioOn() {
    use_audio = true;
    resetColors();
    cycle_time = 50;
  }

  void audioOff() {
    use_audio = false;
    resetColors();
    cycle_time = 50;
  }
  */

  private void check() {
    int cTime = millis();
    if (cTime - last_cycle > cycle_time) {
      //if (use_audio) cycleColors(audio.colors.background); 
      //else cycleColors();
      cycleColors();
      last_cycle = cTime;
    }

    if ( audio.isOnBeat() ) {
      random_test = random(0, 1);
      if (random_test < 0.65) {
        mode = round( random(TOTAL_MODES - 1) );
      }
    }
  }

  void doWheel() {
    buffer.noStroke();
    //buffer.strokeWeight(0.5);

    for (int i = 0; i < colors.length; i++) {
      int rnd = round( random(-1,1) );
      //int h_spec = i + rnd;
      //int v_spec = i - 1 + rnd;
        
      //if (v_spec < 0) v_spec = colors.length - 1;
      //if (v_spec > colors.length) v_spec = 0;
      //if (h_spec < 0) h_spec = colors.length - 1;
      //if (h_spec > colors.length) h_spec = 0;
      
      //rnd = round( random(-1,1) );

      //horizontal = map(audio.averageSpecs[h_spec].value, 0, 100, 20, 5);
      //vertical   = map(audio.averageSpecs[v_spec].value, 0, 100, 10, 1);
      
      horizontal = map(audio.volume.value, 0, 100, 20, 10 + (rnd * 2) );
      vertical   = map(audio.volume.value, 0, 100, 10, 5 + rnd);

      buffer.fill( mapByVol( colors[i] ) );
      if ((i + rnd) % 2 == 0) buffer.fill( audio.colors.get(i) );
      buffer.triangle(location.x, location.y, 0, (i * 10) + vertical, 0, ((i + 1) * 10) - vertical);
      buffer.triangle(location.x, location.y, (i * 20) + horizontal, 0, ((i + 1) * 20) - horizontal, 0);

      bi = 7 - i;
      buffer.fill( mapByVol( colors[bi] ) );
      if ((i + rnd) % 2 == 0) buffer.fill( audio.colors.get(bi) );
      buffer.triangle(location.x, location.y, buffer.width, (i * 10) + vertical, buffer.width, ((i + 1) * 10) - vertical);
      buffer.triangle(location.x, location.y, (i * 20) + horizontal, buffer.height, ((i + 1) * 20) - horizontal, buffer.height);
    }
  }

  void doTunnel() {
    buffer.rectMode(CENTER);
    buffer.stroke(0);
    buffer.strokeWeight(0.5);

    buffer.pushMatrix();
    buffer.translate(location.x, location.y);

    for (int j = 0; j < 2; j++) {
      for (int i = 0; i < colors.length; i++) {
        int rnd = round( random(-1,1) );
        int h_spec = i + rnd;
        int v_spec = i - 1 + rnd;
        
        if (v_spec < 0) v_spec = colors.length - 1;
        if (v_spec > colors.length) v_spec = 0;
        if (h_spec < 0) h_spec = colors.length - 1;
        if (h_spec > colors.length) h_spec = 0;
        
        rnd = round( random(-1,1) );
        
        
        if ((i + rnd) % 2 == 0) {
          //buffer.fill(0);
          //buffer.fill(colors[i]);
          buffer.fill( audio.colors.get(i) );
          horizontal = map(audio.averageSpecs[h_spec].value, 0, 100, size.x, last_size.x + last_size.x);
          vertical   = map(audio.averageSpecs[v_spec].value, 0, 100, size.y, last_size.y + last_size.y);
        } else {
          //buffer.fill(0);
          buffer.fill( mapByVol( colors[i] ) );
          horizontal = map(audio.averageSpecs[h_spec].value, 0, 100, last_size.x, size.x);
          vertical   = map(audio.averageSpecs[v_spec].value, 0, 100, last_size.y, size.y);
        }
        buffer.hint(DISABLE_DEPTH_TEST);
        buffer.rect(0, 0, horizontal, vertical);
        buffer.hint(ENABLE_DEPTH_TEST);
        last_size.set(size.x, size.y);
        size.div(1.25);
      }
    }

    //buffer.fill(0);
    //buffer.rect(0, 0, size.x, size.y, 5);
    buffer.popMatrix();
    resetSize();
  }


  void display() {
    check();
    if (mode == MODE_WHEEL) doWheel();
    if (mode == MODE_TUNNEL) doTunnel();
    //doTunnel();
    buffer.noStroke();  // reset to no stroke
  }
}

