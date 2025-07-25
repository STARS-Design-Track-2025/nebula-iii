module t04_acknowledgement_center (
    // from wishbone
    input logic busy,
    input logic WEN,
    input logic Ram_En,
    input logic key_en,

    
    // from display
    input logic display_ack,

    // for register
    input logic clk,
    input logic rst,

    // output to datapath
    output logic d_ack,
    output logic i_ack
);
//i_ack SERVES AS THE DATA_STORING NOT USED IN DATAPATH
logic DATA_STORING;
logic DATA_STORING1;
logic DATA_STORING2;

always_comb begin
    i_ack = DATA_STORING;
    //if (DATA_STORING || DATA_STORING1 || (DATA_STORING2)) begin                  //AS OF NOW Ram_En is hardwired to be 1. || DATA_STORING2
    if (DATA_STORING || DATA_STORING1) begin 
        d_ack = (display_ack);
    end
    else if (Ram_En && !DATA_STORING1) begin //adrian added the !WEN
        d_ack = (~busy);
    end
    else begin
        d_ack = (key_en);
    end
end

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        DATA_STORING <= 0;
    end
    else if (WEN) begin
        DATA_STORING <= 1;
    end
    else if (display_ack) begin
        DATA_STORING <= 0;
    end
end

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        DATA_STORING1 <= 0;
        DATA_STORING2 <= 0;
    end
    else begin
        DATA_STORING1 <= DATA_STORING;
        DATA_STORING2 <= DATA_STORING1;
    end
end
endmodule