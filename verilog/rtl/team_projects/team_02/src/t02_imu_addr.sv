`default_nettype none
module t02_imu_addr(
    input logic hz100, clk_en, n_rst, sdo, en, filter_ready,
    output logic cs, sdi, sclk, data_ready,
    output logic [79:0] data_out 
    // output logic [4:0] state_out,
    // output logic [79:0] rx_data_out,
    // output logic [87:0] tx_data_out,
    // output logic [6:0] bit_count_out
    // output addr_state_t state,
    // output logic [6:0] bit_count,
    // output logic [87:0] tx_data
); 

typedef enum logic [4:0] {
    IDLE_TEST       = 0,
    POWER_RESET     = 1,
    CS_WAIT_1       = 2,
    ENABLE_SENSORS  = 3,
    CS_WAIT_2       = 4,
    SEL_BANK_2      = 5,
    CS_WAIT_3       = 6,
    CONFIG_GYRO     = 7,
    CS_WAIT_4       = 8,
    CONFIG_ACCEL    = 9,
    CS_WAIT_5       = 10,
    READ_ACCEL_CONFIG = 11,
    CS_WAIT_6       = 12,
    SEL_BANK_0      = 13,
    CS_WAIT_7       = 14,
    WHO_AM_I        = 15,
    CS_WAIT_8       = 16,
    BURST_READ      = 17,
    FILTER_WAIT     = 18,
    DATA_OUT        = 19,
    BUFFER          = 20
} addr_state_t;
    logic sclk_en;

    logic [16:0] counter; 

    // assign state_out = state;


    // assign rx_data_out = rx_data;
    // assign tx_data_out = tx_data;


    always_ff @(posedge hz100 or negedge n_rst) begin
        if (!n_rst) begin
            counter <= 0;
            sclk_en <= 0;
        end else begin
            // Default assignment
            sclk_en <= 0;
            
            // Count to 11,999 (0-11,999 = 12,000 cycles for 12MHz/1kHz)
            if (counter == 17'd2999) begin
                counter <= 0;
                sclk_en <= 1; // Single-cycle enable pulse
            end else begin
                counter <= counter + 1;
            end
        end
    end

    always_ff @ (negedge hz100, negedge n_rst) begin
        if (~n_rst) begin
            sclk <= 1'b0;
        end else if (cs) begin
            sclk <= 1'b0;
        end else if (~cs && sclk_en) begin
            sclk <= ~sclk;
        end
    end

    // assign sclk = ~cs ? hz100 : 1'b0;


    // Internal signals for next state logic
    logic [87:0] tx_data, next_tx_data;
    logic [79:0] rx_data, next_rx_data, next_data_out;
    logic [19:0] wait_counter, next_wait_counter;
    addr_state_t state, next_state;
    logic [6:0] bit_count, next_bit_count;
    logic next_cs;

    // assign bit_count_out = bit_count;
    // logic next_sclk;

    // SPI Protocol: 
    // - Data shifts out on negative edge of sclk (when sclk goes low)
    // - Data latches in on positive edge of sclk (when sclk goes high)
    // - This follows SPI Mode 0: CPOL=0, CPHA=0

    // Combinational logic for SPI signals
    assign sdi = (~cs) ? tx_data[87] : 1'b1;  // Always send MSB of shift_reg
    // assign sclk = ~cs && hz100;

    // assign sclk = next_sclk;
    
    // Registered signals - all updates happen in always_ff blocks
    always_ff @(negedge hz100, negedge n_rst) begin
        if (~n_rst) begin
            state <= IDLE_TEST;
            cs <= 1'b1;
            wait_counter <= 20'b0;
            data_out <= 80'b0;
            tx_data <= {8'h06, 8'h01, 72'h00};
            bit_count <= 7'b0;
            // tx_data <= {8'h06, 8'h01, 8'h00};
        end else  if (clk_en) begin
            state <= next_state;
            cs <= next_cs;
            wait_counter <= next_wait_counter;
            data_out <= next_data_out;
            tx_data <= next_tx_data; // Shift on each negedge
            bit_count <= next_bit_count;
            // tx_data <= next_tx_data;
        end
    end

    // RX data latches on positive edge (when sclk goes high)
    always_ff @(posedge hz100, negedge n_rst) begin
        if (~n_rst) begin
            rx_data <= 80'b0;
        end else if (clk_en) begin
            rx_data <= next_rx_data;
        end
    end

    
    // Combinational logic for next state and control signals
    always_comb begin
        // Default assignments
        next_tx_data = tx_data;
        next_state = state;
        next_bit_count = bit_count;
        next_cs = cs;
        next_wait_counter = wait_counter;
        next_rx_data = rx_data;
        next_data_out = data_out;
        data_ready = 1'b0;
        // next_sclk = (~cs) ? clk : 1'b0;  // Clock only when CS is active
        
        case (state)
            IDLE_TEST: begin
                next_bit_count = 7'b0;
                next_tx_data = {8'h06, 8'h01, 72'h00};  // Set bank 0
                if (en) begin
                    next_state = POWER_RESET;
                    next_cs = 1'b0;              
                end
            end
            
            POWER_RESET: begin
                next_bit_count = bit_count + 1;
                next_tx_data = {tx_data[86:0], 1'b0};  // Shift left
                if (bit_count >= 7'd15) begin  // 16 bits transmitted
                    next_bit_count = 7'b0;
                    next_state = CS_WAIT_1;
                    next_cs = 1'b1;
                end
            end

            CS_WAIT_1: begin
                next_tx_data = {8'h07, 80'h00};
                next_state = ENABLE_SENSORS;
                next_cs = 1'b0;
            end

            ENABLE_SENSORS: begin
                next_bit_count = bit_count + 1;
                next_tx_data = {tx_data[86:0], 1'b0};
                if (bit_count >= 7'd15) begin
                    next_bit_count = 7'b0;
                    next_state = CS_WAIT_2;
                    next_cs = 1'b1;
                end
            end

            CS_WAIT_2: begin
                next_tx_data = {8'h7f, 8'h20, 72'h00};
                next_state = SEL_BANK_2;
                next_cs = 1'b0;
            end
            SEL_BANK_2: begin
                next_bit_count = bit_count + 1;
                next_tx_data = {tx_data[86:0], 1'b0};
                if (bit_count >= 7'd15) begin
                    next_bit_count = 7'b0;
                    next_state = CS_WAIT_3;
                    next_cs = 1'b1;
                end
            end
            CS_WAIT_3: begin
                next_tx_data = {8'h01, 8'h03, 72'h00};
                next_state = CONFIG_GYRO;
                next_cs = 1'b0;
            end
            CONFIG_GYRO: begin
                next_bit_count = bit_count + 1;
                next_tx_data = {tx_data[86:0], 1'b0};
                if (bit_count >= 7'd15) begin
                    next_bit_count = 7'b0;
                    next_state = CS_WAIT_4;
                    next_cs = 1'b1;
                end
            end
            CS_WAIT_4: begin
                next_tx_data = {8'h14, 8'h33, 72'h00};
                next_state = CONFIG_ACCEL;
                next_cs = 1'b0;
            end
            CONFIG_ACCEL: begin
                next_bit_count = bit_count + 1;
                next_tx_data = {tx_data[86:0], 1'b0};
                if (bit_count >= 7'd15) begin
                    next_bit_count = 7'b0;
                    next_state = CS_WAIT_5;
                    next_cs = 1'b1;
                end
            end
            CS_WAIT_5: begin
                next_tx_data = {8'h94, 80'h00};
                next_state = READ_ACCEL_CONFIG;
                next_cs = 1'b0;
            end
            READ_ACCEL_CONFIG: begin
                next_bit_count = bit_count + 1;
                next_tx_data = {tx_data[86:0], 1'b0};

                if (bit_count >= 7'd15) begin
                    next_bit_count = 7'b0;
                    next_state = CS_WAIT_6;
                    next_cs = 1'b1;
                end
            end
            CS_WAIT_6: begin
                next_tx_data = {8'h7f, 8'h00, 72'h00};
                next_state = SEL_BANK_0;
                next_cs = 1'b0;
            end
            SEL_BANK_0: begin
                next_bit_count = bit_count + 1;
                next_tx_data = {tx_data[86:0], 1'b0};
                if (bit_count >= 7'd15) begin
                    next_bit_count = 7'b0;
                    next_state = CS_WAIT_7;
                    next_cs = 1'b1;
                end
            end
            CS_WAIT_7: begin
                next_tx_data = {8'h80, 80'h00};
                // if (en) begin
                next_state = WHO_AM_I;
                next_cs = 1'b0;  
                // end
                // next_tx_data = {8'h80, 8'h00, 8'h00};  // PWR_MGMT_1, device reset

            end
            
            WHO_AM_I: begin
                next_bit_count = bit_count + 1;
                next_tx_data = {tx_data[86:0], 1'b0};

                if (bit_count >= 7'd8 && bit_count <= 7'd23) begin
                    next_rx_data = {rx_data[78:0], sdo};
                end

                if (bit_count > 7'd23) begin
                    next_bit_count = 7'b0;
                    next_state = CS_WAIT_8;
                    next_cs = 1'b1;
                end
            end

            CS_WAIT_8: begin
                next_tx_data = {8'hAD, 80'h0};
                // next_data_ready = 1'b0;
                // next_bit_count = 7'b0;
                // if (en) begin
                next_state = BURST_READ;
                next_cs = 1'b0;
                // end
            end

            BURST_READ: begin
                next_bit_count = bit_count + 1;
                next_tx_data = {tx_data[86:0], 1'b0};

                if (bit_count >= 7'd8 && bit_count < 7'd88) begin
                    next_rx_data = {rx_data[78:0], sdo};
                end
                if (bit_count >= 7'd88) begin
                    next_state = FILTER_WAIT;
                    next_cs = 1'b1;
                    next_bit_count = 7'b0;
                end
            end

            // BUFFER: begin
            //     next_state = en ?  : BUFFER;
            // end

            FILTER_WAIT: begin
                if (filter_ready) begin
                    next_state = DATA_OUT;
                    next_data_out = rx_data;
                    // next_data_ready = 1'b1;
                end
            end

            DATA_OUT: begin
                next_state = CS_WAIT_8;
                data_ready = 1'b1;
            end

            
            default: begin
                // Keep all signals at current values
            end
        endcase 
    end

endmodule