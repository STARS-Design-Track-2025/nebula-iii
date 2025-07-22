module t08_registers(
    input logic clk, nRst, //Clock and active-low reset

    input logic [4:0] address_r1, address_r2, address_rd, //Addresses of the register(s) being read from and register being written to

    input logic [31:0] data_in_frommemory, data_in_frominstructionfetch, data_in_fromalu, //Data from different inputs connected to the register

    input logic [1:0] data_in_control, //For selecting which data is to be drawn from for input (multiplexer)

    input logic en_read_1, en_read_2, en_write, //Enable signals for reading from the registers and writing

    input logic busy, //Disables all reading and writing
    
    output logic [31:0] data_out_r1, data_out_r2 //Output when registers are read from
);

    logic [31:0] data_in;
    //logic [31:0] data_out_r1_n, data_out_r2_n;

    logic [31:0] [31:0] data;
    logic [31:0] [31:0] data_n;

    logic [31:0] data_out_r1_prev = 0;
    logic [31:0] data_out_r2_prev = 0;

    always_ff @ (/*posedge clk, */negedge clk, negedge nRst) begin
        if (!nRst) begin
            
            //data_out_r1 <= 0;
            //data_out_r2 <= 0;
            data <= {1024'b0};

        // end else if (clk == 1) begin

        //     data_out_r1 <= data_out_r1_n;
        //     data_out_r2 <= data_out_r2_n;

        // 
        end else begin

            data <= data_n;

            data_out_r1_prev <= data_out_r1;
            data_out_r2_prev <= data_out_r2;

        end
    end

    always_comb begin : select_data_in

        case (data_in_control) 

            2'b01: data_in = data_in_frommemory;
            2'b10: data_in = data_in_frominstructionfetch;
            2'b11: data_in = data_in_fromalu;
            default: data_in = 0;

        endcase

    end

    always_comb begin : read_and_write

        data_out_r1 = data_out_r1_prev;
        data_out_r2 = data_out_r2_prev;
        
        if (en_read_1 && !busy) begin //Read from one register

            data_out_r1 = data[address_r1];

        end 

        if (en_read_2 && !busy) begin //Read from a second register

            data_out_r2 = data[address_r2];

        end 

        if (en_write && !busy) begin //Write to a register

            data_n[address_rd] = data_in;

        end else begin

            data_n = data;

        end

    end

    logic [31:0] reg31, reg30, reg29, reg28, reg27, reg26, reg25, reg24, reg23, reg22, reg21, reg20, reg19, reg18, reg17, reg16, reg15, reg14, reg13,
                   reg12, reg11, reg10, reg09, reg08, reg07, reg06, reg05, reg04, reg03, reg02, reg01, reg00;

    assign {reg31, reg30, reg29, reg28, reg27, reg26, reg25, reg24, reg23, reg22, reg21, reg20, reg19, reg18, reg17, reg16, reg15, reg14, reg13,
                   reg12, reg11, reg10, reg09, reg08, reg07, reg06, reg05, reg04, reg03, reg02, reg01, reg00} = data;

endmodule
