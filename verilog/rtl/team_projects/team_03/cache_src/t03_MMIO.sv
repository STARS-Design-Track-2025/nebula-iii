`default_nettype none
`timescale 1ps/1ps

module t03_MMIO(
    input logic clk,rst,

    //wishbone inputs
    input logic  [31:0] wb_di, //wishbone data in
    input logic  wb_ack,
    
    //cpu inputs
    input logic [31:0] cpu_din, cpu_addr, //cpu data and address
    input logic cpu_wen,cpu_ren, //cpu read enable and write en 

    //NES controller inputs
    input logic [31:0] NES_din, //NES data
    input logic NES_ack,

    // //Hardware counter input
    input logic [31:0] hardwareClk,
    input logic hardware_ack,

    //output to wishbone
    output logic [31:0] wb_do,
    output logic [31:0] wb_addro,
    output logic [3:0]  wb_sel, //assign to 4'b1111  
    output logic        wb_wen,
    output logic        wb_ren,

    //output to CPU
    output logic [31:0] cpu_do,
    output logic cpu_ack,

    //output to DPU
    output logic [31:0] dpu_addro, //address that is decoded in dpu to go to either positional or not positional
    output logic [31:0] dpu_do
);

assign cpu_do = address_enable ? peripheral_output : wb_di;

assign wb_sel = 4'b1111;
logic n_address_enable, address_enable;
logic [31:0] peripheral_output, n_peripheral_output;

always_ff @ (posedge clk, posedge rst) begin
    if(rst) begin
        address_enable <= 1'b0;
        peripheral_output <= 32'b0;
    end else begin
        address_enable <= n_address_enable;
        peripheral_output <= n_peripheral_output;
    end
end

always_comb begin

    cpu_ack = 0;

    dpu_addro = cpu_addr;
    dpu_do = cpu_din;

    //for debugging!!
        //   n_gameState = data[14:12];
        //     n_p1State = data[11:10];
        //     n_p2State = data[9:8];
        //     n_p1health = data[7:4];
        //     n_p2health = data[3:0];
    // dpu_addro = 32'hFF000004;
    // dpu_do = 32'b011010111111111;

    // dpu_addro = 32'hFF000008;
    // dpu_do = 32'h37230000;

    wb_addro = 32'b0;
    wb_ren = 1'b0;
    wb_wen = 1'b0;
    wb_do = 32'b0;
    cpu_ack = 1'b0;
    n_address_enable = address_enable;
    n_peripheral_output = peripheral_output;

    case(cpu_addr) //REAL DEAL MMIO
        32'hFF000000: begin //NES controller | means that cpu ren is high
            cpu_ack = NES_ack; //Because on the next clock cycle we will be ready
            n_peripheral_output = NES_din;

            if(NES_ack) begin
                n_address_enable = 1'b1;
            end
        end
        32'hFF000004: begin //dpu data for state etc | cpu wen is high
            cpu_ack = 1'b1;
            // dpu_addro = 32'hFF000004;
            // dpu_do = 32'h1FFFFFFF;
        end
        32'hFF000008: begin //positional data | cpu wen is high
            cpu_ack = 1'b1;
            // dpu_addro = 32'hFF000008;
            // dpu_do = 32'h37230000;
        end
        32'hFF00000C: begin //positional data | cpu wen is high
            cpu_ack = hardware_ack; //Because on the next clock cycle we will be ready
            n_peripheral_output = hardwareClk;

            if(hardware_ack) begin
                n_address_enable = 1'b1;
            end
        end
        default: begin //in default case cpu is talking to RAM using wishbone
            wb_addro = cpu_addr;
            wb_ren = cpu_ren;
            wb_wen = cpu_wen;
            wb_do = cpu_din;
            cpu_ack = wb_ack;

            if(wb_ack) begin
                n_address_enable = 1'b0;
            end
        end
    endcase

end

endmodule