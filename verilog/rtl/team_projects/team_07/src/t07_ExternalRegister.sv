//External Register Module
// This module is used to interface with the external registers, allowing for read and write operations.
module t07_ExternalRegister (
    input logic clk,
    input logic rst,
    input logic [31:0] ReadRegister, // Address of the register to read/write from the memory handler
    input logic [31:0] write_data, // Data to write to the register from SPI
    input logic [1:0] rwi, // Enable writing,reading, or idle to the register
    output logic [31:0] read_data // Data read from the register
);
    logic [31:0] registers [31:0]; // 32 registers, each 32 bits wide

    // Read logic
    always_comb begin
        read_data = (rwi == 2'b10) ? registers[ReadRegister] : 32'b0; // Read data if rwi is read
    end

    // Write logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all registers to zero
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'b0;
            end
        end else if (rwi == 2'b01 && ReadRegister != '0) begin
            // Write data to the register if rwi is write and ReadRegister is not zero
            registers[ReadRegister] <= write_data;
        end
    end

endmodule