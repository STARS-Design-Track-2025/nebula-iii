`timescale 1ms/10ps

module t08_I2C_and_interrupt_tb;

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

        SDAin = 0; @ (negedge clk);
        SDAin = 1; @ (negedge clk);

    endtask

    task send_data_frame(logic [7:0] data);

        for (int i = 7; i >= 0; i--) begin

            SDAin = data[i]; @ (negedge scl);

        end

        SDAin = 1;

    endtask

    initial begin

        $dumpfile("t08_I2C_and_interrupt.vcd");
        $dumpvars(0, t08_I2C_and_interrupt_tb);

        reset();

        interrupt();

        repeat (9) @ (negedge scl); repeat (6) @ (negedge clk);

        //Acknowledge bit after slave address in XH
        acknowledge();

        repeat (10) @ (negedge scl); 

        //Acknowledge bit after data address in XL
        acknowledge();

        repeat (14) @ (negedge scl); 

        //Acknowledge bit after slave address 2 in XL (ready for data frame)
        acknowledge();

        @ (negedge scl); @ (posedge scl);

        test = 1;

        send_data_frame(8'b11011001);

        repeat (80) @ (negedge clk);
        @ (negedge clk);
  
        // acknowledge();
        
        // // repeat (80) @ (negedge clk);
        // // @ (negedge clk);

        // // acknowledge();

        // // repeat (80) @ (negedge clk);
        // // @ (negedge clk);

        // // acknowledge();

        // // repeat (80) @ (negedge clk);
        // // @ (negedge clk);

        // // acknowledge();

        // // repeat (80) @ (negedge clk);
        // // @ (negedge clk);

        // // acknowledge();

        // repeat (150) @ (negedge clk);

        #1 $finish;

    end

endmodule