`timescale 1ms / 1ps
module t07_top_tb();
    logic clk, nrst;
    logic [7:0] ESP_in;
    logic FPUFlag, invalError;

    t07_top top0(.clk(clk), .nrst(nrst), .FPUFlag(FPUFlag), .invalError(invalError), .ESP_in(ESP_in));

    // task ESP_val(); begin
    //     ESP_in = 8'hAA;
    //     #4;
    //     ESP_in = 8'hBB;
    //     #4;
    //     ESP_in = 8'hCC;
    //     #4;
    //     ESP_in = 8'hDD;
    //     #4;
    // end
    // endtask

    // task ESP_valLoop(); begin
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();
    //     ESP_val();

    // end
    // endtask

    task reset(); begin
        #2
        nrst = ~nrst;        
        #2
        nrst = ~nrst;
    end
    endtask

    always begin
        #2
        clk = ~clk;
    end

    initial begin
        $dumpfile("t07_top.vcd");
        $dumpvars(0, t07_top_tb);
        clk = 0;
        nrst = 1;
        ESP_in = '0;
        reset();

        #400
        $finish;
    end

endmodule