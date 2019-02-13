 module UART_Receiver
 #(      // FSMD parameters (states names)
    parameter [1:0]  
        idle  = 2'b00,
        start = 2'b01,
        stop  = 2'b10,
        transition = 2'b11
)
 (
    input wire din,
    input wire dnum,snum,
    input wire bd_rate,par,
    
    input clk,rst,
    
    output wire [7:0] data,
    output wire [2:0] error  //3 bit error (parity, overrun, frame error)
 );
 
 // signal declration
wire sample_tick;
reg qclk_reg;       // Sequential part for a clock counter
reg qclk_next;      // Compinational part for this counter
 
 
 
 // counter of the sampling tick ( every 16 clk > 1 sample tick )
always @(posedge clk, posedge rst)
begin    
    if(rst)
        qclk_reg <= 4'b0;
    else
        qclk_reg <= qclk_next; 
end

assign qclk_next = ( ( state == start && qclk_reg == 4'd7 )  ||
                                    (state != start && qclk_reg == 4'd15) ) ? 4'b0 :  qclk_reg + 4'b1;
                   
assign sample_tick = (state == start && qclk == 4'd7 || 
                             (state != start && qclk_reg == 4'd15) ) ? 1'b1 : 1'b0 ;
 
 
 endmodule