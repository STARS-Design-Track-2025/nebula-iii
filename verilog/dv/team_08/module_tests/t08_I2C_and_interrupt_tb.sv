`timescale 1ns/10ps

module t08_I2C_and_interrupt_tb;

    logic clk = 0;
    always #42 clk = ~clk;
    logic nRst, sda_out, sda_in, scl_out, scl_in, inter, done;
    logic [31:0] data_out;

    logic sda_line, scl_line;
    assign sda_line = sda_out && sda_in;
    assign scl_line = scl_out && scl_in;

    t08_I2C_and_interrupt I2C(
        .clk(clk), .nRst(nRst), 
        .sda_in(sda_in), .sda_out(sda_out), .sda_oeb(), 
        .inter(inter), .scl_in(scl_in), .scl_out(scl_out), 
        .data_out(data_out), .done(done)
    );

    initial begin

        $dumpfile("t08_I2C_and_interrupt.vcd");
        $dumpvars(0, t08_I2C_and_interrupt_tb);

        sda_in = 1;
        scl_in = 1;

        inter = 1;

        nRst = 0; @ (negedge clk); nRst = 1;

        inter = 0; @ (negedge clk); inter = 1;

        //#22721
        //#55229
        //#55230
        //#60000

        #200000

        scl_in = 0;

        #200000

        scl_in = 1;

        #10600000

        $finish;

    end

endmodule