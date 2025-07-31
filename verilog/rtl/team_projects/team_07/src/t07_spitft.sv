module t07_spitft (
    input logic [31:0] data,
    input logic [31:0] address,
    input logic clk,
    input logic nrst,
    input logic wi,

    output logic busy_o, // to memory handler
    
    // to ra8875
    output logic chipSelect,
    output logic bitData,
    output logic sclk                                                                                                  
);

logic [63:0] dataforOutput, next_data;
logic [1:0] state, next_state;
logic printState, busy_o_n;


always_ff @(negedge nrst, posedge clk) begin
    if(~nrst) begin
        dataforOutput <= '0;
        state <= 'b0;
        busy_o <= '0;
    end else begin
        dataforOutput <= next_data;
        state <= next_state;
        busy_o <= busy_o_n;
    end
end

always_comb begin
    bitData = 0;
    next_data = dataforOutput;
    next_state = state;
    busy_o_n = 0;
    chipSelect = 1;
    sclk = 0;

    case(state) 
    //state 0 - idle
        2'b0: begin 
            chipSelect = 0;
            sclk = '0;
            busy_o_n = 0;
            if (wi == 1) begin next_state = 2'b1; end 
            else begin next_state = 2'b0; end
        end
    //state 1 - loading data
        2'b1: begin if (wi == 1) begin chipSelect = 0; busy_o_n = 1; sclk = clk; 
            next_data = {address[31:24], data[31:24],  address[23:16], data[23:16], address[15:8], data[15:8], address[7:0], data[7:0]}; 
            next_state = 2'd2; 
            end else begin next_state = 2'b0; end end //load 64 bits
    //state 2 - serially outputting data
        2'd2: begin 
            sclk = clk;
            if (wi == 1 && dataforOutput != '0) begin
                chipSelect = 0; 
                bitData = dataforOutput[63];
                next_data = dataforOutput << 1;
                next_state = 2'd2;
                busy_o_n = 1;
                //sclk = clk;
            end else if (wi == 1 && dataforOutput == '0) begin
                busy_o_n = 1;
                chipSelect = 1;
                next_state = 2'd2;
            end else begin //wi == 0
                busy_o_n = 0;
                chipSelect = 1;
                //sclk = 0;
                next_state = 2'b0;
        end //shift 64 bits
      end
      default: begin sclk = 0; busy_o_n = 0; end
    endcase
end
endmodule


