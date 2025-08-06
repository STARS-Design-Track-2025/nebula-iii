# NEBULA III - Project Documentation

## Team 01 - STARBOY 
* **Peer Mentor:** Johnny Hazboun
* Myles Querimit
* Cristian Andres Martinez
* Safa Islam
* Mixuan Pan

## Project Overview
Welcome to Tetris! This version of tetris was created by STARS 2025 Team 1 by Cristian, Safa, Mixuan, and Myles. 

This document will go over button layouts, features/hardware, and general gameplay.

## Pin Layout
Note that on the final chip, there are 38 GPIO pins of which you have access to 34.
The first number represents the GPIO on the physical chip, while the second number (in brackets) represents the number in your Verilog code. For each pin, mention if it is an input, output, or both and describe the pin function.

* **Pin 00 [00]** - Input or Output? - Pin Function?
* **Pin 01 [--]** - NOT ALLOWED
* **Pin 02 [--]** - NOT ALLOWED
* **Pin 03 [--]** - NOT ALLOWED
* **Pin 04 [--]** - NOT ALLOWED
* **Pin 05 [01]** - Input - MOVE LEFT
* **Pin 06 [02]** - Input - MOVE RIGHT
* **Pin 07 [03]** - Input - ROTATE LEFT
* **Pin 08 [04]** - Input - ROTATE RIGHT
* **Pin 09 [05]** - Input - SOFT DROP
* **Pin 10 [06]** - Input - PLAYER START
* **Pin 11 [07]** - Input - AI START
* **Pin 12 [08]** - Output - VGA HSYNC
* **Pin 13 [09]** - Output - VGA VSYNC
* **Pin 14 [10]** - Output - VGA RED
* **Pin 15 [11]** - Output - VGA GREEN
* **Pin 16 [12]** - Output - VGA BLUE
* **Pin 17 [13]** - Output - SPEAKER
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
VGA BREAKOUT BOARD & CABLE - <img width="1100" height="1100" alt="image" src="https://github.com/user-attachments/assets/bec0ba27-aaed-40e8-8317-df5e80f49e8e" />

Easy access to wires necessary for display

MONITOR - Compatible VGA Display (needs to support 640 x 480 @ 60 Hz, 25 MHz clock)

SPEAKER  & AMPLIFIER -
<img width="2205" height="2015" alt="image" src="https://github.com/user-attachments/assets/6204af3d-272e-4158-bbe0-0e92222c4fcc" />
The amplifier connects to the speaker and ground and FPGA itself.
For speakers, we used a Logitech 

## Functionality Description and Testing
This project is a recreation of Tetris, so all the same rules apply. The best way to test functionality is to wire up buttons and test if inputs are correspond and are valid. 
See presentation for demo video @ testbench example [HERE](https://docs.google.com/presentation/d/e/2PACX-1vQ5J6eAg-fM0MYb9h2nug7m4cWLqn1QPYuZf28jpfTcCsExHs7RleSBiXM36svMkUjVlpEQlcR1J1pw/pub?start=false&loop=false&delayms=3000#slide=id.g372a1441054_2_34)

POINT SYSTEM:
1 line - 1 point
2 lines - 3 points
3 lines - 5 points
4 lines (TETRIS) - 8 points

If you get to a point where you spawn a block on another block (reaching the top of the grid), you will reach a GAMEOVER state, you can easily reset to the beginning by pressing the MOVE RIGHT button followed by the PLAYER START button.

Note: If you're at an edge or by a block, you may not be able to rotate. This is by design, as theres a check to see if the next rotation would be valid and not bump into anything. Make some room to rotate :3

## RTL Diagrams
Include more than just block diagrams, including sub-block diagrams, state-transition diagrams, flowcharts, and timing diagrams. Please include any images or documents of these inside this folder (docs/team_01).
