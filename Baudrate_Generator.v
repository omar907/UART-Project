module Baudrate_Generator(bd_rate, clk, rst, TX_clk, RX_clk);
    
    input wire [1:0] bd_rate;
    input wire clk,rst;
    
    output wire TX_clk;
    output wire RX_clk;

// Signal declaration
reg [19:0] q;

always @(posedge clk,posedge rst)
begin
    if(rst) q <= 20'b111_111_111_111_111_111_111_111;    
    else    q <= q - 20'b1;
end

assign RX_clk = (bd_rate == 2'b00) ? q[19] :        // Baud-rate 1200 RX
                (bd_rate == 2'b01) ? q[18] :        // Baud-rate 2400 RX
                (bd_rate == 2'b10) ? q[17] :        // Baud-rate 4800 RX
                (bd_rate == 2'b11) ? q[16] : 2'bx;  // Baud-rate 9600 RX

assign TX_clk = (bd_rate == 2'b00) ? q[15] :        // Baud-rate 1200 TX
                (bd_rate == 2'b01) ? q[14] :        // Baud-rate 2400 TX
                (bd_rate == 2'b10) ? q[13] :        // Baud-rate 4800 TX
                (bd_rate == 2'b11) ? q[12] : 2'bx;  // Baud-rate 9600 TX
                                

endmodule