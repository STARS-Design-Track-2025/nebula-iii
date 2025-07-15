module t07_fp_fcsr_tb (

logic clk, rst;
logic [2:0] frm;
logic [4:0] fflags;
logic [1:0] rwSignal;
logic [31:0] fcsr_out;

t07_fp_fcsr_tb dut {
    .clk(clk),
    .rst(rst),
    .frm(frm),
    .fflags(fflags),
    .rwSignal(rwSignal),
    .fcsr_out(fcsr_out)
};
//clock generation
always #5 clk = ~clk;

initial begin
    $dumpfile("t07_fp_fcsr.vcd");
    $dumpvars(0, t07_fp_fcsr_tb);

    // Initialize Inputs
    clk = 0;
    rst = 1; // Start with reset high
    frm = 3'b000; // Default rounding mode
    fflags = 5'b00000; // No flags set
    rwSignal = 2'b00; // Default read/write signal

    // test 1 : rst behavior
    rst = 1;
    #10;
    rst = 0;
    #10;
    assert(fcsr_out == 32'b0) else $fatal("Reset failed, fcsr_out should be zero");

    // test 2 : write operation
    rwSignal = 2'b01; // Set to write operation
    fflags = 5'b11011;
    frm = 3'b010; // Set rounding mode
    #10;
    assert(fcsr_out == {24'b0, fflags, frm}) else $fatal("Write operation failed, fcsr_out should match the written value");

    // test 3 : read operation
    rwSignal = 2'b10; // Set to read operation
    #10;
    assert(fcsr_out == {24'b0, fflags, frm}) else $fatal("Read operation failed, fcsr_out should match the current value");

    // test 4: read mode
    rwSignal = 2'b11; // Set to read mode
    #10;
    assert(fcsr_out == {24'b0, fflags, frm}) else $fatal("Read mode failed, fcsr_out should match the current value");  
    
    // test 5: new write operation
    rwSignal = 2'b01; // Set to write operation
    fflags = 5'b00010; // Change flags
    frm = 3'b010; // Set rounding mode
    #10;
    assert(fcsr_out == {24'b0, fflags, frm}) else $fatal("New write operation failed, fcsr_out should match the written value");

    display("All tests passed successfully!");
    $finish;
end
);

endmodule

