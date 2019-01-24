module arbiter(
    input CLK,SCLR,
    input [3:0]REQ,
    input ACK,
    output reg [3:0]GRANT
);

    localparam  IDLE = 3'd0,            
                GNT0 = 3'd1,
                GNT1 = 3'd2,
                GNT2 = 3'd3,
                GNT3 = 3'd4;
    reg [2:0]ps,ns;
    reg [1:0]count;
    reg time_out;

    //Time out signal generator --BEGIN
    always @(posedge CLK) begin
        if(SCLR) begin
            count <= 0;
            time_out <= 0;
        end else if (count == 2'b11) begin
            count <= 0;
            time_out <= 1;
        end else begin
            count <= count + 1;
            time_out <= 0;
        end
    end
    //Time out signal generator --END

    //ARBITER FSM --BEGIN
    always @(posedge CLK) begin
        if(SCLR)
            ps <= IDLE;
        else 
            ps <= ns;
    end
    //State transition
    always @(ps,REQ,time_out,ACK) begin
        case(ps)
            IDLE    :   begin
                            if(REQ[0])        ns <= GNT0;
                            else if(REQ[1])   ns <= GNT1;
                            else if(REQ[2])   ns <= GNT2;
                            else if(REQ[3])   ns <= GNT3;
                            else                ns <= IDLE;
                        end
            GNT0    :   begin
                            if(time_out || ACK) begin
                                if(REQ[1])        ns <= GNT1;
                                else if(REQ[2])   ns <= GNT2;
                                else if(REQ[3])   ns <= GNT3;
                                else if(REQ[0])   ns <= GNT0;
                                else                ns <= IDLE;
                            end else                ns <= GNT0;
                        end
            GNT1    :   begin
                            if(time_out || ACK) begin
                                if(REQ[2])        ns <= GNT2;
                                else if(REQ[3])   ns <= GNT3;
                                else if(REQ[0])   ns <= GNT0;
                                else if(REQ[1])   ns <= GNT1;
                                else                ns <= IDLE;
                            end else                ns <= GNT1;
                        end
            GNT2    :   begin
                            if(time_out || ACK) begin
                                if(REQ[3])        ns <= GNT3;
                                else if(REQ[0])   ns <= GNT0;
                                else if(REQ[1])   ns <= GNT1;
                                else if(REQ[2])   ns <= GNT2;
                                else                ns <= IDLE;
                            end else                ns <= GNT2;
                        end
            GNT3    :   begin
                            if(time_out || ACK) begin
                                if(REQ[0])        ns <= GNT0;
                                else if(REQ[1])   ns <= GNT1;
                                else if(REQ[2])   ns <= GNT2;
                                else if(REQ[3])   ns <= GNT3;
                                else                ns <= IDLE;
                            end else                ns <= GNT3;
                        end
            default :   begin
                            ns <= IDLE;
                        end
        endcase
    end
    //Output
    always @(ps) begin
        case(ps)
            IDLE    :   GRANT = 4'h0;
            GNT0    :   GRANT = 4'h1;
            GNT1    :   GRANT = 4'h2;
            GNT2    :   GRANT = 4'h4;
            GNT3    :   GRANT = 4'h8;
            default :   GRANT = 4'h0;
        endcase
    end
    //ARBITER FSM --END

endmodule