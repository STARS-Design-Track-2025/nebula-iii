`timescale 1ns/10ps

module t08_I2C_3_tb;

    logic clk = 0;
    always #42 clk = ~clk;
    logic nRst, sda_out, scl_out, inter, done;
    logic [31:0] data_out;

    t08_I2C_3 I2C(
        .clk(clk), .nRst(nRst), 
        .sda_in(1'b1), .sda_out(sda_out), .sda_oeb(), 
        .inter(inter), .scl_in(1'b1), .scl_out(scl_out), 
        .data_out(data_out), .done(done)
    );

    initial begin

        $dumpfile("t08_I2C_3.vcd");
        $dumpvars(0, t08_I2C_3_tb);

        inter = 1;

        nRst = 0; @ (negedge clk); nRst = 1;

        inter = 0; @ (negedge clk); inter = 1;

        //#22721
        //#55229
        //#55230
        //#60000
        #1000000

        $finish;

    end

endmodule