#define DEBOUNCE 10  // button debouncer, how many ms to debounce, 5+ ms is usually plenty

// here is where we define the buttons that we'll use. button "1" is the first, button "6" is the 6th, etc
byte buttons[] = {3, 5}; // 12
String buttonNames[] = {"pb1", "pb2"};

// This handy macro lets us determine how big the array up above is, by checking the size
#define NUMBUTTONS sizeof(buttons)

byte potmeters[] = {14}; // A0-14, A5-19 6

String potmeterNames[] = {"pot1"};
// This handy macro lets us determine how big the array up above is, by checking the size
#define NUMPOTMETERS sizeof(potmeters)



// we will track if a button is just pressed, just released, or 'currently pressed'
byte pressed[NUMBUTTONS];

void setup() {
  byte i;

  // set up serial port
  Serial.begin(9600);
  // pin13 LED
  pinMode(13, OUTPUT);

  // Make input & enable pull-up resistors on switch pins
  for (i=0; i< NUMBUTTONS; i++) {
    pinMode(buttons[i], INPUT);
    digitalWrite(buttons[i], HIGH);
  }
}

void check_switches()
{
  static byte previousstate[NUMBUTTONS];
  static byte currentstate[NUMBUTTONS];
  static long lasttime;
  byte index;
  if (millis() < lasttime) {
     lasttime = millis(); // we wrapped around, lets just try again
  }

  if ((lasttime + DEBOUNCE) > millis()) {
    return; // not enough time has passed to debounce
  }
  // ok we have waited DEBOUNCE milliseconds, lets reset the timer
  lasttime = millis();

  for (index = 0; index < NUMBUTTONS; index++) {
    /*justpressed[index] = 0;       // when we start, we clear out the "just" indicators
    justreleased[index] = 0;*/

    currentstate[index] = digitalRead(buttons[index]);   // read the button
    if (currentstate[index] == previousstate[index]) {
      pressed[index] = !currentstate[index];  // remember, digital HIGH means NOT pressed
    }
    //Serial.println(pressed[index], DEC);
    previousstate[index] = currentstate[index];   // keep a running tally of the buttons
  }
}

String getSensorValueJSON(int value){
  return String("{\"value\" : " + String(value, DEC) + "}");
}

void reportButtons(){
  for (byte i = 0; i < NUMBUTTONS; i++) {
    String buttonName = buttonNames[i];
    Serial.print("\"" + buttonName + "\" : ");
    if (pressed[i]) {
      Serial.print(getSensorValueJSON(1));
    }else{
      Serial.print(getSensorValueJSON(0));
    }
    if((NUMPOTMETERS != 0) || (NUMPOTMETERS == 0 && i != NUMBUTTONS-1)){
      Serial.print(", ");
    }
  }
}

void reportPotentiometers(){
  for (byte i = 0; i < NUMPOTMETERS; i++) {
    String btnName = potmeterNames[i];
    Serial.print("\"" + btnName + "\" : ");
    int val = analogRead(potmeters[i]);
    Serial.print(getSensorValueJSON(val));
    if(i != NUMPOTMETERS-1){
      Serial.print(", ");
    }
  }
}

void reportInputStates(){
  Serial.print("{");
  reportButtons();
  reportPotentiometers();
  Serial.println("}");
}

void loop() {
  check_switches();      // when we check the switches we'll get the current state

  reportInputStates();
  
}

