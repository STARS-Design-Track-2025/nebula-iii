module acknowledgement_center (
    // from wishbone
    input logic busy,
    
    // from display
    input logic display_ack,

    // from keypad
    input logic keypad_ack,

    // from datapath
    input logic MemRead,
    input logic MemWrite,

    // output to datapath
    output logic d_ack,
    output logic i_ack
);

    assign d_ack = ~busy && (MemRead || MemWrite) && (display_ack | keypad_ack);
    assign i_ack = 1'b0;


endmodule