`timescale 1ms/10ps

module team_08_display_top_tb;

    logic clk = 0;
    logic rst, red, blue, green;
    logic [20:0] pb;
    logic [7:0] left, right, ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0, data;

    always begin
        clk = 0;
        #1;
        clk = 1;
        #1;
    end

    assign {right[5],ss4[4],right[0], ss1[5], ss1[4], right[4], ss4[5] , ss4[1]} = data;

    team_08_display_top display_top(.hwclk(clk), .reset(rst), .pb(pb), .left(left), .right(right), .
    ss7(ss7), .ss6(ss6), .ss5(ss5), .ss4(ss5), .ss3(ss3), .ss2(ss2), .ss1(ss1), .ss0(ss0));

    initial begin

        $dumpfile("team_08_display_top.vcd");
        $dumpvars(0, team_08_display_top_tb);

        rst = 0;
        #(0.1);

        rst = 1; #4;
        @(posedge clk);
        rst = 0;

        repeat (500) @ (posedge clk);

        repeat (2000) @ (negedge clk);

        #1 $finish;

    end

endmodule