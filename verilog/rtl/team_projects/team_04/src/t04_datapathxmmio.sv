module t04_datapathxmmio(
    input  logic clk,
    input  logic rst,

    // === Keypad ===
    input  logic [4:0] button_pressed,
    input  logic [1:0] app,
    input  logic rising,

    // === Display ===
    output logic [31:0] display_address,
    output logic [31:0] mem_store_display,
    input  logic d_ack_display,
    output logic WEN
);

    // === Internal wires ===
    logic [31:0] instruction;
    logic [31:0] memload;

    logic [31:0] final_address;
    logic [31:0] mem_store;

    logic i_ack, d_ack;
    logic MemRead, MemWrite;

    // === Select memload based on address decoding ===

    // === Instantiate Datapath ===
    t04_datapath datapath (
        .clk(clk),
        .rst(rst),
        .i_ack(i_ack),
        .d_ack(d_ack),
        .instruction(instruction),
        .memload(memload),
        .final_address(final_address),
        .mem_store(mem_store),
        .MemRead_O(MemRead),
        .MemWrite_O(MemWrite)
    );

    // === Instantiate MMIO ===
    t04_mmio mmio (
        .clk(clk),
        .reset(rst), 
        .final_address(final_address),
        .mem_store(mem_store),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .i_ack(i_ack),
        .d_ack(d_ack),
        .instruction(instruction),
        .memload(memload),
        .button_pressed(button_pressed),
        .app(app),
        .rising(rising),
        .display_address(display_address),
        .mem_store_display(mem_store_display),
        .d_ack_display(d_ack_display),
        .WEN(WEN)
    );

endmodule
