`timescale 1ms/10ps

module t08_alu_tb;

    typedef enum logic [5:0] {
        ADD =   6'd1, //R type
        SUB =   6'd2,
        SLL =   6'd3,
        SLT =   6'd4,
        SLTU =  6'd5,
        XOR =   6'd6,
        SRL =   6'd7,
        SRA =   6'd8,
        OR =    6'd9,
        AND =   6'd10,
        
        ADDI =   6'd11, //I type
        SLTI =   6'd12,
        SLTIU =  6'd13,
        XORI =   6'd14,
        ORI =    6'd15,
        ANDI =   6'd16,
        SLLI =   6'd17,
        SRLI =   6'd18,
        SRAI =   6'd19,

        LB =     6'd20, //I type continued
        LH =     6'd21,
        LW =     6'd22,
        LBU =    6'd23,
        LHU =    6'd24,

        SB = 6'd25, //S type
        SH = 6'd26,
        SW = 6'd27,

        BEQ = 6'd28, //B type
        BNE = 6'd29,
        BLT = 6'd30,
        BGE = 6'd31,
        BLTU = 6'd32,
        BGEU = 6'd33,

        AUIPC = 6'd35 // U type

    } alu_operations;

    logic clk = 0;
    always clk = #5 ~clk;
    logic nRst;
    logic [31:0] reg1, reg2, immediate, program_counter;
    logic [5:0] alu_control;
    logic [31:0] data_out;
    logic branch;

    string testname;
    logic pass;
    logic [31:0] expectedresult;
    logic [31:0] actualresult;

    integer wrongCount = 0;
    logic wrong = 0;

    t08_alu alu(.reg1(reg1), .reg2(reg2), .immediate(immediate), .program_counter(program_counter), .alu_control(alu_control), .data_out(data_out), .branch(branch));

    task reset();
        nRst = 0; #1;
        nRst = 1; #1;
    endtask

    task run_operation(logic [5:0] operation);
        alu_control = operation; @ (negedge clk); @ (negedge clk);
        verify_operation(operation); @ (negedge clk); @ (negedge clk);
        if (operation >= 6'd28 && operation <= 6'd33) begin
            print_test_result(testname, (expectedresult == {31'b0, branch}), expectedresult, {31'b0, branch});
        end else begin
            print_test_result(testname, (expectedresult == data_out), expectedresult, data_out);
        end
    endtask

        task run_all_operations();
        for (int i = 1; i <= 31; i++) begin
            run_operation(i[5:0]);
        end
    endtask

    task verify_operation(logic [5:0] operation);
        case (alu_operations'(alu_control))

            // R type operations 
            ADD: begin
                testname = "add";
                expectedresult = reg1 + reg2;
            end 
            SUB: begin
                testname = "subtract";
                expectedresult =    reg1 - reg2;
            end
            SLL: begin
                testname = "shift left";
                expectedresult =    reg1 << (reg2[4:0]);
            end
            SLT: begin   
                testname = "set less than";
                expectedresult =    {31'b0, $signed(reg1) < $signed(reg2)};
            end
            SLTU: begin  
                testname = "set less than unsigned";
                expectedresult =    {31'b0, reg1 < reg2};
            end
            XOR: begin   
                testname = "xor";
                expectedresult =    reg1 ^ reg2;
            end
            SRL: begin   
                testname = "shift right logical";
                expectedresult =    reg1 >> (reg2[4:0]);
            end
            SRA: begin   
                testname = "shift right arithmetic";
                expectedresult =    reg1 >>> (reg2[4:0]);
            end
            OR: begin    
                testname = "or";
                expectedresult =    reg1 | reg2;
            end
            AND: begin   
                testname = "and";
                expectedresult =    reg1 & reg2;
            end

            //I type operations 
            ADDI: begin  
                testname = "add immediate";
                expectedresult =    reg1 + immediate;
            end
            SLTI: begin  
                testname = "set less than immediate";
                expectedresult =    {31'b0, $signed(reg1) < $signed(immediate)};
            end
            SLTIU: begin 
                testname = "set less than immediate unsigned";
                expectedresult =    {31'b0, reg1 < immediate};
            end
            XORI: begin  
                testname = "xor immediate";
                expectedresult =    reg1 ^ immediate;
            end
            ORI: begin   
                testname = "or immediate";
                expectedresult =    reg1 | immediate;
            end
            ANDI: begin  
                testname = "and immediate";
                expectedresult =    reg1 & immediate;
            end
            SLLI: begin
                testname = "shift left logical immediate";
                expectedresult =    reg1 << immediate[4:0];
            end
            SRLI: begin
                testname = "shift right logical immediate";
                expectedresult =    reg1 >> immediate[4:0];
            end
            SRAI: begin
                testname = "shift right arithmetic immediate";
                expectedresult =    reg1 >>> immediate[4:0];
            end
            LB, LBU, LH, LHU, LW: begin   
                testname = "load operations";
                expectedresult =    reg1 + immediate;
            end

            //S type operations
            SB, SH, SW: begin
                testname = "S type operations";
                expectedresult = reg1 + immediate;
            end

            //B type operations
            BEQ: begin
                testname = "branch equal";
                expectedresult =     {31'b0, (reg1 == reg2)};
            end
            BGE: begin   
                testname = "branch greater than";
                expectedresult =     {31'b0, ($signed(reg1) >= $signed(reg2))};
            end
            BGEU: begin  
                testname = "branch greater than or equal";
                expectedresult =     {31'b0, (reg1 >= reg2)};
            end
            BLT: begin   
                testname = "branch less than";
                expectedresult =     {31'b0, ($signed(reg1) < $signed(reg2))};
            end
            BLTU: begin  
                testname = "branch less than unsigned";
                expectedresult =     {31'b0, (reg1 < reg2)};
            end
            BNE: begin   
                testname = "branch not equal";
                expectedresult =     {31'b0, (reg1 != reg2)};
            end

            //U type operations
            AUIPC: begin 
                testname = "AUIPC";
                expectedresult =    program_counter + immediate; 
            end

            default: begin
                testname = "None";
                expectedresult = 32'b0;
            end

        endcase
    endtask

    task print_test_result(string name, logic pass, logic [31:0] expectedresult, logic [31:0] actualresult);
        if (!pass) begin
            $display("TEST FAIL: %s. Expected %B and got %B", name, expectedresult, actualresult);
            wrongCount++;
            wrong = 1; #1
            wrong = 0;
        end
    endtask

    initial begin

        $dumpfile("t08_alu.vcd");
        $dumpvars(0, t08_alu_tb);

        //Power on reset
        reset();

        //Test set 1
        reg1 = 32'sd100;
        reg2 = 32'sd200;
        immediate = 32'sd300;
        program_counter = 32'sd400; @ (negedge clk);

        run_all_operations;

        // //Test set 2
        reg1 = -32'sd500;
        reg2 = 32'sd200;
        immediate = 32'sd300;
        program_counter = 32'sd0; @ (negedge clk);

        run_all_operations;

        // //Test set 3
        reg1 = -32'sd100000;
        reg2 = -32'sd7;
        immediate = 32'sd300;
        program_counter = 32'sd2987; @ (negedge clk);

        run_all_operations;

        // //Test set 4
        reg1 = 32'sd0;
        reg2 = 32'sd0;
        immediate = -32'sd389;
        program_counter = 32'sd1; @ (negedge clk);

        run_all_operations;

        $display("Wrong count: %-4d", wrongCount);

        $display($signed(4'b1100 >> 1'b1));
        $display($signed($signed(4'b1100) >>> 1'b1));

        #1 $finish;

    end

endmodule