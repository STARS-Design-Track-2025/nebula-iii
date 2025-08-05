# NEBULA III - Project Documentation

## Team 07 - NYC Finance Bros
* **Peer Mentor:** Andy Hu
* Rose Freedman
* Tylar Sparks
* Kameswari Mantha]
* Anna Dalton


## Project Overview
In the project, we designed a 32-bit RISC-V CPU that processes stock value data stored in SRAM and displays visual results on a TFT screen. The CPU interfaces with the display via memory-mapped I/O and integrates both fixed-point and floating-point operations to enable precise data processing and graphical output.
## Pin Layout
Note that on the final chip, there are 38 GPIO pins of which you have access to 34.
The first number represents the GPIO on the physical chip, while the second number (in brackets) represents the number in your Verilog code. For each pin, mention if it is an input, output, or both and describe the pin function.

* **Pin 00 [00]** - Input or Output? - Pin Function?
* **Pin 01 [--]** - NOT ALLOWED
* **Pin 02 [--]** - NOT ALLOWED
* **Pin 03 [--]** - NOT ALLOWED
* **Pin 04 [--]** - NOT ALLOWED
* **Pin 05 [01]** - Input or Output? - Pin Function?
* **Pin 06 [02]** - Input or Output? - Pin Function? 
* **Pin 07 [03]** - Input or Output? - Pin Function? 
* **Pin 08 [04]** - Input or Output? - Pin Function? 
* **Pin 09 [05]** - Input or Output? - Pin Function? 
* **Pin 10 [06]** - Input or Output? - Pin Function?
* **Pin 11 [07]** - Input or Output? - Pin Function?
* **Pin 12 [08]** - Input or Output? - Pin Function?
* **Pin 13 [09]** - Input or Output? - Pin Function? 
* **Pin 14 [10]** - Input or Output? - Pin Function? 
* **Pin 15 [11]** - Input or Output? - Pin Function? 
* **Pin 16 [12]** - Input or Output? - Pin Function? 
* **Pin 17 [13]** - Input or Output? - Pin Function? 
* **Pin 18 [14]** - Input or Output? - Pin Function? 
* **Pin 19 [15]** - Input or Output? - Pin Function? 
* **Pin 20 [16]** - Input or Output? - Pin Function? 
* **Pin 21 [17]** - Input or Output? - Pin Function? 
* **Pin 22 [18]** - Input or Output? - Pin Function? 
* **Pin 23 [19]** - Input or Output? - Pin Function? 
* **Pin 24 [20]** - Input or Output? - Pin Function? 
* **Pin 25 [21]** - Input or Output? - Pin Function? 
* **Pin 26 [22]** - Input or Output? - Pin Function? 
* **Pin 27 [23]** - Input or Output? - Pin Function? 
* **Pin 28 [24]** - Input or Output? - Pin Function? 
* **Pin 29 [25]** - Input or Output? - Pin Function?
* **Pin 30 [26]** - Input or Output? - Pin Function?
* **Pin 31 [27]** - Input or Output? - Pin Function?
* **Pin 32 [28]** - Input or Output? - Pin Function?
* **Pin 33 [29]** - Input or Output? - Pin Function?
* **Pin 34 [30]** - Input or Output? - Pin Function?
* **Pin 35 [31]** - Input or Output? - Pin Function?
* **Pin 36 [32]** - Input or Output? - Pin Function?
* **Pin 37 [33]** - Input or Output? - Pin Function?

## External Hardware
RA8875 Driver and Adafruit Product ID: 1680
## Functionality Description and Testing
Detailed System Description:
This project implements a custom 32-bit RISC-V CPU designed to process stock value data stored in SRAM and generate visual output on a TFT display. The CPU reads values encoded in fixed-point format, converts them to integers, and then casts them to single-precision floating-point using instructions from the RV32F standard extension, developed at the University of California, Berkeley. Each value is compared to the current minimum and maximum, and a color is selected to represent the result: green for a new maximum, red for a new minimum, and white if the value is unchanged. The selected color is sent as a command to the RA8875 TFT controller, which draws a 3×3 pixel block at a computed (x, y) location. The x-position increments with each data point to form a horizontal timeline, while the y-position is scaled proportionally to the value.

The system integrates both integer and floating-point computation: integer arithmetic handles control logic, address calculation, and screen positioning, while RV32F single-precision floating-point operations enable accurate comparison and scaling of stock values. Communication with the display is accomplished by memory-mapped I/O, where specific register addresses are written to in order to issue drawing commands to the RA8875.

Testing Procedure:
To verify system behavior, fixed-point stock value data must be preloaded into SRAM starting at address 0x0421 (decimal 1057) and continuing up to 0x0700 (decimal 1792). The final value in the data-set must be 0x0E0F0E0F, which signals to the CPU that all data has been read. When the program is executed, the CPU reads and processes each value, rendering a corresponding 3×3 pixel block on the TFT display. Proper functionality is confirmed by verifying that each block appears in the correct location and is color-coded according to the value’s relationship to the previously processed values. The output should display a continuous, color-coded timeline of the dataset.
## RTL Diagrams
Include more than just block diagrams, including sub-block diagrams, state-transition diagrams, flowcharts, and timing diagrams. Please include any images or documents of these inside this folder (docs/team_07).
