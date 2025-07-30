`timescale 1ms/10ps

//WHAT I WAS DOING: Debugging testbench for I2C_2

module t08_I2C_2_tb;

    logic clk = 0;
    always #5 clk = ~clk;
    logic nRst, sda_out, inter, scl, done;
    logic [31:0] data_out;

    t08_I2C_2 I2C_2(
        .clk(clk), .nRst(nRst), 
        .sda_in(1'b1), .sda_out(sda_out), .sda_oeb(), 
        .inter(inter), .scl(scl), 
        .data_out(data_out), .done(done)
    );

    initial begin

        $dumpfile("t08_I2C_2.vcd");
        $dumpvars(0, t08_I2C_2_tb);

        inter = 1;

        nRst = 0; #1; nRst = 1;

        #1; inter = 0; #1 inter = 1;

        #1000; $finish;

    end

endmodule