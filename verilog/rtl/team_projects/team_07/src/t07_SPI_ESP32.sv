`timescale 1ns/1ps

module t07_SPI_ESP32 (
    input  logic [3:0] ESP_in,
    input  logic       clk,
    input  logic       nrst,
    input  logic       ChipSelectIn,

    output logic [4:0] SPI_Address,      // Address for the external register
    output logic [31:0] dataForExtReg,   // Data to write to the external register
    output logic       ChipSelectOut,
    output logic       SCLK_out          // Clock signal for the ESP32
);

    logic [4:0]    n_address;
    logic [31:0]   MOSI_shiftReg;
    logic [31:0]   n_MOSI_shiftReg;
    logic [31:0]   f_MOSI_shiftReg;

    logic [3:0]    bit_count;
    logic [3:0]    n_bit_count;
    logic [4:0]    address;

    assign SCLK_out = clk; // Pass through the clock directly
    assign ChipSelectOut = ChipSelectIn;

    always_ff @(negedge nrst or posedge clk) begin
        if (!nrst) begin
            MOSI_shiftReg   <= 32'd0;
            bit_count       <= 4'd0;
            dataForExtReg   <= 32'd0;
            address         <= 5'd0;
        end else begin
            MOSI_shiftReg   <= n_MOSI_shiftReg;
            bit_count       <= n_bit_count;
            dataForExtReg   <= f_MOSI_shiftReg;
            address         <= n_address;
        end
    end

    always_comb begin
        // Default values
        n_MOSI_shiftReg = MOSI_shiftReg;
        n_bit_count     = bit_count;
        n_address       = address;
        f_MOSI_shiftReg = 32'd0;
        SPI_Address     = 5'd0;

        if (ChipSelectIn == 1) begin
            n_bit_count     = 4'd0;
            n_address       = 5'd0;
            n_MOSI_shiftReg = 32'd0;
            f_MOSI_shiftReg = 32'd0;
            SPI_Address     = 5'd0;

        end else if (bit_count == 0) begin
            n_MOSI_shiftReg = {MOSI_shiftReg[27:0], ESP_in};
            n_bit_count     = 4'd1;
            // No address update yet

        end else if (bit_count < 8) begin
            n_MOSI_shiftReg = {MOSI_shiftReg[27:0], ESP_in};
            n_bit_count     = bit_count + 4'd1;

        end else begin // bit_count == 8
            n_MOSI_shiftReg = {MOSI_shiftReg[27:0], ESP_in};
            n_bit_count     = 4'd1;

            if (address < 5'd31) begin
                n_address = address + 5'd1;
            end else begin
                n_address = 5'd1;
            end
        end

        // Determine output signals based on bit count
        if (bit_count == 8) begin
            SPI_Address     = address;
            f_MOSI_shiftReg = MOSI_shiftReg;
        end else if (bit_count == 1) begin
            SPI_Address     = address;
            f_MOSI_shiftReg = 32'd0;
        end
    end

endmodule
