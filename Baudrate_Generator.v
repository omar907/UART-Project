module Baudrate_Generator(

    input wire [1:0] bd_rate,
    input wire clk,rst,
    
    output wire TX_clk,
    output wire RX_clk
);

// Signal declaration
reg [16:0] q;

always @(posedge clk,posedge rst) 
    if(rst) q <= 17'b11_111_111_111_111_111;    
    else    q <= q - 1'b1;

assign RX_clk = (bd_rate == 2'b00) ? q[16] :        // Baud-rate 1200 RX
                (bd_rate == 2'b01) ? q[15] :        // Baud-rate 2400 RX
                (bd_rate == 2'b10) ? q[14] :        // Baud-rate 4800 RX
                (bd_rate == 2'b11) ? q[13] : 2'bx;  // Baud-rate 9600 RX

assign TX_clk = (bd_rate == 2'b00) ? q[12] :        // Baud-rate 1200 TX
                (bd_rate == 2'b01) ? q[11] :        // Baud-rate 2400 TX
                (bd_rate == 2'b10) ? q[10] :        // Baud-rate 4800 TX
                (bd_rate == 2'b11) ? q[ 9] : 2'bx;  // Baud-rate 9600 TX
                                

endmodule