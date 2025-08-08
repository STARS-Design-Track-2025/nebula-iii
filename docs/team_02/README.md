# NEBULA III - Project Documentation

## Team 02 - [Team Name]
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

* **Pin 00 [00]** - Not used
* **Pin 01 [--]** - NOT ALLOWED
* **Pin 02 [--]** - NOT ALLOWED
* **Pin 03 [--]** - NOT ALLOWED
* **Pin 04 [--]** - NOT ALLOWED
* **Pin 05 [01]** - Input (pb[18]) - IMU Enable
* **Pin 06 [02]** - Input (pb[1]) - Serial Data Out from IMU
* **Pin 07 [03]** - Output (left[2]) - CS into IMU 
* **Pin 08 [04]** - Output (left[0]) - Serial Data Into IMU 
* **Pin 09 [05]** - Output (left[1]) - SCLK into IMU
* **Pin 10 [06]** - Input (pb[2]) - SDI from shift register
* **Pin 11 [07]** - Output (right[4]) - SCLK into shift register
* **Pin 12 [08]** - Output (right[5]) - Latch for shift register
* **Pin 13 [09]** - Output (right[2]) - PWM X out 
* **Pin 14 [10]** - Output (right[3]) - PWM Y out 
* **Pin 15 [11]** - Output (ss0[1]) - CS into LCD 
* **Pin 16 [12]** - Output (right[0]) - SDO into LCD 
* **Pin 17 [13]** - Output (ss0[7]) - SCLK into SSD 
* **Pin 18 [14]** - Not used 
* **Pin 19 [15]** - Not used 
* **Pin 20 [16]** - Not used 
* **Pin 21 [17]** - Not used 
* **Pin 22 [18]** - Not used 
* **Pin 23 [19]** - Not used 
* **Pin 24 [20]** - Not used 
* **Pin 25 [21]** - Not used 
* **Pin 26 [22]** - Not used 
* **Pin 27 [23]** - Not used 
* **Pin 28 [24]** - Not used 
* **Pin 29 [25]** - Not used
* **Pin 30 [26]** - Not used
* **Pin 31 [27]** - Not used
* **Pin 32 [28]** - Not used
* **Pin 33 [29]** - Not used
* **Pin 34 [30]** - Not used
* **Pin 35 [31]** - Not used
* **Pin 36 [32]** - Not used
* **Pin 37 [33]** - Not used

## External Hardware
List all the required external hardware components and upload a breadboard with the equipment set up (recommend using Tinkercad circuits if possible).

## Functionality Description and Testing
Describe in detail how your project works and how to test it.

## RTL Diagrams
Include more than just block diagrams, including sub-block diagrams, state-transition diagrams, flowcharts, and timing diagrams. Please include any images or documents of these inside this folder (docs/team_02).