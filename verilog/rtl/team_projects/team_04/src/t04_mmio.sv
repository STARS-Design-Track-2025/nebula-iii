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
    input logic BranchConditionFlag,
    input logic JAL_O,

    // === Keypad ===
    input logic [4:0] button_pressed,
    input logic [1:0] app,
    input logic rising,

    // === Display ===
    output logic [31:0] display_address,
    output logic [31:0] mem_store_display,
    input logic d_ack_display,
    output logic WEN,

    // === Wishbone Interface ===

    // These signals are coming from the Wishbone bus.
    input logic stb,
    input logic cyc,
    input logic we,
    input logic [3:0] sel,
    input logic [31:0] adr,
    input logic [31:0] dat_i,
    output logic ack,
    output logic [31:0] dat_o
);

    // === Internal Signals ===
    logic [31:0] memload_or_instruction;
    logic busy;
    logic RAM_en, key_en, key_en1, key_en2, key_en3;
    logic [31:0] key_data;
    logic MemRead_Wishbone;
    logic WEN1;
    logic WEN2;


    // === Wishbone Manager ===
    wishbone_manager wishbone (
        .CLK(clk),
        .nRST(~reset),

        // Wishbone bus input from RAM
        .DAT_I(dat_i),   // data from RAM
        .ACK_I(ack),                    // done signal (inverted busy)

        // CPU-side input
        .CPU_DAT_I(mem_store),
        .ADR_I(final_address),
        .SEL_I(4'd15),                  // full word access
        .WRITE_I(RAM_en && MemWrite1 && !read_I),
        .READ_I(((RAM_en && MemRead_Wishbone) || WEN2) || i_ack || WEN),

        // Unconnected Wishbone bus outputs (to be wired in full system)
        .ADR_O(adr), .DAT_O(dat_o), .SEL_O(sel),
        .WE_O(we), .STB_O(stb), .CYC_O(cyc),

        // CPU-side output
        .CPU_DAT_O(memload_or_instruction),
        .BUSY_O(busy)
    );
    logic MemWrite1;
    logic read_I;
    assign read_I = (((RAM_en && MemRead_Wishbone) || WEN2) || i_ack || WEN);
    // assign write_I = RAM_en && MemWrite && !WEN2;
    // assign read_I = (RAM_en && MemRead_Wishbone) || WEN2;

    
    //FOR TEST BENCHING
    // sram_WB_Wrapper sram (
    // .wb_clk_i(clk),
    // .wb_rst_i(reset),
    // .wbs_stb_i(stb),
    // .wbs_cyc_i(cyc),
    // .wbs_we_i(we),
    // .wbs_sel_i(sel),
    // .wbs_dat_i(dat_o),
    // .wbs_adr_i(adr),
    // .wbs_ack_o(ack),
    // .wbs_dat_o(dat_i)
    // );


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
        .BranchConditionFlag(BranchConditionFlag),
        .JAL_O(JAL_O),
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
        .Ram_En(RAM_en),
        .key_en(key_en),
        .clk(clk),
        .rst(reset),
        .d_ack(d_ack),
        .i_ack(i_ack)
    );

    // === Mux for memload / instruction ===
    always_comb begin
        if (key_en2 || key_en3)
            memload = key_data;
        else if (RAM_en)
            memload = memload_or_instruction;
        else
            memload = 32'hDEADBEEF;  // default or error value
    end
    
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            key_en1 <= 0;
            key_en2 <= 0;
            key_en3 <= 0;
            WEN1 <= 0;
            WEN2 <= 0;
            MemWrite1 <= 0;
        end
        else begin
            key_en1 <= key_en;
            key_en2 <= key_en1;
            key_en3 <= key_en2;
            WEN1 <= WEN;
            WEN2 <= WEN1;
            MemWrite1 <= MemWrite;
        end
    end

    assign instruction = memload;  // simple connection unless you separate fetch/load later
    assign display_address = final_address;
    assign mem_store_display = mem_store;
    always_comb begin
        MemRead_Wishbone = !(MemWrite);
    end
    

endmodule
