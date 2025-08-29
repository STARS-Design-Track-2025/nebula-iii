`timescale 1ns / 1ps

module t07_muxes_tb;

    // Inputs
    logic [31:0] input_a, input_b;
    logic select;

    // Outputs
    logic [31:0] output_data;

    // Instantiate the Unit Under Test (UUT)
    t07_muxes uut (
        .a(input_a),
        .b(input_b),
        .sel(select),
        .out(output_data)
    );

    
    initial begin
        $dumpfile("t07_muxes.vcd");
        $dumpvars(0, t07_muxes_tb);
        
        // Initialize Inputs
        input_a = 32'h00000001;
        input_b = 32'h00000002;
        select = '0; // Select input_a

        // Wait for global reset to finish
        #10;

        // Test case 1: Select input_a
        #10;
        if (output_data !== input_a) $display("Test case 1 failed: expected %h, got %h", input_a, output_data);

        // Test case 2: Select input_b
        select = '1; 
        #10;
        if (output_data !== input_b) $display("Test case 2 failed: expected %h, got %h", input_b, output_data);

        $finish; // End simulation
    end
endmodule