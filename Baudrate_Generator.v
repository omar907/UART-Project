module Baudrate_Generator(bd_rate, clk, rst, TX_clk, RX_clk);

    parameter clk_speed = 50e6; // The speed of the clock of your FPGA in Hz (our FPGA is 50 MHz.)
    
    // the bit of the counter that is corresponding to the desited baud rate is given by this equation
    parameter [4:0] Tx_1200 = $floor( $clog2(clk_speed/1200) );     
    parameter [4:0] Tx_2400 = $floor( $clog2(clk_speed/2400) );
    parameter [4:0] Tx_4800 = $floor( $clog2(clk_speed/4800) );
    parameter [4:0] Tx_9600 = $floor( $clog2(clk_speed/9600) );
    
    input wire [1:0] bd_rate;
    input wire clk,rst;
    
    output wire TX_clk;
    output wire RX_clk;

// Signal declaration
reg [19:0] q;

always @(posedge clk,posedge rst) 
    if(rst) q <= 20'b11_111_111_111_111_111_111;    
    else    q <= q - 20'b1;

assign RX_clk = (bd_rate == 2'b00) ? q[19] :        // Baud-rate 1200 RX
                (bd_rate == 2'b01) ? q[18] :        // Baud-rate 2400 RX
                (bd_rate == 2'b10) ? q[17] :        // Baud-rate 4800 RX
                (bd_rate == 2'b11) ? q[16] : 2'bx;  // Baud-rate 9600 RX

assign TX_clk = (bd_rate == 2'b00) ? q[Tx_1200] :        // Baud-rate 1200 TX
                (bd_rate == 2'b01) ? q[Tx_2400] :        // Baud-rate 2400 TX
                (bd_rate == 2'b10) ? q[Tx_4800] :        // Baud-rate 4800 TX
                (bd_rate == 2'b11) ? q[Tx_9600] : 2'bx;  // Baud-rate 9600 TX
                                

endmodule