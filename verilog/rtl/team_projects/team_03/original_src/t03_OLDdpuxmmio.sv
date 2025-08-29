`default_nettype none
`timescale 1ms/10ps

module t03_OLDdpuxmmio(
    input logic [31:0] addr, data, //in from mmio
    input logic clk,rst,
    output logic [1:0] gameState, p1State, p2State,
    output logic [4:0] p1health, p2health,
    output logic [10:0] x1,x2,y1,y2
);

logic [1:0]  n_gameState, n_p1State, n_p2State;
logic [4:0]  n_p1health, n_p2health;
logic [10:0]  n_x1, n_x2, n_y1, n_y2;

always_ff @(posedge clk, posedge rst)  begin
    if (rst) begin
        gameState <= 2'b00; // init state (could change)
        p1State   <= 2'b00; // init state
        p2State   <= 2'b00;
        p1health  <= 5'd0;
        p2health  <= 5'd0;
        x1        <= '0;
        x2        <= '0;
        y1        <= '0;
        y2        <= '0; 
    end else begin
        gameState <= n_gameState;
        p1State   <= n_p1State;
        p2State   <= n_p2State;
        p1health  <= n_p1health;
        p2health  <= n_p2health;
        x1        <= n_x1;
        x2        <= n_x2;
        y1        <= n_y1;
        y2        <= n_y2;
    end
end

always @ (*) begin //Using an always statement because icarus Verilog throws an error here
    case(addr)
        32'hFF000003: begin
            n_gameState = data[15:14];
            n_p1State = data[13:12];
            n_p2State = data[11:10];
            n_p1health = data[9:5];
            n_p2health = data[4:0];
            n_x1 = x1;
            n_x2 = x2;
            n_y1 = y1;
            n_y2 = y2;
        end
        32'hFF000004: begin
            n_gameState = gameState;
            n_p1State = p1State;
            n_p2State = p2State;
            n_p1health = p1health;
            n_p2health = p2health;
            n_x1 = {3'b000,data[31:24]};
            n_x2 = {3'b000,data[23:16]};
            n_y1 = {3'b000,data[15:8]};
            n_y2 = {3'b000,data[7:0]};
        end
        default: begin
            n_gameState = gameState;
            n_p1State = p1State;
            n_p2State = p2State;
            n_p1health = p1health;
            n_p2health = p2health;
            n_x1 = x1;
            n_x2 = x2;
            n_y1 = y1;
            n_y2 = y2;
        end
    endcase
end


endmodule