`timescale 1ns / 1ps
module t07_control_unit_tb ();
    //control unit inputs
    logic [6:0] Op, funct7;
    logic [2:0] funct3;
    logic [4:0] rs2;
    //control unit outputs
    logic ALUSrc, regWrite, branch, jump, memWrite, memRead, memToReg, FPUSrc, regEnable;
    logic [2:0] regWriteSrc, FPURnd;
    logic [4:0] FPUOp, rs3;
    logic [1:0] FPUWrite;
    logic [3:0] memOp, ALUOp;

    t07_control_unit control(.rs3(rs3), .memOp(memOp), .rs2(rs2), .regWriteSrc(regWriteSrc), .Op(Op), .funct7(funct7), .funct3(funct3), .ALUOp(ALUOp), .ALUSrc(ALUSrc), .regWrite(regWrite), .branch(branch), .jump(jump), .memWrite(memWrite), .memRead(memRead), .FPUSrc(FPUSrc), .regEnable(regEnable), .FPUOp(FPUOp), .FPURnd(FPURnd), .FPUWrite(FPUWrite));

    task Opcodes; begin
        Op = 'b0110111; //U-type, lui
        funct3_task();
        #6
        Op = 'b0010111; //U-type, auipc
        funct3_task();
        #12
        Op = 'b1101111; //J-type, jal
        funct3_task();
        #12
        Op = 'b1100111; //I-type, jalr
        funct3_task();
        #12
        Op = 'b1100011; //B-type
        funct3_task();
        #12
        Op = 'b0000011; //I-type (load)
        funct3_task();
        #12
        Op = 'b0100011; //S-type
        funct3_task();
        #12
        Op = 'b0010011; //I-type (immediate)
        funct3_task();
        #12
        Op = 'b0110011; //R-type
        funct3_task();
    end
    endtask

    task funct3_task; begin
        funct3 = 'b000;
        funct7_task();
        #1.5
        funct3 = 'b001;
        funct7_task();
        #1.5
        funct3 = 'b010;
        funct7_task();
        #1.5
        funct3 = 'b011;
        funct7_task();
        #1.5
        funct3 = 'b100;
        funct7_task();
        #1.5
        funct3 = 'b101;
        funct7_task();
        #1.5
        funct3 = 'b110;
        funct7_task();
        #1.5
        funct3 = 'b111;
        funct7_task();
    end
    endtask

    task funct7_task; begin
        funct7 = '0;
        rs2_task();
        #1
        funct7 = 'b0100000;
        rs2_task();
    end
    endtask

    task rs2_task; begin
        rs2 = '0;
        #1 
        rs2 = 5'b00001;
    end
    endtask

    task check_Rtype; begin
        if(Op == 'b110011) begin
            if(funct3 == 'b000 & funct7 == '0 & ALUOp == 4'd0) begin $display("add is correct"); end else begin $display("add error"); end
            if(funct3 == 'b000 & funct7 == 'b0100000 & ALUOp == 4'd08) begin $display("sub is correct"); end else begin $display("sub error"); end
        end
    end
    endtask

    //signal dump
    initial begin
        $dumpfile("t07_control_unit.vcd");
        $dumpvars(0, t07_control_unit_tb);

    Opcodes();
        #1
        Opcodes();

        check_Rtype();
        
        #1 
        $finish;
    

    end




endmodule