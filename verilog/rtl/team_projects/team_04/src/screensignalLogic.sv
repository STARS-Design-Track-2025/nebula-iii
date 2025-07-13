module screensignalLogic (
    input logic [31:0] controlBus, coordBus,
    input logic [17:0] ct,
    output logic ack, dcx, wrx, csx,
    output logic [7:0] data  
);

logic [7:0] nextData, currentData;
logic nextDcx, nextCsx, nextWrx, currentDcx, currentCsx, currentWrx;
logic [9:0] control;

assign control = controlBus[9:0];
//assign clearCommand

// clear x y on off r g b bl wh

always_comb begin

    nextData = currentData;
    nextCsx = currentCsx;
    nextWrx = currentWrx;
    nextDcx = currentDcx;
    ack = 0;

    case (control)
        10'b1000000000: begin //clear
            case (ct)
                0: begin 
                    nextWrx = 1;
                    nextDcx = 1;
                    nextCsx = 1;
                    nextData = 0;
                end
                1: begin
                    nextCsx = 0;
                end
                2: begin
                    nextDcx = 0;
                    nextWrx = 0;
                    nextData = clearCommand;
                end
                3: begin
                    nextWrx = 1;
                end
                4: begin
                    nextCsx = 1;
                end
                200000: begin
                    ack = 1;
                end
            endcase
        end
    endcase
    




endmodule