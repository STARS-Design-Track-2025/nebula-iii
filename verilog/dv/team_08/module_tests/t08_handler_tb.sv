`timescale 1ms/10ps
module t08_handler_tb;
logic [31:0] fromregister=0,  frommem=0, mem_address=0;
logic write=0, read=0, clk=0, nrst=1, writeout, readout, busy = 0, done = 1;
logic [2:0] func3=0;
logic [31:0] toreg,  tomem, addressnew, counter= 0, instruction;

task tfr;
   nrst = 0; #1;
   nrst = 1; #1;
endtask
    
always #1 clk = ~clk;
always #3 done = ~done;
always #5 counter = counter + 1;
always #5 frommem = frommem +2;
t08_handler blockhandle(.counter(counter), .instruction(instruction), .busy(busy), .done(done), .readout(readout), .writeout(writeout), .fromregister(fromregister), .frommem(frommem), .mem_address(mem_address), .write(write), .read(read), .clk(clk),.nrst(nrst), .func3(func3), .toreg(toreg), . tomem(tomem), .addressnew(addressnew));

initial begin
    $dumpfile("t08_handler.vcd"); 
    $dumpvars(0, t08_handler_tb);
    
    tfr; #1;

// data memory usage
    
    fromregister = {1'b0,{31{1'b1}}};

    mem_address = 12;
    write = 1;
    #4; busy = 1; #3;
    busy = 0; #1;

    for (integer i = 0; i <= 2; i++) begin
        func3 = i;
        mem_address = 32'h0000_000C + i;
        #10;end
    #10;
    write = 0;
    read = 1;
    frommem = {1'b0,{31{1'b1}}};

    for (integer j = 0; j <= 5; j++) begin
        if (j == 3) begin j = 4; end
            func3 = j;
            mem_address = 32'h0000_000C + j;
            busy = 1; #1;
            busy = 0; #1;
        #10; end
    #10;

    frommem = {1'b1,{31{1'b1}}};
    for (integer k = 0; k <= 5; k++) begin
        if (k == 3) begin k = 4; end
           func3 = k;
           mem_address = 32'h0000_000C + k;
                       busy = 1; #1;
            busy = 0; #1;
        #10; end
    #10;



    read = 0;
    write = 0;
    for (integer  w = 0; w <=20; w++) begin
        busy = 1;#1;
        busy = 0;
        // counter = w;
        //frommem = 10 + w;
        #5;
    end

    read = 1;
    fromregister = {12'b0,{10{1'b1}}}; #10;
    #5; $finish;  
    

end

endmodule


