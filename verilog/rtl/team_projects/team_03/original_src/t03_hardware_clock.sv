`default_nettype none
`timescale 1ps/1ps
module t03_hardware_clock(
    input logic clk, rst,
    output logic [31:0] new_counter
);

logic [31:0] count, n_count, n_new_counter;

always_ff @( posedge clk, posedge rst) begin
    if (rst) begin
        count <= 0;
        new_counter <= 0;
    end else begin
        count <= n_count;
        new_counter <= n_new_counter;
    end
end

always_comb begin 
    n_count = count;
    n_new_counter = new_counter;
    if (count == 10000) begin //when testbenching change the value from 40000 to something small like 4 so we can see the waves
        n_new_counter = new_counter + 1;
        n_count = 0;
    end
    else begin
        n_count = count + 1;
    end
end

endmodule