`default_nettype none
`timescale 1ps/1ps

module t03_dpuxmmio(
    input logic [31:0] addr, data,
    input logic clk,rst,
    output logic [2:0]  gameState,
    output logic [1:0]  p1State,p2State,
    output logic [3:0] p1health, p2health,
    output logic [10:0] x1,x2,y1,y2,
    output logic p1Left, p2Left
);

logic [2:0]  n_gameState;
logic [1:0]  n_p1State, n_p2State;
logic [3:0]  n_p1health, n_p2health;
logic [10:0]  n_x1, n_x2, n_y1, n_y2;
logic n_p2Left, n_p1Left;

always_ff @(posedge clk, posedge rst)  begin
    if (rst) begin
        gameState <= 3'b00; // init state (could change)
        p1State   <= 2'b00; // init state
        p2State   <= 2'b00;
        p1health  <= 4'd0;
        p2health  <= 4'd0;
        x1        <= '0;
        x2        <= '0;
        y1        <= '0;
        y2        <= '0; 
    end else 
    begin
        gameState <= n_gameState;
        p1State   <= n_p1State;
        p2State   <= n_p2State;
        p1health  <= n_p1health;
        p2health  <= n_p2health;
        x1        <= n_x1;
        x2        <= n_x2;
        y1        <= n_y1;
        y2        <= n_y2;
        p1Left <= n_p1Left;
        p2Left <= n_p2Left;
    end
end

always@(*) begin
    n_x1 = x1;
    n_x2 = x2;
    n_y1 = y1;
    n_y2 = y2;
    n_gameState = gameState;
    n_p1State = p1State;
    n_p2State = p2State;
    n_p1health = p1health;
    n_p2health = p2health;
    n_p1Left = p1Left;
    n_p2Left = p2Left;
    case(addr)
        32'hFF000004: begin
            n_gameState = data[30:28];
            n_p1State = data[27:26];
            n_p2State = data[25:24];
            n_p1health = data[23:20];
            n_p2health = data[19:16];
            n_p1Left = data[1];
            n_p2Left = data[0];
        end
        32'hFF000008: begin
            n_x1 = {3'b000,data[31:24]};
            n_y1 = {3'b000,data[23:16]};
            n_x2 = {3'b000,data[15:8]};
            n_y2 = {3'b000,data[7:0]};
        end
    endcase
end


endmodule