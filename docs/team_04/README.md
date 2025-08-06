# NEBULA III - Project Documentation

## Team 04 - [ADRIAN]
* **Peer Mentor:** [Adrian Buczkowski]
* [Omar Habli]
* [Jeff Liu]
* [Owen Yao]
* [Darren Huang]
* [Ethan Peyton]

## Project Overview
Describe what your project is in 2-3 sentences. Do NOT mention functionality details, you will add those in the *Functionality Description and Testing* section.
Our project is a graphing calculator that is powered by a CPU. The user types in an equation using the keypad and the graph of the equation will be displayed.

## Pin Layout
Note that on the final chip, there are 38 GPIO pins of which you have access to 34.
The first number represents the GPIO on the physical chip, while the second number (in brackets) represents the number in your Verilog code. For each pin, mention if it is an input, output, or both and describe the pin function.

* **Pin 00 [00]** - Not Used
* **Pin 01 [--]** - NOT ALLOWED
* **Pin 02 [--]** - NOT ALLOWED
* **Pin 03 [--]** - NOT ALLOWED
* **Pin 04 [--]** - NOT ALLOWED
* **Pin 05 [01]** - Output - column[0]
* **Pin 06 [02]** - Output - column[1] 
* **Pin 07 [03]** - Output - column[2] 
* **Pin 08 [04]** - Output - column[3] 
* **Pin 09 [05]** - Input - row[0]
* **Pin 10 [06]** - Input - row[1]
* **Pin 11 [07]** - Input - row[2]
* **Pin 12 [08]** - Input - row[3]
* **Pin 13 [09]** - Output - screenCsx 
* **Pin 14 [10]** - Output - screenDcx 
* **Pin 15 [11]** - Output - screenWrx 
* **Pin 16 [12]** - Output - screenData[0] 
* **Pin 17 [13]** - Output - screenData[1] 
* **Pin 18 [14]** - Output - screenData[2] 
* **Pin 19 [15]** - Output - screenData[3] 
* **Pin 20 [16]** - Output - screenData[4] 
* **Pin 21 [17]** - Output - screenData[5] 
* **Pin 22 [18]** - Output - screenData[6] 
* **Pin 23 [19]** - Output - screenData[7] 
* **Pin 24 [20]** - Not Used
* **Pin 25 [21]** - Not Used 
* **Pin 26 [22]** - Not Used 
* **Pin 27 [23]** - Not Used 
* **Pin 28 [24]** - Not Used 
* **Pin 29 [25]** - Not Used
* **Pin 30 [26]** - Not Used
* **Pin 31 [27]** - Not Used
* **Pin 32 [28]** - Not Used
* **Pin 33 [29]** - Not Used
* **Pin 34 [30]** - Not Used
* **Pin 35 [31]** - Not Used
* **Pin 36 [32]** - Not Used
* **Pin 37 [33]** - Not Used

## External Hardware
List all the required external hardware components and upload a breadboard with the equipment set up (recommend using Tinkercad circuits if possible).
4x4 matrix keypad
TFT LCD screen

## Functionality Description and Testing
Describe in detail how your project works and how to test it.
The user will first interact with the keypad which will send a binary number to the CPU from 1:32 depending on the alpha state. The CPU will then read the value sent from the keypad and either display the corresponding value, operator, or swtich apps. After an equation is typed into the calculator, the graph will be displayed. 

## RTL Diagrams
Include more than just block diagrams, including sub-block diagrams, state-transition diagrams, flowcharts, and timing diagrams. Please include any images or documents of these inside this folder (docs/team_04).