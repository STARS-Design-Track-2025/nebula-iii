`default_nettype none
`timescale 1ps/1ps

module t03_vertical_counter
(
    input logic rst,
    input logic clk,
    output logic [10:0] Vcnt, 
    input tc
);
    logic [10:0] vcnt_max; 
    logic [10:0] next_Vcnt;
    assign vcnt_max = 11'd666; 
    logic [2:0] count;
    logic [2:0] next_count; 

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
           Vcnt <= 0;
           count <= 0;

        end
        else begin
            Vcnt <= next_Vcnt;
            count <= next_count;
        end
    end

    
    always_comb begin
        next_Vcnt = Vcnt;
        if(Vcnt <= vcnt_max && tc) begin
            next_Vcnt = Vcnt + 1;
        end
        else if(Vcnt > vcnt_max) begin
            next_Vcnt = 0;
        end
    end



endmodule