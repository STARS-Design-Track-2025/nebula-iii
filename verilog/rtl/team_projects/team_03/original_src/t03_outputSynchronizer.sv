`default_nettype none
`timescale 1ps/1ps

//We want an edge detector for A and B here, so when those are pressed, they are only asserted for a couple of cycles until they are pressed again

module t03_outputSynchronizer(
    input logic clk, rst,
    input logic [15:0] controllerInputs,
    output logic [15:0] syncronizedOut, //happens after 2 flip flops
    output logic buttonAPressP1,
    output logic buttonBPressP1,
    output logic buttonAPressP2,
    output logic buttonBPressP2
);

logic [15:0] registeredOut; //happens after 1 flip flop
logic n_buttonAPressP1;
logic n_buttonBPressP1;
logic n_buttonAPressP2;
logic n_buttonBPressP2;


always_ff @( posedge clk, posedge rst ) begin
    if (rst) begin 
        registeredOut <= 0;
        syncronizedOut <= 16'b0;
        buttonAPressP1 <= 1'b0;
        buttonBPressP1 <= 1'b0;
        buttonAPressP2 <= 1'b0;
        buttonBPressP2 <= 1'b0;
    end else begin
        syncronizedOut <= registeredOut;
        registeredOut <= controllerInputs;
        buttonAPressP1 <= n_buttonAPressP1;
        buttonBPressP1 <= n_buttonBPressP1;
        buttonAPressP2 <= n_buttonAPressP2;
        buttonBPressP2 <= n_buttonBPressP2;
    end
end

always_comb begin
    n_buttonAPressP1 = syncronizedOut[15] & !registeredOut[15];
    n_buttonBPressP1 = syncronizedOut[14] & !registeredOut[14];

    n_buttonAPressP2 = syncronizedOut[7] & !registeredOut[7];
    n_buttonBPressP2 = syncronizedOut[6] & !registeredOut[6];
end

endmodule
