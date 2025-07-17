module t04_acknowledgement_center (
    // from wishbone
    input logic busy,
    input logic WEN,
    input logic Ram_En,
    input logic key_en,

    
    // from display
    input logic display_ack,

    // from datapath
    input logic MemRead,
    input logic MemWrite,

    // output to datapath
    output logic d_ack,
    output logic i_ack
);
always_comb begin
    if (Ram_En) begin //AS OF NOW Ram_En is hardwired to be 1
        d_ack = (~busy);
    end
    else if (WEN) begin
        d_ack = (display_ack);
    end
    else begin
        d_ack = (key_en);
    end
    i_ack = 0;
end

endmodule