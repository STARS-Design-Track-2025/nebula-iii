 typedef enum logic [1:0] {  
        IDLE = 0,
        LOAD = 1,
        OUTPUT = 2
    } state_tft;

module t07_spitft (
    input logic [15:0] in,
    input logic clk,
    input logic nrst,
    input logic wi,
    input logic delay,
    input logic miso_in,

    output logic [7:0] miso_out, //to internal registers

    output logic ack, // to memory handler
    // to ra8875
    
    output logic chipSelect,
    output logic bitData,
    output logic sclk                                                                                                  
);

    logic [15:0] next_miso, misoShift;
    logic [15:0] dataforOutput, next_data;
    logic [1:0] state, next_state;
    logic [4:0] counter, next_ctr;


    always_ff @(negedge nrst, posedge clk) begin
        if(~nrst) begin
            dataforOutput <= '0;
            counter <= 5'b0;
            state <= 2'b0;
            misoShift <= '0;
        end else begin
            dataforOutput <= next_data;
            state <= next_state;
            counter <= next_ctr;
            misoShift <= next_miso;
        end
    end

    always_comb begin
        bitData = 0;
        next_data = dataforOutput;
        next_miso = misoShift;
        next_state = state;
        ack = 0;
        chipSelect = 1;
        sclk = 0;
        next_ctr = counter;
        miso_out = '0;

        case (state) 
            2'b00: begin if (delay == 1) begin next_state = 2'b10; end
            else if (wi == 1) begin 
                next_ctr = 5'b0; 
                chipSelect = 0; 
                ack = 1; 
                sclk = clk; 
                next_data = in;
                next_miso = '0;
                next_state = 2'b01;
            end else begin 
                    next_state = 2'b00; 
            end 
            end //load 16 bits
            2'b01: begin if (delay == 1) begin next_state = 2'b10; end
                else if (wi == 1 && counter < 5'd16) begin
                    ack = 1;
                    chipSelect = 0; 
                    sclk = clk;
                    bitData = dataforOutput[15];
                    next_data = dataforOutput << 1;
                    if (in[15:8] == 8'h40) begin
                        next_miso = {misoShift[14:0], miso_in};
                        //next_ctr = counter + 1;
                    end

                    next_state = 2'b01;
                    next_ctr = counter + 1;
                end 
                else if ((wi == 1 && counter == 5'd16) || wi == 0 || delay == 1) begin
                    if ((counter == 5'd16) && in[15:8] == 8'h40) begin
                        sclk = clk;
                        miso_out = misoShift[7:0];
                        //next_state = 2'b01;
                    end
                    next_state = 2'b10;
                end //write - shift 16 bits
                
            end
            2'b10: begin
                ack = 0;
                chipSelect = 1;
                sclk = 0;
                if (delay == 1) begin next_state = 2'b10; end else if (delay == 0) begin next_state = 2'b00; end
            end //idle / delay
            default: begin sclk = 0; ack = 0; end
    endcase
end
endmodule
