module t07_spitft (
    input logic [31:0] data,
    input logic [31:0] address,
    input logic clk,
    input logic nrst,
    input logic wi,

    output logic ack, // to memory handler
    
    // to ra8875
    output logic chipSelect,
    output logic bitData,
    output logic sclk                                                                                                  
);

logic [63:0] dataforOutput, next_data;
logic state, next_state;
logic printState;
logic [6:0] counter, next_ctr;


always_ff @(negedge nrst, posedge clk) begin
    if(~nrst) begin
        dataforOutput <= '0;
        counter <= 7'b0;
        state <= 1'b0;
    end else begin
        dataforOutput <= next_data;
        state <= next_state;
        counter <= next_ctr;
    end
end

always_comb begin
    bitData = 0;
    next_data = dataforOutput;
    next_state = state;
    ack = 0;
    chipSelect = 1;
    sclk = 0;
    next_ctr = counter;

    case (state) 
      1'b0: begin if (wi == 1) begin next_ctr = 7'b0; chipSelect = 0; ack = 1; sclk = clk; next_data = {address[31:24], data[31:24],  address[23:16], data[23:16], address[15:8], data[15:8], address[7:0], data[7:0]}; next_state = 1'b1; end else begin next_state = 1'b0; end end //load 64 bits
      1'b1: begin if (wi == 1 && counter < 7'd64) begin
                ack = 1;
                chipSelect = 0; 
                sclk = clk;
                bitData = dataforOutput[63];
                next_data = dataforOutput << 1;
                next_state = 1'b1;
                next_ctr = counter + 1;
        end else if (wi == 1 && counter == 7'd64) begin
            ack = 0;
            chipSelect = 1;
            next_state = 1'b0;
        end else if (wi == 0) begin
            ack = 0;
            chipSelect = 1;
            sclk = 0;
            next_state = 1'b0;
        end //shift 64 bits
      end
      default: begin sclk = 0; ack = 0; end
    endcase
end

endmodule


