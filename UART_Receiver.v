 module UART_Receiver
 #(      // FSMD parameters (states names)
    parameter [1:0]  
        idle  = 2'b00,
        receiving = 2'b01,
        wait_stop  = 2'b10,
        stop = 2'b11
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
reg  sample_trigger;
reg [1:0] state;
reg [1:0] next_state;
reg qclk_reg;       // Sequential part for a clock counter
reg qclk_next;      // Compinational part for this counter
reg [3:0] r;    // Sequential counter
reg [3:0] r_next;
reg [8:0] data_reg; // A regester to store the received data in 
reg data_flag;  // A flag to detect that the data is received correctly
reg error_reg; 
 
 // Counter of the sampling tick ( every 16 clk > 1 sample tick )
always @(posedge clk, posedge rst)
begin    
    if(rst)
    begin
        qclk_reg <= 4'b0;
        sample_16 <= 1'b0;
    end
    else
    begin
        qclk_reg <= qclk_next;
        if(q_reg == 4'd7)   sample_16 = 1'b1; 
    end
end

assign qclk_next = ( ( sample_16 == 1'b0 && qclk_reg == 4'd7 )  ||
                                 (sample_16 == 1'b1 && qclk_reg == 4'd15) ) ? 4'b0 :  qclk_reg + 4'b1;
                   
assign sample_tick = ( sample_16 == 1'b0 && qclk == 4'd7 || 
                                 ( sample_16 == 1'b1 && qclk_reg == 4'd15 ) ) ? 1'b1 : 1'b0;

//FSMD state and data registers sequantial circuit
always @(posedge clk, posedge rst)
begin
    if(rst)
    begin
        state <= 4'b0;
        q_reg <= 4'b0;
        data_reg <= 9'b0;
    end
    else if(sample_tick)
    begin
        state <= next_state;
        q_reg <= q_next;
        if(state == receiving)
        begin
            data_reg <= data_reg >> 1;
            data_reg[8] <= din;
        end
    end
end


//Control path of the FSMD ... next statte logic(combinational part of the FSM)
always @(*)
begin
    case(state)
    idle: if(din)  next_state = idle;
          else     next_state = receiving;
          
    receiving : if(r == 4'b0) 
                case(snum)
                1'b0 : next_state = stop;
                1'b1 : next_state = wait_stop;
                endcase
                else next_state = receiving;
                
    wait_stop : if(din) next_state = stop;
                else    next_state = idle;
                
    stop : next_state = idle;
    
    endcase    
end
 
 
 
 endmodule