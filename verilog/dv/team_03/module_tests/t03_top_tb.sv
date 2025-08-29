`timescale 1ns/10ps

module top_tb;
    logic reset;
    logic [20:0] pb;
    logic clk;
    integer clkCounter;
    logic [7:0] left, right, ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0;
    logic red, green, blue;

  // UART ports
    logic [7:0] txdata;
    logic txclk, rxclk;
    

    parameter CLKPERIOD = 100;

    always begin
        #(CLKPERIOD/2) clk = 1'b1;
        #(CLKPERIOD/2) clk = 1'b0;
    end

    top DUT(.hz100(clk), .reset(reset), .pb(pb), .rxdata(8'b0), .txready(1'b0), .rxready(1'b0),
    .left(left), .right(right), .ss7(ss7), .ss6(ss6), .ss5(ss5), .ss4(ss4), .ss3(ss3), .ss2(ss2), .ss1(ss1), .ss0(ss0),
    .red(red), .green(green), .blue(blue),
    .txdata(txdata), .txclk(txclk), .rxclk(rxclk));

  
    
    initial begin
        pb[4] =1;
    clk = 0;
    // make sure to dump the signals so we can see them in the waveform
    $dumpfile("waves/top.vcd");
    $dumpvars(0, top_tb);

    initialize();

    reset = 1'b1;

    @ (posedge clk);
    @ (negedge clk);

    reset = 1'b0;

    repeat(10) @ (posedge clk);
    @ (negedge clk);

    pb = 21'b0_0000_0000_0000_1000_0000;

    
    repeat(40) begin
        repeat(3000) begin 
            @ (posedge clk);
        end

            // $display("instruction=%h", DUT.CPU.instruction);
            // $display("register 1=%d", DUT.CPU.registerFile.regfile[1]);

        repeat(3000) begin 
            @ (posedge clk);
        end
    end
    @ (negedge clk);


    // repeat(1000) begin
    //     @ (posedge clk);
    //     clkCounter++;
    //     $display("instruction=%h", DUT.CPU.instruction);
    //     $display("register 10=%d", DUT.CPU.registerFile.regfile[10]);

    //     $display("register 1=%d", DUT.CPU.registerFile.regfile[1]);
    //     $display("register 6=%d", DUT.CPU.registerFile.regfile[6]);
    //     $display("register 10=%d", DUT.CPU.registerFile.regfile[10]);
        
    //     $display("y2=%b", DUT.MMIOInterface.y2);
    //     $display("y1=%b", DUT.MMIOInterface.y1);
    //     $display("x2=%b", DUT.MMIOInterface.x2);
    //     $display("x1=%b", DUT.MMIOInterface.x1);
    //     $display("gameState=%b", DUT.MMIOInterface.gameState);
    //     $display("p1State=%b", DUT.MMIOInterface.p1State);
    //     $display("p2State=%b", DUT.MMIOInterface.p2State);
    //     $display("p1health=%b", DUT.MMIOInterface.p1health);
    //     $display("p2health=%b", DUT.MMIOInterface.p2health);
    // end

    // finish the simulation
    #1 $finish;
    end

    task initialize ();
        begin
            clk = 1'b0;
            reset = 1'b0;
            pb = 21'b0;
            clkCounter = 0;
        end
    endtask
endmodule
