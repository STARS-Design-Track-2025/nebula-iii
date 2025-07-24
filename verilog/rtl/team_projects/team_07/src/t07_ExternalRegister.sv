//External Register Module
// This module is used to interface with the external registers, allowing for read and write operations.
module t07_ExternalRegister (
    input logic clk,
    input logic nrst,
    input logic [4:0] ReadRegister, // Address of the register to read/write from the memory handler
    input logic [4:0] SPIAddress, // Address for the SPI ESP32
    input logic [31:0] write_data, // Data to write to the register from SPI
    input logic ri, // Enable reading or idle to the register
    output logic [31:0] read_data, // Data read from the register
    output logic ack_REG // acknowledge signal to the memory handler

);
    logic [31:0] registers [31:0]; // 32 registers, each 32 bits wide
    logic next_ack_REG;  // Next acknowledge signal to the memory handler
    logic [31:0] next_read_data; // Next write data to the register
    
    logic pre_ri, ri_edge;
    always_ff @(negedge nrst, posedge clk) begin
        if (!nrst) begin 
            pre_ri <= '0;
        end else begin
            pre_ri <= ri;
        end
    end

    assign ri_edge = (!ri && pre_ri);

    always_comb begin
        ack_REG = 1'b0; // Default to not acknowledge
        next_read_data = registers[ReadRegister]; // Default read data from the register
        if (ri_edge) begin // If read or idle signal is high 
            ack_REG = 1'b1; // Acknowledge the read operation
        end
    end

    // Write logic
    always_ff @(negedge nrst, posedge clk) begin
        if (!nrst) begin
            //ack_REG <= 1'b0; // Reset acknowledge signal
            read_data <= 32'b0; // Reset read data
            // Reset all registers to zero
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'b0;
            end
        end else begin
            registers[SPIAddress] <= write_data; // Write data to the register
            //ack_REG <= next_ack_REG; // Acknowledge signal to the memory handler
            read_data <= next_read_data; // Update write data
        end
    end

endmodule