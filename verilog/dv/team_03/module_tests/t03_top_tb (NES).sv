`timescale 1ms/10ps

module top_tb ();

logic clk, rst;
logic [20:0] pb;
// logic player_state;

top tester (.hz100(clk), .reset(rst), .pb(pb));

    always begin
        #1
        clk = ~clk;
    end

    initial begin
        $dumpfile("waves/top.vcd");
        $dumpvars(0, top_tb);

        pb = 21'b0;
        clk = 0;
        rst = 1;
        
        @(posedge clk);
        @(posedge clk);

        rst = 0;
        pb = '0;

        @(posedge clk);
        @(posedge clk);

        pb = 21'b000000000000010000000;
        // pb = 21'd128;

        repeat(5000) @(posedge clk);
        @(posedge clk);

        pb = '0;

        @(posedge clk);
        @(posedge clk);

        pb = 21'b000000000000001000000;
        // pb = 21'd64;

        @(posedge clk);
        @(posedge clk);

        pb = '0;

        #2
        $finish;
    end

endmodule