`timescale 1ms/10ps

module t08_registers_tb;

    logic clk = 0;
    always clk = #5 ~clk;
    logic nRst;

    logic [4:0] address_r1 = 0;
    logic [4:0] address_r2 = 0;
    logic [4:0] address_rd = 0;
    logic [31:0] data_in_frommemory = 0;
    logic [31:0] data_in_frominstructionfetch = 0;
    logic [31:0] data_in_fromalu = 0;
    logic [1:0] data_in_control = 0;
    logic en_read_1 = 0; 
    logic en_read_2 = 0; 
    logic en_write = 0;
    logic [31:0] data_out_r1, data_out_r2;

    t08_registers registers(.clk(clk), .nRst(nRst), .address_r1(address_r1), .address_r2(address_r2), .address_rd(address_rd), 
        .data_in_frommemory(data_in_frommemory), .data_in_frominstructionfetch(data_in_frominstructionfetch), .data_in_fromalu(data_in_fromalu), 
        .data_in_control(data_in_control), .en_read_1(en_read_1), .en_read_2(en_read_2), .en_write(en_write), .data_out_r1(data_out_r1), 
        .data_out_r2(data_out_r2));

    string testname;
    logic pass;
    logic [31:0] expectedresult;
    logic [31:0] actualresult;

    integer testNumber = 0;
    integer wrongCount = 0;

    task reset();
        nRst = 0; #1;
        nRst = 1; #1;
    endtask

    initial begin

        $dumpfile("waves/t08_registers.vcd");
        $dumpvars(0, t08_registers_tb);

        //Power on reset
        reset();

        //Test 1: Reading only from register 18, which should currently contain 0. 
        testNumber++;
        en_read_1 = 0;
        en_read_2 = 1;
        en_write = 0;
        data_in_control = 0;
        address_r1 = 5'd5;
        address_r2 = 5'd18;
        address_rd = 5'd13;
        data_in_frommemory = 32'd345;
        data_in_frominstructionfetch = 32'd1024;
        data_in_fromalu = 32'd0;
        @ (negedge clk); @ (negedge clk);

        //Test 2: Writing 345 to register 13.
        testNumber++;
        en_read_1 = 0;
        en_read_2 = 0;
        en_write = 1;
        data_in_control = 0;
        address_r1 = 5'd5;
        address_r2 = 5'd18;
        address_rd = 5'd13;
        data_in_frommemory = 32'd345;
        data_in_frominstructionfetch = 32'd1024;
        data_in_fromalu = 32'd0;
        @ (negedge clk); @ (negedge clk);

        //Test 3: Reading from register 13 to make sure it contains 345. 
        testNumber++;
        en_read_1 = 1;
        en_read_2 = 0;
        en_write = 0;
        data_in_control = 0;
        address_r1 = 5'd13;
        address_r2 = 5'd18;
        address_rd = 5'd5;
        data_in_frommemory = 32'd345;
        data_in_frominstructionfetch = 32'd1024;
        data_in_fromalu = 32'd0;
        @ (negedge clk); @ (negedge clk);

        //Test 4: Disabling both read and write and making sure the output doesn't change. 
        testNumber++;
        en_read_1 = 0;
        en_read_2 = 0;
        en_write = 0;
        data_in_control = 0;
        address_r1 = 5'd13;
        address_r2 = 5'd18;
        address_rd = 5'd5;
        data_in_frommemory = 32'd345;
        data_in_frominstructionfetch = 32'd1024;
        data_in_fromalu = 32'd0;
        @ (negedge clk); @ (negedge clk);

        //Test 5: Changing data_in_control to pull from instruction fetch instead. (Register 5 should now hold 1024)
        testNumber++;
        en_read_1 = 0;
        en_read_2 = 0;
        en_write = 1;
        data_in_control = 1;
        address_r1 = 5'd13;
        address_r2 = 5'd18;
        address_rd = 5'd5;
        data_in_frommemory = 32'd345;
        data_in_frominstructionfetch = 32'd1024;
        data_in_fromalu = 32'd0;
        @ (negedge clk); @ (negedge clk);

        //Test 6: Verifying that register 5 holds 1024.
        testNumber++;
        en_read_1 = 0;
        en_read_2 = 1;
        en_write = 0;
        data_in_control = 1;
        address_r1 = 5'd13;
        address_r2 = 5'd5;
        address_rd = 5'd5;
        data_in_frommemory = 32'd345;
        data_in_frominstructionfetch = 32'd1024;
        data_in_fromalu = 32'd0;
        @ (negedge clk); @ (negedge clk);

        //Test 7: Changing data_in_control to pull from alu instead. (Register 5 should now hold 0)
        testNumber++;
        en_read_1 = 0;
        en_read_2 = 0;
        en_write = 1;
        data_in_control = 2'b10;
        address_r1 = 5'd13;
        address_r2 = 5'd18;
        address_rd = 5'd5;
        data_in_frommemory = 32'd345;
        data_in_frominstructionfetch = 32'd1024;
        data_in_fromalu = 32'd0;
        @ (negedge clk); @ (negedge clk);

        //Test 8: Verifying that register 5 holds 0.
        testNumber++;
        en_read_1 = 0;
        en_read_2 = 1;
        en_write = 0;
        data_in_control = 1;
        address_r1 = 5'd13;
        address_r2 = 5'd5;
        address_rd = 5'd5;
        data_in_frommemory = 32'd345;
        data_in_frominstructionfetch = 32'd1024;
        data_in_fromalu = 32'd0;
        @ (negedge clk); @ (negedge clk);

        //Test 9: Reading from two registers at once. (Should output 345 and 0) 
        testNumber++;
        en_read_1 = 1;
        en_read_2 = 1;
        en_write = 0;
        data_in_control = 0;
        address_r1 = 5'd13;
        address_r2 = 5'd18;
        address_rd = 5'd5;
        data_in_frommemory = 32'd345;
        data_in_frominstructionfetch = 32'd1024;
        data_in_fromalu = 32'd0;
        @ (negedge clk); @ (negedge clk);

        #1 $finish;

    end

endmodule