
const int vol_pin = 1;

int vol_value = 0;
int prev = 210;

void setup() {
  Serial.begin( 9600 );
}

void loop() {
  vol_value = analogRead( vol_pin );
  //Serial.println(vol_value);
  if (vol_value < 200 && prev >= 200) {
    Serial.write(1);
    //Serial.println(1);
  }
  prev = vol_value;

  delay( 50 );
}
