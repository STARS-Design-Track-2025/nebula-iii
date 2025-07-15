module t08_registers(
    input logic clk, nRst, //Clock and active-low reset

    input logic [4:0] address_r1, address_r2, address_rd, //Addresses of the register(s) being read from and register being written to

    input logic [31:0] data_in_frommemory, data_in_frominstructionfetch, data_in_fromalu, //Data from different inputs connected to the register

    input logic [1:0] data_in_control, //For selecting which data is to be drawn from for input (multiplexer)

    input logic en_read_1, en_read_2, en_write, //Enable signals for reading from the registers and writing
    
    output logic [31:0] data_out_r1, data_out_r2 //Output when registers are read from
);

    logic [31:0] data_in;
    //logic [31:0] data_out_r1_n, data_out_r2_n;

    logic [31:0] [31:0] data;
    logic [31:0] [31:0] data_n;

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

        data_out_r1 = 0;
        data_out_r2 = 0;
        
        if (en_read_1) begin //Read from one register

            data_out_r1 = data[address_r1];

        end else begin

            data_out_r1 = data_out_r1;

        end

        if (en_read_2) begin //Read from a second register

            data_out_r2 = data[address_r2];

        end else begin

            data_out_r2 = data_out_r2;

        end

        if (en_write) begin //Write to a register

            data_n[address_rd] = data_in;

        end else begin

            data_n = data;

        end

    end

endmodule
