`timescale 1s/10ps

module t08_display_tb;

    logic clk, Rst;
    always begin
        clk = 0;
        #1;
        clk = 1;
        #1;
    end

    logic [31:0] controlBus = 32'b10000000;
    logic [31:0] xBus = 32'b1100100000_000001001111; //800-top 20 bits, 79 -lower 12bits
    logic [31:0] yBus = 32'b1111000000_000001011001; //960 -top 20 bits, 89 lower 12 bits
    logic [22:0] ct;
    logic ack, dcx, wrx, csx;
    logic [7:0] data;
    
    t08_display disptest (.controlBus(controlBus), .xBus(xBus), .yBus(yBus), .ct(ct), .clk(clk), .rst(Rst), .ack(ack), .dcx(dcx), .wrx(wrx), .csx(csx), .data(data));
    
   

    initial begin

        $dumpfile("t08_display.vcd");
        $dumpvars(0, t08_display_tb);

        Rst = 0;
        @(posedge clk);
        Rst = 1; #4;
        @(posedge clk);
        Rst = 0;
        ct = 0;
        for (integer i = 0; i < 2000000; i++) begin
            @(posedge clk);
            ct = ct + 1; 
            if (ct == 1200028 && controlBus == 32'b10000000) begin
                controlBus = 32'b10;
                ct = 0;
            end else if (ct == 36 && controlBus == 32'b10) begin
                ct = 0;
            end
        end
      
        #1 $finish;

    end

endmodule