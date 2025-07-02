# Smart Garbage Level Monitoring System (IoT Prototype)

## Project Overview

This project implements a smart waste management prototype designed to monitor the fill-level of garbage bins in real-time. By leveraging an ultrasonic sensor and a microcontroller (simulated in Tinkercad or physically using Arduino/ESP32), the system aims to prevent overflowing bins, thus improving urban cleanliness and hygiene by alerting municipal teams when a bin needs to be emptied.

This documentation specifically details the **Tinkercad Circuits simulation** approach for demonstrating the core functionality, as physical hardware may not always be readily available.

## Problem Statement

Unmonitored garbage bins often overflow in urban areas, leading to significant health hazards, foul odors, unsanitary conditions, and general environmental degradation. Traditional manual inspection methods are inefficient and costly.

## Objective

To develop an IoT-based system that accurately monitors garbage bin levels using an ultrasonic sensor and provides real-time alerts when the bin is full, enabling proactive waste collection.

## Features (Simulated)

* **Real-time Level Monitoring:** Continuously measures the distance to the garbage, calculating the fill percentage.
* **Visual Fill Level Indicators:** Uses LEDs to visually represent the bin's fill status:
    * **Green LED:** Bin is less than 50% full.
    * **Yellow LED:** Bin is 50% to 85% full.
    * **Red LED:** Bin is 85% or more full (approaching full/full).
* **Serial Monitor Alerts:** Prints the distance, calculated fill percentage, and "ALERT: GARBAGE BIN IS FULL!" messages to the serial console for debugging and observation.

## Technologies Used (Simulated Environment)

* **Platform:** Autodesk Tinkercad Circuits
* **Microcontroller:** Arduino Uno R3 (simulated)
* **Sensor:** Ultrasonic Distance Sensor (3-pin PING sensor - simulated HC-SR04 variant)
* **Indicators:** LEDs (simulated)
* **Programming Language:** Arduino C++

## Hardware Requirements (Simulated in Tinkercad)

* 1 x Arduino Uno R3
* 1 x Ultrasonic Distance Sensor (3-pin PING sensor)
* 1 x Breadboard (small or large)
* 3 x LEDs (e.g., Green, Yellow, Red)
* 3 x 220 Ohm Resistors (for LEDs)
* Jumper Wires (virtual connections in Tinkercad)

## Circuit Diagram 
![Screenshot 2025-07-02 215528](https://github.com/user-attachments/assets/e1a02434-99c5-486a-9760-9eb071113fbb)


**Wiring Guide:**

* **Arduino Uno R3 to Breadboard Power:**
    * Arduino 5V -> Breadboard (+) rail
    * Arduino GND -> Breadboard (-) rail
* **Ultrasonic Distance Sensor (3-pin PING sensor):**
    * VCC -> Breadboard (+) rail
    * GND -> Breadboard (-) rail
    * SIG -> Arduino Digital Pin 7
* **LEDs (with 220 Ohm Resistors):**
    * Green LED (Anode/Longer Leg) -> Arduino Digital Pin 2
    * Green LED (Cathode/Shorter Leg) -> 220 Ohm Resistor -> Breadboard (-) rail
    * Yellow LED (Anode/Longer Leg) -> Arduino Digital Pin 3
    * Yellow LED (Cathode/Shorter Leg) -> 220 Ohm Resistor -> Breadboard (-) rail
    * Red LED (Anode/Longer Leg) -> Arduino Digital Pin 4
    * Red LED (Cathode/Shorter Leg) -> 220 Ohm Resistor -> Breadboard (-) rail

## Software (Arduino Code)

The `garbage_level_monitor.ino` file contains the Arduino C++ code for the project.

```cpp
// Define pin for Ultrasonic Sensor (SIG pin)
const int pingPin = 7; // Connect the SIG pin of the 3-pin sensor to Arduino Digital Pin 7

// Define pins for LEDs
const int greenLED = 2;
const int yellowLED = 3;
const int redLED = 4;

// Define bin dimensions (in cm) for calculating percentage full
// Adjust these values based on your simulated bin's characteristics in Tinkercad.
const float BIN_HEIGHT = 50.0; // Total height of the bin from sensor to bottom (conceptual)
const float EMPTY_BIN_DISTANCE = 45.0; // Distance from sensor when bin is empty
const float FULL_BIN_THRESHOLD_DISTANCE = 10.0; // Distance from sensor when bin is considered full

long duration;
int distanceCm;
float percentageFull;

void setup() {
  Serial.begin(9600); // Initialize serial communication for debugging

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
  // Speed of sound = 343 meters/second = 0.0343 cm/microsecond
  // Distance = (duration * speed of sound) / 2 (because sound travels to object and back)
  distanceCm = duration * 0.0343 / 2;

  // Print distance to serial monitor
  Serial.print("Distance: ");
  Serial.print(distanceCm);
  Serial.println(" cm");

  // Calculate percentage full
  // First, find the actual garbage level relative to the bottom of the bin
  // (Assuming sensor is at the top, and distance decreases as bin fills)
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

  // --- Visual Alerts (LEDs) ---
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
