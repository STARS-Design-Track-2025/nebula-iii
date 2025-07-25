//External Register Module
// This module is used to interface with the external registers, allowing for read and write operations.

`timescale 1ns/1ps

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
    //logic next_ack_REG;  // Next acknowledge signal to the memory handler
    logic [31:0] next_read_data; // Next write data to the register
    
    // edge detector
    logic ri_first, ri_f_n, ri_second, ri_s_n;
    always_ff @(negedge nrst, posedge clk) begin
        if (!nrst) begin 
            ri_first <= 0;
            ri_second <= 0;
        end else begin
            ri_first <= ri_f_n;
            ri_second <= ri_s_n;
        end
    end

    always_comb begin
        ri_f_n = ri;
        ri_s_n = ri_first;
    end

    assign ack_REG = (ri_first && !ri_second);

    always_comb begin
        next_read_data = registers[ReadRegister]; // Default read data from the register
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