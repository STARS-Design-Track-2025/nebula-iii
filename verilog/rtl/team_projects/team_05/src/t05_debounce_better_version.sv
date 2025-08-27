
module t05_debounce_better_version(
    input logic pb_1,clk,
    output logic pb_out
    );
    logic slow_clk_en;
    logic [2:0] D, Q;
    // wire Q1,Q2,Q2_bar,Q0;
    // clock_enable u1(clk,slow_clk_en);
    
    // my_dff_en d0(clk,slow_clk_en,pb_1,Q0);
    assign D[0] = pb_1;
    // my_dff_en d1(clk,slow_clk_en,Q0,Q1);
    assign D[1] = Q[0];
    // my_dff_en d2(clk,slow_clk_en,Q1,Q2);
    assign D[2] = Q[1];
    
    assign pb_out = Q[1] & ~Q[2];

    //moved inside single module
    logic [26:0]counter=0;
    always_ff @(posedge clk) begin
       counter <= (counter>=249999)?0:counter+1;
    end
    
    assign slow_clk_en = (counter == 249999)?1'b1:1'b0;
    
    always_ff @ (posedge clk) begin
        if(slow_clk_en==1) begin
           Q <= D;
        end
    end
endmodule



// Slow clock enable for debouncing button 
//  FPGA4schools
// module clock_enable(input Clk_100M,output slow_clk_en);
//     reg [26:0]counter=0;
//     always @(posedge Clk_100M)
//     begin
//        counter <= (counter>=249999)?0:counter+1;
//     end

//     assign slow_clk_en = (counter == 249999)?1'b1:1'b0;
// endmodule

// D-flip-flop with clock enable signal for debouncing module 
// module my_dff_en(input DFF_CLOCK, clock_enable,D, output reg Q=0);
//     always @ (posedge DFF_CLOCK) begin
//   if(clock_enable==1) 
//            Q <= D;
//     end
// endmodule 
