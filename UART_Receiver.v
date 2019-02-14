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
    input wire [1:0] bd_rate,par,
    
    input clk,rst,
    
    output wire [7:0] data,
    output wire error  //1 bit error (parity, overrun, frame error)
 );
 
 // signal declration
wire sample_tick;
reg  sample_16;
reg  [1:0] state;
reg  [1:0] next_state;
reg  [3:0] qclk_reg;       // Sequential part for a clock counter
wire [3:0] qclk_next;      // Compinational part for this counter
reg  [3:0] r;    // Sequential counter
reg  [3:0] r_next;
reg  [8:0] data_reg; // A regester to store the received data in 
reg  data_flag;  // A flag to detect that the data is received correctly
reg  error_reg;
 
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
        if( qclk_reg == 4'd7 )   sample_16 = 1'b1; 
    end
end

assign qclk_next = ( ( sample_16 == 1'b0 && qclk_reg == 4'd7 )  ||
                                 (sample_16 == 1'b1 && qclk_reg == 4'd15) ) ? 4'b0 :  qclk_reg + 4'b1;
                   
assign sample_tick = ( sample_16 == 1'b0 && qclk_reg == 4'd7 || 
                                 ( sample_16 == 1'b1 && qclk_reg == 4'd15 ) ) ? 1'b1 : 1'b0;

//FSMD state and data registers sequantial circuit
always @(posedge clk, posedge rst)
begin
    if(rst)
    begin
        state <= 4'b0;
        r <= 4'b0;
        data_reg <= 9'b0;
    end
    else if(sample_tick)
    begin
        state <= next_state;
            r <= r_next;
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
          
    receiving : if(r == 4'b1) 
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
 
 
 //Data path of the FSMD ... next data logic
always @(*)
begin
    // next data logic
    case(state)
    idle :
    begin
        data_flag = 1'b0;
        error_reg = 1'b0;
        if(~din)
        begin
            case(par)                                                                                    
            'b00,2'b11 :                                                                                
             begin                                                                                        
                 if(dnum) r_next = 4'd8;   // no parity + 8-bit data                                      
                 else     r_next = 4'd7;   // no parity + 7-bit data                                                                                                          
             end                                                                                          
                                                                                                          
             2'b01 :                                                                                      
             begin                                                                                        
                 case(dnum)                                                                               
                 1'b1:  r_next = 4'd9; //odd parity +  8-bit data   
                 1'b0:  r_next = 4'd8; //odd parity +  7-bit data   
                 endcase                                                                                  
             end                                                                                          
                                                                                                          
             2'b10 :                                                                                      
             begin                                                                                        
                 case(dnum)                                                                               
                 1'b1:  r_next = 4'd9;  //even parity +  8-bit data 
                 1'b0:  r_next = 4'd8;  //even parity +  7-bit data 
                 endcase                                                                                  
             end                                                                                    
             endcase                                                                                      
        end                                      
        else
        begin
        // like the reset conditions     
            r_next = 4'b0;
        end
    end
    
    receiving: 
    begin 
        r_next = r - 4'b1;  // decrementing the counter 
        data_flag = 1'b0; 
        error_reg = 1'b0;
    end 
                   
                     
    wait_stop:  
    begin
                r_next = 4'b0;
                data_flag = 1'b0;                 
                if(din) error_reg = 1'b0;
                else    error_reg = 1'b1;
    end
                
    stop:   
    begin
        r_next = 4'b0;
        if(~din) begin error_reg = 1'b1; data_flag =1'b0; end
        else
        begin
            if(dnum)
            begin
                case(par)
                2'b01 : if( data_reg[8] !=  ^(data_reg[7:0]) ) begin error_reg = 1'b1; data_flag =1'b0; end
                        else begin error_reg = 1'b0; data_flag =1'b1; end
                2'b10 : if( data_reg[8] != ~^(data_reg[7:0]) ) begin error_reg = 1'b1; data_flag =1'b0; end
                        else begin error_reg = 1'b0; data_flag =1'b1; end
                default : begin error_reg = 1'b0; data_flag = 1'b1; end
                endcase
            end
            else
            begin
                case(par)
                2'b01 : if( data_reg[8] !=  ^(data_reg[7:1]) )  begin error_reg = 1'b1; data_flag =1'b0; end
                        else begin error_reg = 1'b0; data_flag =1'b1; end
                2'b10 : if( data_reg[8] != ~^(data_reg[7:1]) )  begin error_reg = 1'b1; data_flag =1'b0; end
                        else begin error_reg = 1'b0; data_flag =1'b1; end
                default : begin error_reg = 1'b0; data_flag =1'b1; end
                endcase
            end
        end
    end
    endcase     
end
        
assign error = error_reg;

assign data = ( dnum && data_flag) ?    data_reg[7:0]     :
              (~dnum && data_flag) ? {1'b0,data_reg[7:1]} : 8'b0;
    

 endmodule