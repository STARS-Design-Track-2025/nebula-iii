`default_nettype none

// team 07 registers file
/* internal registers
purpose: implements register file for cpu
contains 32 registers each 32 bit wide

- read registers: read_reg1, read_reg2 <- these are the registers to read from
- write register: write_reg <- this is the register to write to
- write data: write_data <- this is the address to write to
- reg_write_enable: reg_write_enable <- this is the signal to enable writing to the register

*/

module t07_registers (
    input logic clk,
    input logic rst,
    input logic [4:0] read_reg1, // from decoder
    input logic [4:0] read_reg2, // from decoder
    input logic [4:0] write_reg, // from decoder
    input logic [31:0] write_data, // from memory handler
    input logic reg_write, // from control unit
    input logic enable, // from control unit

    output logic [31:0] read_data1, read_data2

);

    // Register file: 32 registers, each 32 bits wide
    logic [31:0] registers [31:0];

    // read logic
    always_comb begin
        read_data1 = registers[read_reg1];
        read_data2 = registers[read_reg2];
    end 
    
    // write logic
    always_ff @(posedge clk or rst) begin
        if (rst) begin
            // Reset all registers to zero
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'b0;
            end
        end else if (enable) begin
            if (reg_write && write_reg != 5'b0) begin
                registers[write_reg] <= write_data;
            end
        end
    end

endmodule

