module t04_mmio (
    input logic clk,
    input logic reset,
    //CPU
    input logic [31:0] final_address,
    input logic [31:0] mem_store,
    output logic i_ack,
    output logic d_ack,
    output logic [31:0] instruction,
    output logic [31:0] memload,
    //RAM
    output logic [31:0] RAM_address,
    output logic [31:0] mem_store_RAM,
    input logic [31:0] data_or_instruction,
    input logic busy,
    //Keypad
    input logic [4:0] button_pressed,
    input logic [1:0] app,
    input logic rising,
    //Display
    output logic [31:0] display_address,
    output logic [31:0] mem_store_display,
    input logic d_ack_display,
    output logic WEN
);







t04_wishbone_manager wishbone(.CLK(clk),.nRST(reset),.DAT_I(),.ACK_I(),.CPU_DAT_I());




endmodule