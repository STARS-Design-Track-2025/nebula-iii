//TODO: The registers designated in MMIO need to be altered a bit on the hardware level but this will be done later

/*
Catalog of how registers are used: 
    - rs0: Fixed at 0
        - This also serves as the display command for no operation. 
    - rs1: 
    - rs2: 
    - rs3: 
    - rs4: 
    - rs5: 
    - rs6: 
    - rs7: 
    - rs8: 
    - rs9: 
    - rs10: 
    - rs11: red color
    - rs12: orange color
    - rs13: yellow color
    - rs14: green color
    - rs15: blue color
    - rs16: purple color
    - rs17: pink color
    - rs18: black color
    - rs19: Holds the coordinate input from I2C
    - rs20: Holds the done signal from I2C
    - rs21: 
    - rs22: Fixed at 2A (column address set command hex value)
    - rs23: Fixed at 2B (page address set command hex value)
    - rs24: Fixed at 2C (memory write command hex value)
    - rs25: SPI command address 121212
    - rs26: SPI parameters address 333333
    - rs27: Used for storing the start and end columns for the display screen for the column address set command
    - rs28: Used for storing the start and end pages for the display screen for the page address set command
    - rs29: 
    - rs30: Fixed at E1913 (address for coordinate input from I2C) 
        - The I2C done signal will be stored at a location 1 higher (E1914).
    - rs31: Fixed at 1D97C (address for SPI commands) 
        - The parameter count address will be stored at a location 1 higher (1D97D).
        - The parameters address will be stored at a location 2 higher (1D97E). 
*/

/*
Setup
*/

setup:
	/*Initializing fixed register values*/
	addi x22, x0, 0x2A  //column address set command 
	addi x23, x0, 0x2B  //page address set command
    addi x24, x0, 0x2C  //memory write command
    addi x25, x0, 0x01  //display screen software reset command
	lui x30, 0xE1       
	addi x30, x0, 0x913 //address for I2C data
	lui x31, 0x1D       
	addi x31, x0, 0x97C

	/*Entering main loop*/
	main_loop

/*
Commands section:
Address for display commands stored in rs31. Count stored 1 location higher, parameters stored 2 locations higher.
*/

displayscreen_no_operation:
    /*The no operation command hex value is 00*/
	sw x0, 0(x31)

	/*The number of parameters is stored in rs10*/
	addi x10, x0, 0 /*This command has 0 parameters*/
	sw x10, 1(x31)

displayscreen_software_reset:
    /*The software reset command is stored in rs25*/
	sw x25, 0(x31)

	/*The number of parameters is stored in rs10*/
	addi x10, x0, 0 /*This command has 0 parameters*/
	sw x10, 1(x31)

displayscreen_column_address_set:
    /*The column address set command is stored in rs22*/
	sw x22, 0(x31)

	/*The number of parameters is stored in rs10*/
	addi x10, x0, 4 /*This command has 4 parameters*/
	sw x10, 1(x31)

	/*Current column bounds stored in rs14*/
	sw x14, 2(x31)

displayscreen_page_address_set:
    /*The page address set command is stored in rs23*/
	sw x23, 0(x31)

	/*The number of parameters is stored in rs10*/
	addi x10, x0, 4 /*This command has 4 parameters*/
	sw x10, 1(x31)

	/*Current row bounds stored in rs15*/
	sw x15, 2(x31)

displayscreen_memory_write:
    /*The memory write command is stored in rs24*/
	sw x24, 0(x31)

	/*The number of parameters is stored in rs10*/
	addi x10, x0, 3 /*This command has 3 parameters*/
	sw x10, 1(x31)

	/*Send all 0 for color data (color fixed at black for now)*/
	sw x0, 2(x31)

/*
Pixel handling section
*/

read_touchscreen_coordinates:
	/*Address for I2C data is stored in rs30*/
	/*The actual data from I2C will be stored in rs19*/
	lw x19, 0(x30)

convert_pixel_data: /*(written in half SystemVerilog, half assembly for now)*/

    /*Collecting data from I2C*/
    touch_x_pos = I2C_reg[27:16];
    touch_y_pos = I2C_reg[11:0];

    /*Adjusting for different resolutions*/
    display_x_pos = touch_x_pos / 17;
    display_y_pos = touch_y_pos / 13;

    /*Change the color of a pixel if it is being contacted*/
    addi x3, x0,  0x80000000 /*1000...000*/
    andi x4, x19, 0xC0000000 /*1100...000. Note that this is ANDI not ADDI*/
    beq x3, x4, draw_new_pixel

check_new_pixel: /*An event has occurred as a pixel and it must be checked whether it is a contact event*/
	read_touchscreen_coordinates
	convert_pixel_data
	displayscreen_memory_write

draw_new_pixel: /*It has been confirmed that there is a contact event at a pixel*/
	/*Designating which column the pixel to change is in*/
	addi x14, x0, display_y_pos
    displayscreen_column_address_set
    /*Designating which row (page) the pixel to change is in*/
	addi x15, x0, display_x_pos
	displayscreen_page_address_set

	/*Sending the command to update the pixel*/
	displayscreen_memory_write

/*
Main loop
*/

main_loop:
	/*Done signal will go to register 20*/
    lw x20, 1(x30)
    /*Checking if the done signal is high (not equal to x0)*/
    bne x20, x0, check_new_pixel
    /*Repeat loop*/
    main_loop
