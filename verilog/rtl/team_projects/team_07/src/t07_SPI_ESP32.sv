module t07_SPI_ESP32 (
    input logic [7:0] ESP_in, 
    input logic SCLK_in, clk, nrst,
    output logic [31:0] SPI_Address, // Address for the external register],
    output logic [31:0] dataForExtReg, // Data to write to the external register

);
    logic [31:0] n_address;
    logic [31:0] MOSI_shiftReg;
    logic [31:0] n_MOSI_shiftReg; // Next value for the MOSI shift register
    logic [31:0] f_MOSI_shiftReg; // Final value for the MOSI shift register after 4 bits


    logic [3:0] bit_count;
    logic [3:0] n_bit_count; // Next value for the bit count

    always_ff @(posedge SCLK_in, negedge nrst) begin
        if (!nrst) begin
            MOSI_shiftReg <= '0;
            bit_count <= 0;
        end else begin      
            MOSI_shiftReg <= n_MOSI_shiftReg; // Shift in the incoming data
            bit_count <= n_bit_count;
            if (bit_count == 4) begin
                SPI_Address <= n_address; // Update the address after 4 bits
                MOSI_shiftReg <= n_MOSI_shiftReg; // Update the MOSI shift register
                dataForExtReg <= f_MOSI_shiftReg; // Update the data for the external register
            end else begin
                //????????????????????
            end
        end 
    end
      
always_comb begin
    if (bit_count < 4) begin
        n_MOSI_shiftReg = {MOSI_shiftReg[23:0], ESP_in}; // Shift in the incoming data
        n_bit_count = bit_count + 1; // Increment the bit count
    end else if(bit_count == 4) begin
        f_MOSI_shiftReg = MOSI_shiftReg; // Keep the shift register unchanged
        n_MOSI_shiftReg = {MOSI_shiftReg[23:0], ESP_in}; // Shift in the incoming data
        n_bit_count = '1; // Keep the bit count unchanged
    end
    
end
    
endmodule