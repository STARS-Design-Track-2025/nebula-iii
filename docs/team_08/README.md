# NEBULA III - Project Documentation

## Team 08 - [Team Name]
* **Peer Mentor:** [Name]
* [Name]
* [Name]
* [Name]
* [Name]
* [Add more names, if needed]

## Project Overview
Describe what your project is in 2-3 sentences. Do NOT mention functionality details, you will add those in the *Functionality Description and Testing* section.

## Pin Layout
Note that on the final chip, there are 38 GPIO pins of which you have access to 34.
The first number represents the GPIO on the physical chip, while the second number (in brackets) represents the number in your Verilog code. For each pin, mention if it is an input, output, or both and describe the pin function.

* **Pin 00 [00]** - input - interrupt from touchscreen 
* **Pin 01 [--]** - NOT ALLOWED
* **Pin 02 [--]** - NOT ALLOWED
* **Pin 03 [--]** - NOT ALLOWED
* **Pin 04 [--]** - NOT ALLOWED
* **Pin 05 [01]** - input and output - SDA, line for I2C with touchscreen 
* **Pin 06 [02]** - input and output - SCL, line for I2C with touchscreen 
* **Pin 07 [03]** - output - SPI D0(7 bit bus data) 
* **Pin 08 [04]** - output - SPI D1 
* **Pin 09 [05]** - output - SPI D2 
* **Pin 10 [06]** - output - SPI D3 
* **Pin 11 [07]** - output - SPI D4 
* **Pin 12 [08]** - output - SPI D5 
* **Pin 13 [09]** - output - SPI D6  
* **Pin 14 [10]** - output - SPI D7 
* **Pin 15 [11]** - output - SPI WR (write clock)
* **Pin 16 [12]** - output - SPI RD (read clock)
* **Pin 17 [13]** - output - SPI CS (chip select, active low)
* **Pin 18 [14]** - output - SPI C/D (data or command signal)
* **Pin 19 [15]** - not used 
* **Pin 20 [16]** - not used 
* **Pin 21 [17]** - not used 
* **Pin 22 [18]** - not used 
* **Pin 23 [19]** - not used 
* **Pin 24 [20]** - not used 
* **Pin 25 [21]** - not used 
* **Pin 26 [22]** - not used 
* **Pin 27 [23]** - not used 
* **Pin 28 [24]** - not used 
* **Pin 29 [25]** - not used
* **Pin 30 [26]** - not used
* **Pin 31 [27]** - not used
* **Pin 32 [28]** - not used
* **Pin 33 [29]** - not used
* **Pin 34 [30]** - not used
* **Pin 35 [31]** - not used
* **Pin 36 [32]** - not used
* **Pin 37 [33]** - not used

## External Hardware
We are using a capacitive touchscreen+display component
Link: https://learn.adafruit.com/adafruit-2-8-and-3-2-color-tft-touchscreen-breakout-v2/overview

To connect screen with the chip, follow the pinmap and conect IM ports of the screen to GND. Here s the picture: ![screen pinmap](<Screenshot from 2025-08-06 15-25-37.png>)

## Functionality Description and Testing
Describe in detail how your project works and how to test it.

## RTL Diagrams
Include more than just block diagrams, including sub-block diagrams, state-transition diagrams, flowcharts, and timing diagrams. Please include any images or documents of these inside this folder (docs/team_08).