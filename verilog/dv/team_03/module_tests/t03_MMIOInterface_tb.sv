`timescale 1ms/10ps

module MMIOInterface_tb;

    logic clk;
    logic rst;
    logic [31:0] data;
    logic [31:0] address;
    logic write;
    logic read;
    logic [31:0] dataOut;
    logic ack;
    integer testNumber;

    MMIOInterface DUT(.clk(clk), .rst(rst), .data(data), .address(address), .write(write), .read(read), .dataOut(dataOut), .ack(ack));

    parameter CLKPERIOD = 10;

    always begin
        #(CLKPERIOD/2) clk = 1'b1;
        #(CLKPERIOD/2) clk = 1'b0;
    end
    
    initial begin
    // make sure to dump the signals so we can see them in the waveform
    $dumpfile("waves/MMIOInterface.vcd");
    $dumpvars(0, MMIOInterface_tb);

    initialize();

    rst = 1'b1;

    @ (posedge clk);
    @ (negedge clk);

    rst = 1'b0;

    //ADDRESS IS BYTE ADDRESS, SO WE SHIFT IT BY 2 TO GET IT WORD ADDRESSED

    //Reading first instruction
    address = (32'd0 << 2);
    read = 1'b1;

    while(~ack) @ (posedge clk);
    read = 1'b0;
    @ (negedge clk);

    checkDataOut(32'b00000000001100010000000010110011);

    //Reading second instruction
    address = (32'd1 << 2);
    read = 1'b1;

    while(~ack) @ (posedge clk);
    read = 1'b0;
    @ (negedge clk);

    checkDataOut(32'b01000000001100010000000010110011);

    //Reading third instruction
    address = (32'd2 << 2);
    read = 1'b1;

    while(~ack) @ (posedge clk);
    read = 1'b0;
    @ (negedge clk);

    checkDataOut(32'b00111110100000010000000010010011);

    //Writing third instruction
    address = (32'd2 << 2);
    write = 1'b1;
    data = 32'hDEADBEEF;

    while(~ack) @ (posedge clk);
    write = 1'b0;
    @ (negedge clk);


    //Reading third instruction
    address = (32'd2 << 2);
    read = 1'b1;

    while(~ack) @ (posedge clk);
    read = 1'b0;
    @ (negedge clk);

    checkDataOut(32'hDEADBEEF);


    // finish the simulation
    #1 $finish;
    end

    task initialize();
        begin
        clk = 1'b0;
        rst = 1'b0;
        data = 32'b0;
        address = 32'b0;
        write = 1'b0;
        read = 1'b0;
        testNumber = 1'b1;
        #1;
        end
    endtask

    task checkDataOut(input [31:0] taskDataOut);
        begin
            $display("testNumber = \%d, dataOut=\%b", testNumber++, dataOut);

            if(taskDataOut != dataOut) begin
                $display("ERROR: Expected dataOut is %b, but dataOut is %b", taskDataOut, dataOut);
            end
        end
    endtask

endmodule
