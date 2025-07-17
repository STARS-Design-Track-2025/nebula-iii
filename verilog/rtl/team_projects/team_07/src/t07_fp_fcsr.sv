// fp control & status register
/* 

This module implements the FP Control and Status Register (FPSCR) for Team 07.
- It handles the control and status bits for floating point operations.
- The FPSCR is used to manage the state of the floating point unit (FPU).
- It includes bits for rounding mode, exception flags, and other control signals.
- The module supports read and write operations based on control signals.

- The FPSCR is essential for managing floating point operations and ensuring correct behavior of the FPU.
*/
module t07_fp_fcsr (
    input logic clk,
    input logic rst,
    input logic [2:0] frm, // write = 00 read = 01 idle = 10 || rounding mode
    input logic [4:0] fflags, // floating point exception flags
    input logic [1:0] rwSignal, // read/write signal

    output logic [31:0] fcsr_out // output FPSCR value
);

logic [31:0] fcsr; // internal fpscr register

always_ff @(posedge clk or negedge ~rst) begin
    if (rst) begin
        fcsr <= 32'b0; // reset fpscr to zero
    end else begin
        case (rwSignal)
            2'b01: fcsr <= {24'b0, fflags, frm}; // write operation
            2'b10: fcsr <= fcsr; // read operation, keep current value
            default: fcsr <= fcsr; // idle state, keep current value
        endcase
    end
end

always_comb begin
    fcsr_out = fcsr; // output the current FPSCR value
end


endmodule
