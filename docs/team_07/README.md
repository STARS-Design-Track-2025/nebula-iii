# NEBULA III - Project Documentation

## Team 07 - NYC Finance Bros - CPU for Stock Pattern Recognition
* **Peer Mentor:** Andy Hu
* Rose Freedman
* Tylar Sparks
* Kameswari Mantha
* Anna Dalton


## Project Overview
In the project, we designed a single cycle RISC-V CPU with a custom fixed-point extension that processes stock value data stored in SRAM and displays visual results on a TFT screen. The CPU interfaces with the display via memory-mapped I/O and integrates both fixed-point and floating-point operations to enable precise data processing and graphical output.
## Pin Layout
Note that on the final chip, there are 38 GPIO pins of which you have access to 34.
The first number represents the GPIO on the physical chip, while the second number (in brackets) represents the number in your Verilog code. For each pin, mention if it is an input, output, or both and describe the pin function.

* **Pin 00 [00]** - Not Used
* **Pin 01 [--]** - NOT ALLOWED
* **Pin 02 [--]** - NOT ALLOWED
* **Pin 03 [--]** - NOT ALLOWED
* **Pin 04 [--]** - NOT ALLOWED
* **Pin 05 [01]** - Output - SCK for the RA8875 driver, connected to screen
* **Pin 06 [02]** - Input - MISO line for the RA8875 driver
* **Pin 07 [03]** - Output - MOSI line for the RA8875 driver
* **Pin 08 [04]** - Output - Chip Select (CS) for the RA8875 driver
* **Pin 09 [05]** - Output - invalError debugging LED
* **Pin 10 [06]** - Not Used
* **Pin 11 [07]** - Not Used
* **Pin 12 [08]** - Not Used 
* **Pin 13 [09]** - Not Used 
* **Pin 14 [10]** - Not Used 
* **Pin 15 [11]** - Not Used 
* **Pin 16 [12]** - Not Used 
* **Pin 17 [13]** - Not Used 
* **Pin 18 [14]** - Not Used 
* **Pin 19 [15]** - Not Used 
* **Pin 20 [16]** - Not Used 
* **Pin 21 [17]** - Not Used 
* **Pin 22 [18]** - Not Used 
* **Pin 23 [19]** - Not Used 
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
RA8875 Driver and Adafruit Product ID: 1680
## Functionality Description and Testing
Detailed System Description:

This project implements a custom single-cycle RISC-V CPU designed to process stock value data stored in SRAM and generate visual output on a TFT display. The CPU reads values encoded in fixed-point format, converts them to integers, and then casts them to single-precision floating-point using instructions from the RV32F standard extension, developed at the University of California, Berkeley. Each value is compared to the current minimum and maximum, and a color is selected to represent the result: green for a new maximum, red for a new minimum, and white if the value is unchanged. The selected color is sent as a command to the RA8875 TFT controller, which draws a 3×3 pixel block at a computed (x, y) location. The x-position increments with each data point to form a horizontal timeline, while the y-position is scaled proportionally to the value.

The system integrates both integer and fixed-point computation: integer arithmetic unit handles control logic, address calculation, and screen positioning, while RV32F single-precision floating-point operations enable accurate comparison and scaling of stock values. Communication with the display is accomplished by memory-mapped I/O, where specific register addresses are written to in order to issue drawing commands to the RA8875.

Testing Procedure:

To verify system behavior, fixed-point stock value data must be preloaded into SRAM starting at address 0x0421 (decimal 1057) and continuing up to 0x0700 (decimal 1792). The final value in the data-set must be 0xE0F0E0F0, which signals to the CPU that all data has been read. When the program is executed, the CPU reads and processes each value, rendering a corresponding 3×3 pixel block on the TFT display. Proper functionality is confirmed by verifying that each block appears in the correct location and is color-coded according to the value’s relationship to the previously processed values. The output should display a continuous, color-coded timeline of the dataset.
## RTL Diagrams
Include more than just block diagrams, including sub-block diagrams, state-transition diagrams, flowcharts, and timing diagrams. Please include any images or documents of these inside this folder (docs/team_07).
