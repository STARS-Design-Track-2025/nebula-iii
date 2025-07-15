module t07_SPI_ESP32 (
    input logic ESP_in, SCLK_in, clk, rst,
    output logic SCLK_out,
    output logic [31:0] dataForCPU
);
    logic [31:0] MOSI_shiftReg;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            MOSI_shiftReg <= '0;
        end
        else if(SCLK_in == 1) begin //check that this only happens on rising edge of SCLK
            MOSI_shiftReg <= {MOSI_shiftReg[30:0], ESP_in};
        end
        else begin
            MOSI_shiftReg <= MOSI_shiftReg;
        end
    end
    
endmodule