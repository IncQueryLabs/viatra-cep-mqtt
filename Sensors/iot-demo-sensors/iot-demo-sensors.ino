#define DEBOUNCE 10  // button debouncer 5+ ms

byte buttons[] = {3, 4, 5}; // D2-D12
String buttonNames[] = {"pb1", "pb2", "pb3"};
#define NUMBUTTONS sizeof(buttons)

byte potmeters[] = {18}; // A0-14, A5-19 6

String potmeterNames[] = {"pot1"};
#define NUMPOTMETERS sizeof(potmeters)

// pressed buttons
byte pressed[NUMBUTTONS];

void setup() {
  byte i;

  // set up serial port
  Serial.begin(9600);
  // pin13 LED
  pinMode(13, OUTPUT);

  // Make input & enable pull-up resistors on button pins
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
     lasttime = millis();
  }

  // Wait DEBOUNCE time
  if ((lasttime + DEBOUNCE) > millis()) {
    return;
  }
  // reset the timer
  lasttime = millis();

  for (index = 0; index < NUMBUTTONS; index++) {
    currentstate[index] = digitalRead(buttons[index]);
    if (currentstate[index] == previousstate[index]) {
      pressed[index] = !currentstate[index];
    }
    previousstate[index] = currentstate[index];
  }
}

String getSensorValueJSON(int value){
  return String("[{\"messageName\" : {\"value\" : " + String(value, DEC) + "}}]");
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
  check_switches(); // Get current states of the buttons

  reportInputStates();
  
}

