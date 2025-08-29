# NEBULA III - Project Documentation

## Team 04 - ADRIAN
**Peer Mentor:** Adrian Buczkowski
* Omar Habli
* Jeff Liu
* Owen Yao
* Darren Huang
* Ethan Peyton

## Project Overview
Our project is a single-cycle RISC-V CPU for a graphing calculator. The user types in an equation using the keypad and the graph of the equation will be displayed.

## Pin Layout
The first number represents the GPIO on the physical chip, while the second number (in brackets) represents the number in your Verilog code. For each pin, mention if it is an input, output, or both and describe the pin function. Note that on the final chip, there are 38 GPIO pins of which you have access to 34.

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
This project uses a 4x4 matrix keypad and a TFT LCD screen

## Functionality Description and Testing
The user will first interact with the keypad by pressing the buttons, which will send a binary number to the CPU from 1:32 depending on the "alpha" state. The CPU will then read the value sent from the keypad and either display the corresponding value, operator, or switch from an equation state to a graphing state. After the user switches to a graphing state, the equation entered in the equation state is graphed and displayed on the LCD screen.

## RTL Diagrams
All block diagrams, sub-block diagrams, state-transition diagrams, and flowcharts used for this project are inside this folder (docs/team_04).