module tb_arbiter;

//Inputs
reg CLK,SCLR;
reg [3:0]REQ;
reg ACK;
//Outputs
wire [3:0]GRANT;

//UUT
arbiter uut(
    .CLK(CLK),
    .SCLR(SCLR),
    .REQ(REQ),
    .ACK(ACK),
    .GRANT(GRANT)
);

//Clock Defination --BEGIN
localparam TimePeriod = 10;
initial CLK = 0;
always #(TimePeriod/2) CLK = ~CLK;
//Clock Defination --END

//Simulation Time
localparam SIMEND = 130*TimePeriod;

//Stimulu   --BEGIN
//Reset Cycle
initial begin
    SCLR = 0;
    REQ = 4'd0;
    ACK = 4'd0;
    @(posedge CLK) SCLR = 0;
    @(posedge CLK) SCLR = 1;
    @(posedge CLK) SCLR = 0;
end
//Random Request Inputs
initial begin
    repeat(400)
    @(posedge CLK)  REQ = $random;
end
//Random ACK Signal
initial begin
    repeat(100) begin
        repeat(4)
            @(posedge CLK);
        ACK = $random;
    end
end
initial
    #SIMEND $stop;
//Stimulu   --END

//Monitor
initial
    $monitor($time,"REQ = %b, ACK = %b, GRANT = %b",REQ,ACK,GRANT);

endmodule // tb_arbiter