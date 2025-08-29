`default_nettype none
`timescale 1ps/1ps
module t03_hardwareclkxmmio(
    input logic clk, rst,
    input logic [31:0] new_counter,
    output logic [31:0] data_to_CPU,
    output logic ack
);

    logic [31:0] n_data_to_CPU;
    assign ack = 1'b1;

    always_ff @( posedge clk, posedge rst ) begin
        if (rst) begin
            data_to_CPU <= '0;
        end else begin
            data_to_CPU <= n_data_to_CPU;
        end
    end

    always_comb begin 
        n_data_to_CPU = new_counter;
    end

endmodule