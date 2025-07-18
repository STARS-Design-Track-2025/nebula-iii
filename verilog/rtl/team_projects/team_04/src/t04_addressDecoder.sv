module t04_addressDecoder (
    input  logic [31:0] address_in,
    input  logic MemRead,
    input  logic MemWrite,
    output logic Ram_En,
    output logic key_en,
    output logic WEN  // Write Enable for display or other MMIO
);

    // Address map (can customize)
    localparam logic [31:0] DISPLAY_ADDR1   = 32'h0000_0004; //control
    localparam logic [31:0] DISPLAY_ADDR2  = 32'h0000_0008; //x
    localparam logic [31:0] DISPLAY_ADDR3  = 32'h4000_000C; //y
    localparam logic [31:0] KEYPAD_ADDR   = 32'h0000_0010;

    always_comb begin
        Ram_En = 1;
        key_en = 0;
        WEN    = 0;

        if (address_in == DISPLAY_ADDR1 || address_in == DISPLAY_ADDR2 || address_in == DISPLAY_ADDR3) begin
            WEN = 1;
        end
        else if (address_in == KEYPAD_ADDR) begin
            key_en = 1;
        end
        // else begin  //(if (address_in >= 32'h33000000 && address_in <= 32'h33001000))
        //     Ram_En = 1;
        // end
    end

endmodule
