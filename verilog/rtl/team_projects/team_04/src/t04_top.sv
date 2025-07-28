module t04_top(
    input  logic clk,
    input  logic rst,

    // === Keypad ===
    input  logic [3:0] row,
    output logic [3:0] column, // good boy (can I have this column to be named the same as an internal signal)
    output logic [4:0] button, // this is temporary for testing

    // // === Display ===
    output  logic screenCsx,
    output  logic screenDcx,
    output  logic screenWrx,
    output  logic [7:0] screenData,
    output  logic checkX, checkY, checkC,
    output  logic [7:0] pc,
    output  logic [1:0] acks,
    output  logic clk_meas
);

    // === Internal wires ===
    logic [31:0] instruction;
    logic [31:0] memload;
  
    logic [31:0] final_address;
    logic [31:0] mem_store;

    logic i_ack, d_ack;
    logic MemRead, MemWrite;
    logic BranchConditionFlag;
    logic JAL_O;

    logic pulse_e;
    assign pc = final_address[7:0];
    //logic [4:0] button;
    logic [1:0] app;
    logic rising;

    logic [31:0] display_address;
    logic [31:0] mem_store_display;
    logic WEN;
    logic d_ack_display;
    logic [9:0] cnt, ncnt;
  assign acks = {d_ack, d_ack_display};

  always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
      cnt <= '0;
    end else begin
      cnt <= ncnt;
    end
  end

  always_comb begin
    if(cnt == 1000) begin
      ncnt = 0;
    end else begin
      ncnt = cnt + 1;
    end
  end

  assign clk_meas = (cnt == 1000) ? 1 : 0;

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
        .MemWrite_O(MemWrite),
        .BranchConditionFlag(BranchConditionFlag),
        .JAL_O(JAL_O)
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
        .BranchConditionFlag(BranchConditionFlag),
        .JAL_O(JAL_O),
        .button_pressed(button),
        .app(app),
        .rising(rising),
        .display_address(display_address),
        .mem_store_display(mem_store_display),
        .d_ack_display(d_ack_display),
        .WEN(WEN)
    );

    // === KEYPAD INTERFACE ===

    t04_counter_column columns (
        .clk(clk), .rst(rst),
        .column(column),
        .pulse_e(pulse_e)
    );

    t04_keypad_interface keypad (
    .clk(clk), .rst(rst),
    .column(column),
    .row(row),
    .pulse(pulse_e),
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
        .screenData(screenData),
        .checkC(checkC),
        .checkX(checkX),
        .checkY(checkY)
    );

endmodule
