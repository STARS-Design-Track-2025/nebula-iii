module t07_fp_fcsr_tb;

    logic clk;
    logic nrst;
    logic [2:0] frm; // Floating-point rounding mode
    logic [4:0] fflags; // Floating-point flags
    logic [1:0] rwSignal; // Read/Write signal
    logic [31:0] fcsr_out; // Output FCSR value

    // Instantiate the Unit Under Test (UUT)
    t07_fp_fcsr uut (
        .clk(clk),
        .nrst(nrst),
        .frm(frm),
        .fflags(fflags),
        .rwSignal(rwSignal),
        .fcsr_out(fcsr_out)
    );

//clock generation
    always begin
        clk = 0;
        #5; // Wait for 5 time units
        clk = 1;
        #5; // Wait for 5 time units
    end

initial begin
    $dumpfile("t07_fp_fcsr.vcd");
    $dumpvars(0, t07_fp_fcsr_tb);

    // Initialize Inputs
    clk = 0;
    nrst = 1; // Start with reset high
    frm = 3'b000; // Default rounding mode
    fflags = 5'b00000; // No flags set
    rwSignal = 2'b00; // Default read/write signal

    // test 1 : rst behavior
    nrst = 1'b1;
    #10;
    nrst = 1'b0;
    #10;
    

    // test 2 : write operation
    rwSignal = 2'b01; // Set to write operation
    fflags = 5'b11011;
    frm = 3'b010; // Set rounding mode
    #10;
    

    // test 3 : read operation
    rwSignal = 2'b10; // Set to read operation
    frm = 3'b000;
    fflags = 5'b00000;
    #10;
    

    // test 4: idle state
    rwSignal = 2'b00; // Idle state
    frm = 3'b111;
    fflags = 5'b00000;
    #10;

    
    // test 5: new write operation
    rwSignal = 2'b01; // Set to write operation
    fflags = 5'b00010; // Change flags
    frm = 3'b010; // Set rounding mode
    #10;

    //testing flags

    fflags = 5'b00000; //clear flags


    $display("All tests passed successfully!");
    $finish;
end
endmodule

