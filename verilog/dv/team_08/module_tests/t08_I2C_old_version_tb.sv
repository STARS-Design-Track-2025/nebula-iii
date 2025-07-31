`timescale 1ms/10ps

module t08_I2C_old_version_tb;

    logic clk = 0;
    always clk = #5 ~clk;
    logic nrst = 1;
    logic SDAin = 1;
    logic SDAout;
    logic inter = 1; //Interrupt is active low
    logic scl;
    logic [31:0] data_out;
    logic done;

    logic test = 0;

    t08_I2C_and_interrupt I2C(.clk(clk), .nRst(nrst), .SDAin(SDAin), .SDAout(SDAout), .inter(inter), .scl(scl), .data_out(data_out), .done(done));

    task reset();

        nrst = 0; @ (negedge clk);
        nrst = 1; @ (negedge clk);

    endtask

    task interrupt();

        inter = 0; @ (negedge clk);
        inter = 1; @ (negedge clk);

    endtask

    task acknowledge();

        SDAin = 0; @ (negedge scl); //@ (negedge scl);
        SDAin = 1; @ (negedge clk);

    endtask

    task send_data_frame(logic [7:0] data);

        for (int i = 7; i >= 0; i--) begin

            SDAin = data[i]; @ (negedge scl); //@ (posedge clk);

        end

        SDAin = 1;

    endtask

    initial begin

        $dumpfile("t08_I2C_and_interrupt.vcd");
        $dumpvars(0, t08_I2C_old_version_tb);

        reset();

        interrupt();

        /*XH phase*/

        repeat (9) @ (negedge scl); //repeat (4) @ (negedge clk);

        // Acknowledge bit after slave address in XH
        acknowledge();

        repeat (10) @ (negedge scl); @ (negedge clk);

        //Acknowledge bit after data address in XH
        acknowledge();

        repeat (14) @ (negedge scl); @ (negedge clk);

        //Acknowledge bit after slave address 2 in XH (ready for data frame)
        acknowledge();

        //@ (negedge scl); @ (posedge scl); @ (posedge clk);

        //test = 1;

        send_data_frame(8'b11011001); //D9

        repeat (3) @ (negedge scl);

        /*XL phase*/

        repeat (9) @ (negedge scl); //repeat (4) @ (negedge clk);

        //Acknowledge bit after slave address in XH
        acknowledge();

        repeat (10) @ (negedge scl); @ (negedge clk);

        //Acknowledge bit after data address in XH
        acknowledge();

        repeat (14) @ (negedge scl); @ (negedge clk);

        //Acknowledge bit after slave address 2 in XH (ready for data frame)
        acknowledge();

        //@ (negedge scl); @ (posedge scl); @ (posedge clk);

        //test = 1;

        send_data_frame(8'b11011001); //D9

        repeat (3) @ (negedge scl);

        /*YH phase*/

        repeat (9) @ (negedge scl); //repeat (4) @ (negedge clk);

        //Acknowledge bit after slave address in XH
        acknowledge();

        repeat (10) @ (negedge scl); @ (negedge clk);

        //Acknowledge bit after data address in XH
        acknowledge();

        repeat (14) @ (negedge scl); @ (negedge clk);

        //Acknowledge bit after slave address 2 in XH (ready for data frame)
        acknowledge();

        //@ (negedge scl); @ (posedge scl); @ (posedge clk);

        //test = 1;

        send_data_frame(8'b11011001); //D9

        repeat (3) @ (negedge scl);

        /*YL phase*/

        // repeat (9) @ (negedge scl); //repeat (4) @ (negedge clk);

        // //Acknowledge bit after slave address in XH
        // acknowledge();

        // repeat (10) @ (negedge scl); @ (negedge clk);

        // //Acknowledge bit after data address in XH
        // acknowledge();

        // repeat (14) @ (negedge scl); @ (negedge clk);

        // //Acknowledge bit after slave address 2 in XH (ready for data frame)
        // acknowledge();

        // //@ (negedge scl); @ (posedge scl); @ (posedge clk);

        // //test = 1;

        // send_data_frame(8'b11011001); //D9

        // repeat (2) @ (negedge scl);

        // repeat(20) @ (negedge clk);

        #1 $finish;

    end

endmodule