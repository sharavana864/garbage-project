// Define pin for Ultrasonic Sensor (SIG pin)
const int pingPin = 7; // Connect the SIG pin of the 3-pin sensor to Arduino Digital Pin 7

// Define pins for LEDs (these remain the same as before)
const int greenLED = 2;
const int yellowLED = 3;
const int redLED = 4;

// Define bin dimensions (in cm) for calculating percentage full (these remain the same)
const float BIN_HEIGHT = 50.0;
const float EMPTY_BIN_DISTANCE = 45.0;
const float FULL_BIN_THRESHOLD_DISTANCE = 10.0;

long duration;
int distanceCm;
float percentageFull;

void setup() {
  Serial.begin(9600);

  // Set pin modes for LEDs
  pinMode(greenLED, OUTPUT);
  pinMode(yellowLED, OUTPUT);
  pinMode(redLED, OUTPUT);

  // Initially turn all LEDs off
  digitalWrite(greenLED, LOW);
  digitalWrite(yellowLED, LOW);
  digitalWrite(redLED, LOW);
}

void loop() {
  // --- PING Sensor (3-pin) Logic ---
  // The PING sensor uses one pin for both trigger and echo.
  // First, send a pulse:
  pinMode(pingPin, OUTPUT);  // Set pin to OUTPUT
  digitalWrite(pingPin, LOW);
  delayMicroseconds(2);
  digitalWrite(pingPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(pingPin, LOW);

  // Then, listen for the echo:
  pinMode(pingPin, INPUT);   // Set pin to INPUT
  duration = pulseIn(pingPin, HIGH);

  // Calculate the distance in centimeters
  distanceCm = duration * 0.0343 / 2;

  // Print distance to serial monitor
  Serial.print("Distance: ");
  Serial.print(distanceCm);
  Serial.println(" cm");

  // Calculate percentage full (remains the same)
  float effectiveDistanceRange = EMPTY_BIN_DISTANCE - FULL_BIN_THRESHOLD_DISTANCE;
  float garbageHeight = EMPTY_BIN_DISTANCE - distanceCm;

  percentageFull = (garbageHeight / effectiveDistanceRange) * 100.0;

  // Clamp percentage to 0-100%
  if (percentageFull < 0) {
    percentageFull = 0;
  }
  if (percentageFull > 100) {
    percentageFull = 100;
  }

  Serial.print("Garbage Level: ");
  Serial.print(percentageFull);
  Serial.println("% full");

  // --- Visual Alerts (LEDs) --- (remains the same)
  digitalWrite(greenLED, LOW);
  digitalWrite(yellowLED, LOW);
  digitalWrite(redLED, LOW); // Turn all off first

  if (percentageFull < 50) {
    digitalWrite(greenLED, HIGH); // Green: Less than 50% full (Good)
  } else if (percentageFull >= 50 && percentageFull < 85) {
    digitalWrite(yellowLED, HIGH); // Yellow: 50% to 85% full (Moderate)
  } else { // percentageFull >= 85
    digitalWrite(redLED, HIGH); // Red: 85% or more full (Alert!)
    Serial.println("ALERT: GARBAGE BIN IS FULL!");
  }

  delay(1000); // Wait for 1 second before next reading
}
