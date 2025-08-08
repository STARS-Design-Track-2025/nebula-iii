module t07_spiTFTHu (
    input logic clk,
    input logic nrst,
    
    //from MMIO
    input logic [31:0] MOSI_data, //first 16 bits represent amount o cycles to dely, lower 16 are command for RA8875
    input logic read_in, write_in,

    //to MMIO
    output logic [31:0] MISO_out, //to internal registers
    output logic ack, // to memory handler
    
    //from RA8875
    input logic MISO_in,

    // to ra8875
    output logic chipSelect,
    output logic bitData,
    output logic sclk                                                                                                  
);

    typedef enum logic[2:0] { 
        IDLE = 0,
        SETUP = 1,
        SHIFT = 2,
        READ = 3,
        DELAY = 4
    } TFT_states;

    TFT_states state, next_state;

    logic reading_flag, next_reading_flag, delay_flag, next_delay_flag;
    logic [7:0] MISO_Reg, next_miso;
    logic [15:0] dataforOutput, next_data;

    logic [4:0] counter, next_ctr;

    logic [31:0] delayctr, next_delayctr;

    assign MISO_out = {24'b0, MISO_Reg};

    always_ff @(negedge nrst, posedge clk) begin
        if(~nrst) begin
            dataforOutput <= '0;
            counter <= 5'b0;
            state <= IDLE; 
            MISO_Reg <= '0;
            delayctr <= '0;
            reading_flag <= 0;
        end else begin
            dataforOutput <= next_data;
            state <= next_state;
            counter <= next_ctr;
            MISO_Reg <= next_miso;
            delayctr <= next_delayctr;
            reading_flag <= next_reading_flag;
            delay_flag <= next_delay_flag;
        end
    end

    always_comb begin
        case (state) 
            IDLE: begin 
                //SPI signals
                sclk = 1;
                bitData = 1;
                chipSelect = 1;

                //busy signal
                ack = 0;

                //internal signals
                next_data = 0;
                next_miso = MISO_Reg;
                next_ctr = 0;
                next_delayctr = 0;
                next_reading_flag = 0;
                next_delay_flag = 0;

                //next state logic
                if (write_in) begin
                    next_state = SETUP;
                end else if (read_in) begin
                    next_state = READ;
                end else begin
                    next_state = IDLE;
                end
            end 
            SETUP: begin 
                //SPI signals
                sclk = 1;
                bitData = 1;
                chipSelect = 1;

                //busy signal
                ack = 1;

                //internal signals
                next_ctr = 0;
                next_miso = MISO_Reg;

                next_data = MOSI_data[15:0];
                next_delayctr = {1'b0, MOSI_data[30:0]};

                if (MOSI_data[15:8] == 8'h40 && MOSI_data[31] != 1'b1) begin
                    next_reading_flag = 1;
                end else begin
                    next_reading_flag = 0;
                end

                if (MOSI_data[31] == 1'b1) begin
                    next_delay_flag = 1;
                end else begin
                    next_delay_flag = 0;
                end

                //next state logic
                if (MOSI_data[31] == 1'b1) begin
                    next_state = DELAY;
                end else begin
                    next_state = SHIFT;
                end

            end
            SHIFT: begin
                //SPI signals
                sclk = ~clk;
                bitData = dataforOutput[15];
                chipSelect = 0;

                //busy signal
                ack = 1;

                //internal signals
                next_data = {dataforOutput[14:0], 1'b0};
                next_ctr = counter + 1;
                next_delayctr = delayctr;
                next_reading_flag = reading_flag;
                next_delay_flag = delay_flag;

                if (reading_flag) begin
                    if (counter >= 5'd8 && counter <= 5'd16) begin
                        next_miso = {MISO_Reg[6:0], MISO_in};
                    end else begin
                        next_miso = MISO_Reg;
                    end
                end else begin
                    next_miso = MISO_Reg;
                end

                //next state logic
                if (counter <= 5'd15) begin
                    next_state = SHIFT;
                end else begin
                    next_state = IDLE;
                end
            end 

            READ: begin 
                //spi signals
                sclk = 1;
                bitData = 1;
                chipSelect = 1;

                //busy signals
                ack = 1; 

                //internal signals
                next_data = dataforOutput;
                next_ctr = counter;
                next_miso = MISO_Reg;
                next_delay_flag = delay_flag;
                next_reading_flag = reading_flag;
                next_delayctr = delayctr;

                //next state logic
                next_state = IDLE;
            end
            DELAY: begin
                //SPI signals
                sclk = 1;
                bitData = 1;
                chipSelect = 1;

                //busy signal
                ack = 1;

                //internal signals
                next_data = dataforOutput;
                next_ctr = 0;
                next_miso = MISO_Reg;
                next_delay_flag = delay_flag;
                next_reading_flag = 0;

                next_delayctr = delayctr - 1;

                //next state logic
                if (delayctr == 1) begin
                    next_state = IDLE;
                end else begin
                    next_state = DELAY;
                end
            end
            default: begin
                //SPI signals
                sclk = 1;
                bitData = 1;
                chipSelect = 1;

                //busy signal
                ack = 0;

                //internal signals
                next_data = dataforOutput;
                next_miso = MISO_Reg;
                next_ctr = 0;
                next_delayctr = 0;
                next_delay_flag = delay_flag;
                next_reading_flag = reading_flag;

                //next state logic
                next_state = IDLE;
            end
    endcase
end
endmodule
