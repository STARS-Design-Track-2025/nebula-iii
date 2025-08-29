`default_nettype none
`timescale 1ps/1ps

module t03_eight_bit_shift(
    input logic clk, rst, button_en, data, finished,//data is the serial input from the controller
    output logic [7:0] latchedValue
);

logic [7:0] n_parallelOut;
logic [7:0] parallelOut;
logic [7:0] n_latchedValue;

always_ff @( posedge clk, posedge rst ) begin 
    if (rst) begin
        parallelOut <= '1;
    end else if (button_en) begin
        parallelOut <= {parallelOut[6:0], data};
    end
end

always_ff @( posedge clk, posedge rst ) begin 
    if (rst) begin
        latchedValue <= '1;
    end else if (finished) begin //finished signal might be going high one cycle too late, check NES_clkdiv_counter  and waves
        latchedValue <= parallelOut;
    end
end

endmodule

// mo3dul3 eight_bit_shift(
//     input logic clk, rst, button_en, data, //data is the serial input from the controller
//     output logic [7:0] parallelOut_latched
// );

// logic [6:0] parallelOut, n_parallelOut;
// logic [3:0] count, n_count;
// logic [7:0] n_parallelOut_latched;

// always_ff @( posedge clk, posedge rst ) begin 
//     if (rst) begin
//         count <= 0;
//         parallelOut <= '0;
//         parallelOut_latched <= '0;
//     end else if (button_en) begin
//         count <= n_count;
//         parallelOut <= n_parallelOut;
//         parallelOut_latched <= n_parallelOut_latched;
//     end
// end

// always_comb begin
//     n_count = count;
//     n_parallelOut = parallelOut;
//     n_parallelOut_latched = parallelOut_latched;
//     if (count < 7) begin
//         n_count <= count + 1;
//         n_parallelOut <= {parallelOut[5:0], data};
//     end else begin
//         n_parallelOut_latched <= {parallelOut, data};
//         n_parallelOut <= {parallelOut[5:0], data};
//         n_count <= 0;
//     end
// end

// endmodule

