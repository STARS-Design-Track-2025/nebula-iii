module t04_mmio (
    input logic clk,
    input logic reset,

    // === CPU ===
    input logic [31:0] final_address,
    input logic [31:0] mem_store,
    input logic MemRead,
    input logic MemWrite,
    output logic i_ack,
    output logic d_ack,
    output logic [31:0] instruction,
    output logic [31:0] memload,

    // === Keypad ===
    input logic [4:0] button_pressed,
    input logic [1:0] app,
    input logic rising,

    // === Display ===
    output logic [31:0] display_address,
    output logic [31:0] mem_store_display,
    input logic d_ack_display,
    output logic WEN
);

    // === Internal Signals ===
    logic [31:0] memload_or_instruction;
    logic busy;
    logic RAM_en, key_en;
    logic [31:0] key_data;

    // === Wishbone Manager ===
    t04_wishbone_manager wishbone (
        .CLK(clk),
        .nRST(~reset),

        // Wishbone bus input from RAM
        .DAT_I(),   // data from RAM
        .ACK_I(),                    // done signal (inverted busy)

        // CPU-side input
        .CPU_DAT_I(mem_store),
        .ADR_I(final_address),
        .SEL_I(4'd15),                  // full word access
        .WRITE_I(MemWrite && RAM_en),
        .READ_I(MemRead && RAM_en),

        // Unconnected Wishbone bus outputs (to be wired in full system)
        .ADR_O(), .DAT_O(), .SEL_O(),
        .WE_O(), .STB_O(), .CYC_O(),

        // CPU-side output
        .CPU_DAT_O(memload_or_instruction),
        .BUSY_O(busy)
    );

    // === Address Decoder ===
    t04_addressDecoder addrDecode (
        .address_in(final_address),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Ram_En(RAM_en),
        .key_en(key_en),
        .WEN(WEN)
    );

    // === Keypad Register ===
    t04_keypad_register keyreg (
        .clk(clk),
        .reset(reset),
        .button_pressed(button_pressed),
        .app(app),
        .rising(rising),
        .key_en(key_en),
        .data_out(key_data)
    );

    // === Acknowledgment Center ===
    t04_acknowledgement_center ack_center (      
        .display_ack(d_ack_display),
        .busy(busy),
        .WEN(WEN),
        .Ram_En(Ram_En),
        .key_en(key_en),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .d_ack(d_ack),
        .i_ack(i_ack)
    );

    // === Mux for memload / instruction ===
    always_comb begin
        if (RAM_en)
            memload = memload_or_instruction;
        else if (key_en)
            memload = key_data;
        else
            memload = 32'hDEADBEEF;  // default or error value
    end

    assign instruction = memload;  // simple connection unless you separate fetch/load later
    assign display_address = final_address;
    assign mem_store_display = mem_store;
    

endmodule
