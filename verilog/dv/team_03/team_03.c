/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include <defs.h>
#include <stub.c>

// List of Wishbone Slave Addresses

// Change this to 300X0000 where X is your team number
#define reg_team_03_EN (*(volatile uint32_t*)0x30030000)

// GPIO Control
#define reg_gpio_PIN_0TO7 (*(volatile uint32_t*)0x32000000)
#define reg_gpio_PIN_8TO15 (*(volatile uint32_t*)0x32000004)
#define reg_gpio_PIN_16TO23 (*(volatile uint32_t*)0x32000008)
#define reg_gpio_PIN_24TO31 (*(volatile uint32_t*)0x3200000C)
#define reg_gpio_PIN_32TO37 (*(volatile uint32_t*)0x32000010)

// LA Control
#define reg_la_sel (*(volatile uint32_t*)0x31000000)

// SRAM address space
#define sram_space (*(volatile uint32_t*)0x33000000)

void main()
{
	/* 
	IO Control Registers
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 3-bits | 1-bit | 1-bit | 1-bit  | 1-bit  | 1-bit | 1-bit   | 1-bit   | 1-bit | 1-bit | 1-bit   |

	Output: 0000_0110_0000_1110  (0x1808) = GPIO_MODE_USER_STD_OUTPUT
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 110    | 0     | 0     | 0      | 0      | 0     | 0       | 1       | 0     | 0     | 0       |
	
	 
	Input: 0000_0001_0000_1111 (0x0402) = GPIO_MODE_USER_STD_INPUT_NOPULL
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 001    | 0     | 0     | 0      | 0      | 0     | 0       | 0       | 0     | 1     | 0       |

	*/

	/* Set up the housekeeping SPI to be connected internally so	*/
	/* that external pin changes don't affect it.			*/

	reg_spi_enable = 1;
    reg_wb_enable = 1;
	// reg_spimaster_cs = 0x10001;
	// reg_spimaster_control = 0x0801;

	// reg_spimaster_control = 0xa002;	// Enable, prescaler = 2,
                                        // connect to housekeeping SPI

	// Connect the housekeeping SPI to the SPI master
	// so that the CSB line is not left floating.  This allows
	// all of the GPIO pins to be used for user functions.

	// Configure IO[0] and IO[37:5] to outputs
	reg_mprj_io_0 =  GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_5 = GPIO_MODE_USER_STD_OUTPUT; //hsync
    reg_mprj_io_6 = GPIO_MODE_USER_STD_OUTPUT; //vsync
    reg_mprj_io_7 = GPIO_MODE_USER_STD_OUTPUT; //r2
    reg_mprj_io_8 = GPIO_MODE_USER_STD_OUTPUT; //r1
    reg_mprj_io_9 = GPIO_MODE_USER_STD_OUTPUT; //r0
    reg_mprj_io_10 = GPIO_MODE_USER_STD_OUTPUT; //g2
    reg_mprj_io_11 = GPIO_MODE_USER_STD_OUTPUT; //g1
    reg_mprj_io_12 = GPIO_MODE_USER_STD_OUTPUT; //g0
    reg_mprj_io_13 = GPIO_MODE_USER_STD_OUTPUT; //b1
    reg_mprj_io_14 = GPIO_MODE_USER_STD_OUTPUT; //b0
    reg_mprj_io_15 = GPIO_MODE_USER_STD_OUTPUT; //pulse
    reg_mprj_io_16 = GPIO_MODE_USER_STD_OUTPUT; //latch
    reg_mprj_io_17 = GPIO_MODE_USER_STD_INPUT_NOPULL; // player1
    reg_mprj_io_18 = GPIO_MODE_USER_STD_INPUT_NOPULL; // player2
    reg_mprj_io_19 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_20 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_21 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_22 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_23 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_24 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_25 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_26 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_27 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_28 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_29 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_30 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_31 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_32 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_33 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_34 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_35 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_36 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_37 = GPIO_MODE_USER_STD_OUTPUT;

	// Now, apply configuration
	reg_mprj_xfer = 1;
	while (reg_mprj_xfer == 1);

	// ****************************************
	// PLL Configuration (Configure to 40 MHz)
	// ****************************************

	// NO PLL CONFIG NEEDED LOL

	// Set PLL enable, no DCO mode
    // reg_hkspi_pll_ena = 0x1;

	// Set both PLL output dividers to 4
    // reg_hkspi_pll_source = 0x24;

	// Write 16 to feedback divider
    // reg_hkspi_pll_divider = 0x10;

	// Disable PLL bypass
    // reg_hkspi_pll_bypass = 0x0;

	// Configure All LA probes as inputs to the cpu 
	reg_la0_oenb = reg_la0_iena = 0x00000000;    // [31:0]
	reg_la1_oenb = reg_la1_iena = 0x00000000;    // [63:32]
	reg_la2_oenb = reg_la2_iena = 0x00000000;    // [95:64]
	reg_la3_oenb = reg_la3_iena = 0x00000000;    // [127:96]

	// Configure GPIOs outputs to be selected by your team.
	// To do this, you must change each of the digits below to your team number in Hex.
	// e.g. if you are Team 11, change the first reg to 0xBBBBBBBB
	// Each nibble is used by the GPIO control unit to determine the which input to the GPIO
	// controls the output.  This allows for multiple projects to interface with the outside world
	// simultaneously if desired.
	reg_gpio_PIN_0TO7 = 0x33333333;
	reg_gpio_PIN_8TO15 = 0x33333333;
	reg_gpio_PIN_16TO23 = 0x33333333;
	reg_gpio_PIN_24TO31 = 0x33333333;
	reg_gpio_PIN_32TO37 = 0x333333;

	// Load instructions to RAM
	*(&sram_space + 0) = 0x00000013;
	*(&sram_space + 1) = 0x00000013;
	*(&sram_space + 2) = 0x00000013;
	*(&sram_space + 3) = 0x00000013;
	*(&sram_space + 4) = 0x00000013;
	*(&sram_space + 5) = 0x00000013;
	*(&sram_space + 6) = 0x00000013;
	*(&sram_space + 7) = 0x00000013;
	*(&sram_space + 8) = 0x00000013;
	*(&sram_space + 9) = 0x00000013;
	*(&sram_space + 10) = 0x00000013;
	*(&sram_space + 11) = 0x00000013;
	*(&sram_space + 12) = 0x00000013;
	*(&sram_space + 13) = 0x00000013;
	*(&sram_space + 14) = 0x00000013;
	*(&sram_space + 15) = 0x00000013;
	*(&sram_space + 16) = 0x00000013;
	*(&sram_space + 17) = 0x00000013;
	*(&sram_space + 18) = 0x00000013;
	*(&sram_space + 19) = 0x00000013;
	*(&sram_space + 20) = 0x00000013;
	*(&sram_space + 21) = 0x00000013;
	*(&sram_space + 22) = 0x00000013;
	*(&sram_space + 23) = 0x00000013;
	*(&sram_space + 24) = 0x00000013;
	*(&sram_space + 25) = 0x00000013;
	*(&sram_space + 26) = 0x00000013;
	*(&sram_space + 27) = 0x00000013;
	*(&sram_space + 28) = 0x00000013;
	*(&sram_space + 29) = 0x00000013;
	*(&sram_space + 30) = 0x00000013;
	*(&sram_space + 31) = 0x00000013;
	*(&sram_space + 32) = 0x00000013;
	*(&sram_space + 33) = 0x00000013;
	*(&sram_space + 34) = 0x00000013;
	*(&sram_space + 35) = 0x00000013;
	*(&sram_space + 36) = 0x00000013;
	*(&sram_space + 37) = 0x00000013;
	*(&sram_space + 38) = 0x00000013;
	*(&sram_space + 39) = 0xff000fb7;
	*(&sram_space + 40) = 0x00aa0137;
	*(&sram_space + 41) = 0x00000337;
	*(&sram_space + 42) = 0x02530313;
	*(&sram_space + 43) = 0x000003b7;
	*(&sram_space + 44) = 0x05538393;
	*(&sram_space + 45) = 0x00000437;
	*(&sram_space + 46) = 0x01d40413;
	*(&sram_space + 47) = 0x000004b7;
	*(&sram_space + 48) = 0x01d48493;
	*(&sram_space + 49) = 0x00000537;
	*(&sram_space + 50) = 0x00a50513;
	*(&sram_space + 51) = 0x000005b7;
	*(&sram_space + 52) = 0x00a58593;
	*(&sram_space + 53) = 0x251d50b7;
	*(&sram_space + 54) = 0x51d08093;
	*(&sram_space + 55) = 0x001fa423;
	*(&sram_space + 56) = 0x00cfa283;
	*(&sram_space + 57) = 0x251d50b7;
	*(&sram_space + 58) = 0x51d08093;
	*(&sram_space + 59) = 0x001fa423;
	*(&sram_space + 60) = 0x00000537;
	*(&sram_space + 61) = 0x00a50513;
	*(&sram_space + 62) = 0x000005b7;
	*(&sram_space + 63) = 0x00a58593;
	*(&sram_space + 64) = 0x00aa0eb7;
	*(&sram_space + 65) = 0x05d11263;
	*(&sram_space + 66) = 0x251d50b7;
	*(&sram_space + 67) = 0x51d08093;
	*(&sram_space + 68) = 0x001fa423;
	*(&sram_space + 69) = 0x000fa183;
	*(&sram_space + 70) = 0x00100f37;
	*(&sram_space + 71) = 0x01e1feb3;
	*(&sram_space + 72) = 0x000e8a63;
	*(&sram_space + 73) = 0x10000f37;
	*(&sram_space + 74) = 0x01e16133;
	*(&sram_space + 75) = 0x002fa223;
	*(&sram_space + 76) = 0x0040006f;
	*(&sram_space + 77) = 0x251d50b7;
	*(&sram_space + 78) = 0x51d08093;
	*(&sram_space + 79) = 0x001fa423;
	*(&sram_space + 80) = 0x002fa223;
	*(&sram_space + 81) = 0xfbdff06f;
	*(&sram_space + 82) = 0x00cfa283;
	*(&sram_space + 83) = 0xf0000f37;
	*(&sram_space + 84) = 0x01e17833;
	*(&sram_space + 85) = 0x40000eb7;
	*(&sram_space + 86) = 0x03d80c63;
	*(&sram_space + 87) = 0x00cfa203;
	*(&sram_space + 88) = 0x405208b3;
	*(&sram_space + 89) = 0x00000eb7;
	*(&sram_space + 90) = 0x3e8e8e93;
	*(&sram_space + 91) = 0x011edc63;
	*(&sram_space + 92) = 0x10000f37;
	*(&sram_space + 93) = 0x01e10133;
	*(&sram_space + 94) = 0x002fa223;
	*(&sram_space + 95) = 0x00cfa283;
	*(&sram_space + 96) = 0x0040006f;
	*(&sram_space + 97) = 0xf0000f37;
	*(&sram_space + 98) = 0x01e17833;
	*(&sram_space + 99) = 0xfc9ff06f;
	*(&sram_space + 100) = 0x00000f37;
	*(&sram_space + 101) = 0x01cf0f13;
	*(&sram_space + 102) = 0x01c15693;
	*(&sram_space + 103) = 0x00000337;
	*(&sram_space + 104) = 0x02530313;
	*(&sram_space + 105) = 0x000003b7;
	*(&sram_space + 106) = 0x05538393;
	*(&sram_space + 107) = 0x00000eb7;
	*(&sram_space + 108) = 0x004e8e93;
	*(&sram_space + 109) = 0x4bd69063;
	*(&sram_space + 110) = 0x00cfa203;
	*(&sram_space + 111) = 0x405208b3;
	*(&sram_space + 112) = 0x40638933;
	*(&sram_space + 113) = 0x00000eb7;
	*(&sram_space + 114) = 0x032e8e93;
	*(&sram_space + 115) = 0x43d8c263;
	*(&sram_space + 116) = 0x000fa183;
	*(&sram_space + 117) = 0x00000eb7;
	*(&sram_space + 118) = 0x01de8e93;
	*(&sram_space + 119) = 0x008ed863;
	*(&sram_space + 120) = 0xffe70713;
	*(&sram_space + 121) = 0x00e40433;
	*(&sram_space + 122) = 0x0040006f;
	*(&sram_space + 123) = 0x00000eb7;
	*(&sram_space + 124) = 0x01de8e93;
	*(&sram_space + 125) = 0x009ed863;
	*(&sram_space + 126) = 0xffe78793;
	*(&sram_space + 127) = 0x00f484b3;
	*(&sram_space + 128) = 0x0040006f;
	*(&sram_space + 129) = 0x00000eb7;
	*(&sram_space + 130) = 0x01de8e93;
	*(&sram_space + 131) = 0x009eca63;
	*(&sram_space + 132) = 0x000007b7;
	*(&sram_space + 133) = 0x000004b7;
	*(&sram_space + 134) = 0x01d48493;
	*(&sram_space + 135) = 0x0040006f;
	*(&sram_space + 136) = 0x00000eb7;
	*(&sram_space + 137) = 0x01de8e93;
	*(&sram_space + 138) = 0x008eca63;
	*(&sram_space + 139) = 0x00000737;
	*(&sram_space + 140) = 0x00000437;
	*(&sram_space + 141) = 0x01d40413;
	*(&sram_space + 142) = 0x0040006f;
	*(&sram_space + 143) = 0x40ff0f37;
	*(&sram_space + 144) = 0x003f0f13;
	*(&sram_space + 145) = 0x01e17133;
	*(&sram_space + 146) = 0x10000f37;
	*(&sram_space + 147) = 0x01e1feb3;
	*(&sram_space + 148) = 0x000e8863;
	*(&sram_space + 149) = 0x04000f37;
	*(&sram_space + 150) = 0x01e16133;
	*(&sram_space + 151) = 0x0040006f;
	*(&sram_space + 152) = 0x20000f37;
	*(&sram_space + 153) = 0x01e1feb3;
	*(&sram_space + 154) = 0x000e8863;
	*(&sram_space + 155) = 0x08000f37;
	*(&sram_space + 156) = 0x01e16133;
	*(&sram_space + 157) = 0x0040006f;
	*(&sram_space + 158) = 0x01000f37;
	*(&sram_space + 159) = 0x01e1feb3;
	*(&sram_space + 160) = 0x000e8863;
	*(&sram_space + 161) = 0x01000f37;
	*(&sram_space + 162) = 0x01e16133;
	*(&sram_space + 163) = 0x0040006f;
	*(&sram_space + 164) = 0x02000f37;
	*(&sram_space + 165) = 0x01e1feb3;
	*(&sram_space + 166) = 0x000e8863;
	*(&sram_space + 167) = 0x02000f37;
	*(&sram_space + 168) = 0x01e16133;
	*(&sram_space + 169) = 0x0040006f;
	*(&sram_space + 170) = 0x40638933;
	*(&sram_space + 171) = 0x408489b3;
	*(&sram_space + 172) = 0x00095663;
	*(&sram_space + 173) = 0x40730933;
	*(&sram_space + 174) = 0x0040006f;
	*(&sram_space + 175) = 0x0009d663;
	*(&sram_space + 176) = 0x409409b3;
	*(&sram_space + 177) = 0x0040006f;
	*(&sram_space + 178) = 0x00000eb7;
	*(&sram_space + 179) = 0x013e8e93;
	*(&sram_space + 180) = 0x13d95463;
	*(&sram_space + 181) = 0x00000eb7;
	*(&sram_space + 182) = 0x00ae8e93;
	*(&sram_space + 183) = 0x11d9dc63;
	*(&sram_space + 184) = 0x10000f37;
	*(&sram_space + 185) = 0x01e1feb3;
	*(&sram_space + 186) = 0x080e8263;
	*(&sram_space + 187) = 0x02000f37;
	*(&sram_space + 188) = 0x01e1feb3;
	*(&sram_space + 189) = 0x000e8463;
	*(&sram_space + 190) = 0x0700006f;
	*(&sram_space + 191) = 0xfff58593;
	*(&sram_space + 192) = 0x00000f37;
	*(&sram_space + 193) = 0x010f0f13;
	*(&sram_space + 194) = 0x01059693;
	*(&sram_space + 195) = 0xfff10f37;
	*(&sram_space + 196) = 0xffff0f13;
	*(&sram_space + 197) = 0x01e17133;
	*(&sram_space + 198) = 0x00d16133;
	*(&sram_space + 199) = 0x00735863;
	*(&sram_space + 200) = 0x00030393;
	*(&sram_space + 201) = 0x01938393;
	*(&sram_space + 202) = 0x00c0006f;
	*(&sram_space + 203) = 0x00030393;
	*(&sram_space + 204) = 0xfe738393;
	*(&sram_space + 205) = 0x00000eb7;
	*(&sram_space + 206) = 0x091e8e93;
	*(&sram_space + 207) = 0x007edc63;
	*(&sram_space + 208) = 0x000003b7;
	*(&sram_space + 209) = 0x09138393;
	*(&sram_space + 210) = 0x00038313;
	*(&sram_space + 211) = 0xfe730313;
	*(&sram_space + 212) = 0x0040006f;
	*(&sram_space + 213) = 0x0003da63;
	*(&sram_space + 214) = 0x000003b7;
	*(&sram_space + 215) = 0x00038313;
	*(&sram_space + 216) = 0x01930313;
	*(&sram_space + 217) = 0x0040006f;
	*(&sram_space + 218) = 0x0040006f;
	*(&sram_space + 219) = 0x01000f37;
	*(&sram_space + 220) = 0x01e1feb3;
	*(&sram_space + 221) = 0x060e8e63;
	*(&sram_space + 222) = 0x20000f37;
	*(&sram_space + 223) = 0x01e1feb3;
	*(&sram_space + 224) = 0x000e8463;
	*(&sram_space + 225) = 0x0680006f;
	*(&sram_space + 226) = 0xfff50513;
	*(&sram_space + 227) = 0x00000f37;
	*(&sram_space + 228) = 0x014f0f13;
	*(&sram_space + 229) = 0x01451693;
	*(&sram_space + 230) = 0xff100f37;
	*(&sram_space + 231) = 0xffff0f13;
	*(&sram_space + 232) = 0x01e17133;
	*(&sram_space + 233) = 0x00d16133;
	*(&sram_space + 234) = 0x00735863;
	*(&sram_space + 235) = 0x00038313;
	*(&sram_space + 236) = 0xfe730313;
	*(&sram_space + 237) = 0x00c0006f;
	*(&sram_space + 238) = 0x00038313;
	*(&sram_space + 239) = 0x01930313;
	*(&sram_space + 240) = 0x00000eb7;
	*(&sram_space + 241) = 0x091e8e93;
	*(&sram_space + 242) = 0x006ed863;
	*(&sram_space + 243) = 0x00000337;
	*(&sram_space + 244) = 0x09130313;
	*(&sram_space + 245) = 0x0040006f;
	*(&sram_space + 246) = 0x00035a63;
	*(&sram_space + 247) = 0x00000337;
	*(&sram_space + 248) = 0x00030393;
	*(&sram_space + 249) = 0x01938393;
	*(&sram_space + 250) = 0x0040006f;
	*(&sram_space + 251) = 0x0040006f;
	*(&sram_space + 252) = 0x0040006f;
	*(&sram_space + 253) = 0x0040006f;
	*(&sram_space + 254) = 0x00000eb7;
	*(&sram_space + 255) = 0x010e8e93;
	*(&sram_space + 256) = 0x01d95c63;
	*(&sram_space + 257) = 0x00941863;
	*(&sram_space + 258) = 0x00000637;
	*(&sram_space + 259) = 0x00160613;
	*(&sram_space + 260) = 0x0040006f;
	*(&sram_space + 261) = 0x0040006f;
	*(&sram_space + 262) = 0x00000eb7;
	*(&sram_space + 263) = 0x001e8e93;
	*(&sram_space + 264) = 0x07d61263;
	*(&sram_space + 265) = 0x00000637;
	*(&sram_space + 266) = 0x02735863;
	*(&sram_space + 267) = 0xfff30313;
	*(&sram_space + 268) = 0x00000eb7;
	*(&sram_space + 269) = 0x091e8e93;
	*(&sram_space + 270) = 0x006ed863;
	*(&sram_space + 271) = 0x00000337;
	*(&sram_space + 272) = 0x09130313;
	*(&sram_space + 273) = 0x0040006f;
	*(&sram_space + 274) = 0x00035663;
	*(&sram_space + 275) = 0x00000337;
	*(&sram_space + 276) = 0x0040006f;
	*(&sram_space + 277) = 0x02c0006f;
	*(&sram_space + 278) = 0x00130313;
	*(&sram_space + 279) = 0x00000eb7;
	*(&sram_space + 280) = 0x091e8e93;
	*(&sram_space + 281) = 0x006ed863;
	*(&sram_space + 282) = 0x00000337;
	*(&sram_space + 283) = 0x09130313;
	*(&sram_space + 284) = 0x0040006f;
	*(&sram_space + 285) = 0x00035663;
	*(&sram_space + 286) = 0x00000337;
	*(&sram_space + 287) = 0x0040006f;
	*(&sram_space + 288) = 0x1680006f;
	*(&sram_space + 289) = 0x00018e93;
	*(&sram_space + 290) = 0x100efe93;
	*(&sram_space + 291) = 0x020e8463;
	*(&sram_space + 292) = 0x00338393;
	*(&sram_space + 293) = 0x00116113;
	*(&sram_space + 294) = 0x00000eb7;
	*(&sram_space + 295) = 0x091e8e93;
	*(&sram_space + 296) = 0x007ed863;
	*(&sram_space + 297) = 0x000003b7;
	*(&sram_space + 298) = 0x09138393;
	*(&sram_space + 299) = 0x0040006f;
	*(&sram_space + 300) = 0x0040006f;
	*(&sram_space + 301) = 0x00018e93;
	*(&sram_space + 302) = 0x200efe93;
	*(&sram_space + 303) = 0x020e8263;
	*(&sram_space + 304) = 0xffd38393;
	*(&sram_space + 305) = 0x00000f37;
	*(&sram_space + 306) = 0xf00f0f13;
	*(&sram_space + 307) = 0x01e17133;
	*(&sram_space + 308) = 0x0003d663;
	*(&sram_space + 309) = 0x000003b7;
	*(&sram_space + 310) = 0x0040006f;
	*(&sram_space + 311) = 0x0040006f;
	*(&sram_space + 312) = 0x00018e93;
	*(&sram_space + 313) = 0x400efe93;
	*(&sram_space + 314) = 0x000e8e63;
	*(&sram_space + 315) = 0x00000eb7;
	*(&sram_space + 316) = 0x03ce8e93;
	*(&sram_space + 317) = 0x009ed663;
	*(&sram_space + 318) = 0xfe248493;
	*(&sram_space + 319) = 0x0040006f;
	*(&sram_space + 320) = 0x0040006f;
	*(&sram_space + 321) = 0x00001f37;
	*(&sram_space + 322) = 0x800f0f13;
	*(&sram_space + 323) = 0x01e1feb3;
	*(&sram_space + 324) = 0x020e8463;
	*(&sram_space + 325) = 0x00000eb7;
	*(&sram_space + 326) = 0x01de8e93;
	*(&sram_space + 327) = 0x01d49c63;
	*(&sram_space + 328) = 0x000007b7;
	*(&sram_space + 329) = 0x01a78793;
	*(&sram_space + 330) = 0x000004b7;
	*(&sram_space + 331) = 0x01e48493;
	*(&sram_space + 332) = 0x0040006f;
	*(&sram_space + 333) = 0x0040006f;
	*(&sram_space + 334) = 0x00010f37;
	*(&sram_space + 335) = 0x01e1feb3;
	*(&sram_space + 336) = 0x020e8863;
	*(&sram_space + 337) = 0x00330313;
	*(&sram_space + 338) = 0x00000f37;
	*(&sram_space + 339) = 0xf00f0f13;
	*(&sram_space + 340) = 0x01e17133;
	*(&sram_space + 341) = 0x00000eb7;
	*(&sram_space + 342) = 0x091e8e93;
	*(&sram_space + 343) = 0x006ed863;
	*(&sram_space + 344) = 0x00000337;
	*(&sram_space + 345) = 0x09130313;
	*(&sram_space + 346) = 0x0040006f;
	*(&sram_space + 347) = 0x0040006f;
	*(&sram_space + 348) = 0x00020f37;
	*(&sram_space + 349) = 0x01e1feb3;
	*(&sram_space + 350) = 0x000e8e63;
	*(&sram_space + 351) = 0xffd30313;
	*(&sram_space + 352) = 0x00216113;
	*(&sram_space + 353) = 0x00035663;
	*(&sram_space + 354) = 0x00000337;
	*(&sram_space + 355) = 0x0040006f;
	*(&sram_space + 356) = 0x0040006f;
	*(&sram_space + 357) = 0x00040f37;
	*(&sram_space + 358) = 0x01e1feb3;
	*(&sram_space + 359) = 0x000e8e63;
	*(&sram_space + 360) = 0x00000eb7;
	*(&sram_space + 361) = 0x03ce8e93;
	*(&sram_space + 362) = 0x008ed663;
	*(&sram_space + 363) = 0xfe240413;
	*(&sram_space + 364) = 0x0040006f;
	*(&sram_space + 365) = 0x0040006f;
	*(&sram_space + 366) = 0x00080f37;
	*(&sram_space + 367) = 0x01e1feb3;
	*(&sram_space + 368) = 0x020e8463;
	*(&sram_space + 369) = 0x00000eb7;
	*(&sram_space + 370) = 0x01de8e93;
	*(&sram_space + 371) = 0x01d41c63;
	*(&sram_space + 372) = 0x00000737;
	*(&sram_space + 373) = 0x01a70713;
	*(&sram_space + 374) = 0x00000437;
	*(&sram_space + 375) = 0x01e40413;
	*(&sram_space + 376) = 0x0040006f;
	*(&sram_space + 377) = 0x0040006f;
	*(&sram_space + 378) = 0x00cfa283;
	*(&sram_space + 379) = 0x0040006f;
	*(&sram_space + 380) = 0x00051663;
	*(&sram_space + 381) = 0x6c000137;
	*(&sram_space + 382) = 0x0040006f;
	*(&sram_space + 383) = 0x00059663;
	*(&sram_space + 384) = 0x53000137;
	*(&sram_space + 385) = 0x0040006f;
	*(&sram_space + 386) = 0x00000f37;
	*(&sram_space + 387) = 0x018f0f13;
	*(&sram_space + 388) = 0x01831093;
	*(&sram_space + 389) = 0x00000f37;
	*(&sram_space + 390) = 0x010f0f13;
	*(&sram_space + 391) = 0x01041693;
	*(&sram_space + 392) = 0x00d0e0b3;
	*(&sram_space + 393) = 0x00000f37;
	*(&sram_space + 394) = 0x008f0f13;
	*(&sram_space + 395) = 0x00839693;
	*(&sram_space + 396) = 0x00d0e0b3;
	*(&sram_space + 397) = 0x00048693;
	*(&sram_space + 398) = 0x00d0e0b3;
	*(&sram_space + 399) = 0x001fa423;
	*(&sram_space + 400) = 0x002fa223;
	*(&sram_space + 401) = 0x00000f37;
	*(&sram_space + 402) = 0x01cf0f13;
	*(&sram_space + 403) = 0x01c15693;
	*(&sram_space + 404) = 0xb5dff06f;
	*(&sram_space + 405) = 0x53000eb7;
	*(&sram_space + 406) = 0x03d11863;
	*(&sram_space + 407) = 0x251d00b7;
	*(&sram_space + 408) = 0x01d08093;
	*(&sram_space + 409) = 0x000fa183;
	*(&sram_space + 410) = 0x00100f37;
	*(&sram_space + 411) = 0x01e1feb3;
	*(&sram_space + 412) = 0x000e8663;
	*(&sram_space + 413) = 0x00aa0137;
	*(&sram_space + 414) = 0x0040006f;
	*(&sram_space + 415) = 0x001fa423;
	*(&sram_space + 416) = 0x002fa223;
	*(&sram_space + 417) = 0xfd1ff06f;
	*(&sram_space + 418) = 0x6c000eb7;
	*(&sram_space + 419) = 0x03d11863;
	*(&sram_space + 420) = 0x001d50b7;
	*(&sram_space + 421) = 0x51d08093;
	*(&sram_space + 422) = 0x000fa183;
	*(&sram_space + 423) = 0x00100f37;
	*(&sram_space + 424) = 0x01e1feb3;
	*(&sram_space + 425) = 0x000e8663;
	*(&sram_space + 426) = 0x10aa0137;
	*(&sram_space + 427) = 0x0040006f;
	*(&sram_space + 428) = 0x001fa423;
	*(&sram_space + 429) = 0x002fa223;
	*(&sram_space + 430) = 0xfd1ff06f;
	*(&sram_space + 431) = 0xa29ff06f;
	*(&sram_space + 432) = 0x00008067;
	
	// Enable your design
	reg_team_03_EN = 1;
}
