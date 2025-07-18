module t04_top(
    input  logic clk,
    input  logic rst,

    // === Keypad ===
    input  logic [3:0] row,

    // // === Display ===
    output  logic screenCsx,
    output  logic screenDcx,
    output  logic screenWrx,
    output  logic [7:0] screenData
    
);

    // === Internal wires ===
    logic [31:0] instruction;
    logic [31:0] memload;

    logic [31:0] final_address;
    logic [31:0] mem_store;

    logic i_ack, d_ack;
    logic MemRead, MemWrite;

    logic [4:0] button;
    logic [1:0] app;
    logic rising;

    logic [31:0] display_address;
    logic [31:0] mem_store_display;
    logic WEN;
    logic d_ack_display;


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
        .button_pressed(button),
        .app(app),
        .rising(rising),
        .display_address(display_address),
        .mem_store_display(mem_store_display),
        .d_ack_display(d_ack_display),
        .WEN(WEN)
    );

    // === KEYPAD INTERFACE ===

    t04_keypad_interface keypad (
    .clk(clk), .rst(rst),
    .row(row),
    .button(button),
    .app(app),
    .rising(rising)
    );

    // === DISPLAY INTERFACE ===

    t04_screen_top screen (
        .clk(clk),
        .rst(rst),
        .WEN(WEN),
        .mem_store_display(mem_store_display),
        .display_address(display_address),
        .d_ack_display(d_ack_display),
        .dcx(screenDcx),
        .csx(screenCsx),
        .wrx(screenWrx),
        .screenData(screenData)
    );

endmodule
