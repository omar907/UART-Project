module UART_Transmitter
#(      // FSMD parameters (states names)
    parameter [1:0]  
        idle = 2'b00,
        sending = 2'b01,
        stop = 2'b10,
        transition = 2'b11
)
( data,start,dnum,snum,par,clk,rst,dout
    );
input wire [7:0] data;  // The temperature data to be send to the Receiver
input wire start;       // Start sending the data (flag)
input wire dnum,snum;   // number of data/stop bits
input wire [1:0] par;   // bode_rate/type of parity
input wire clk,rst;     // Clock/reset
    
output wire dout ;       // One bit output (data shifted serialy)


// declaring signals
reg [8:0] data_reg;
reg [8:0] data_reg_next;
reg dout_next;
reg dout_reg;   
reg [1:0] state; //sequential part of the FSMD
reg [1:0] next_state;  // combinational part of the FSMD
reg [3:0] q;   // sequential counter
reg [3:0] q_next; 
reg parity_bit;

//FSMD state and data registers sequantial circuit
always @(posedge clk,posedge rst)
begin
    if(rst)
    begin
        state <= idle;
        data_reg <= 8'b0;
        dout_reg <= 1'b1;
        q <= 4'b0;
    end
    else
    begin
        state <= next_state;
        dout_reg <= dout_next;
        q <= q_next;
        data_reg <= data_reg_next;
    end
end

//Control path of the FSMD ... next statte logic(combinational part of the FSM)
always @(*)
begin
    // next state logic 
    case(state)
    idle:     if(start) next_state = sending;
              else next_state = idle;
        
    sending:  if(q == 4'b0) next_state = stop;
              else next_state = sending;
    
    stop:     if(snum)          next_state = transition;
              else if(~start)   next_state = idle;
              else              next_state = stop; 
                
  transition: if(~start) next_state = idle;
              else       next_state = transition; 
    endcase
end


//Data path of the FSMD ... next data logic
always @(*)
begin
    // next data logic 
    case(state)
    idle:
    begin
        if(start)                                                                                        
        begin                                                                                            
            dout_next = 1'b0;                                                                            
                                                                                                         
            case(par)                                                                                    
            2'b00,2'b11 :                                                                                
            begin                                                                                        
                case(dnum)
                1'b1: q_next = 4'd8;   // no parity + 8-bit data                                      
                1'b0: q_next = 4'd7;   // no parity + 7-bit data
                endcase                                      
                parity_bit = 1'b0;                                                                       
            end                                                                                          
                                                                                                         
            2'b01 :                                                                                      
            begin                                                                                        
                case(dnum)                                                                               
                1'b1:  begin parity_bit = (^data);      q_next = 4'd9; end  //odd parity +  8-bit data   
                1'b0:  begin parity_bit = (^data[6:0]); q_next = 4'd8; end  //odd parity +  7-bit data   
                endcase                                                                                  
            end                                                                                          
                                                                                                         
            2'b10 :                                                                                      
            begin                                                                                        
                case(dnum)                                                                               
                1'b1:  begin parity_bit = (~^data);      q_next = 4'd9; end  //even parity +  8-bit data 
                1'b0:  begin parity_bit = (~^data[6:0]); q_next = 4'd8; end  //even parity +  7-bit data 
                endcase                                                                                  
            end                                                                                          
            endcase                                                                                      
                                                                                                         
            case(dnum)                                                                                   
            1'b1:  data_reg_next = {parity_bit,data};    //parity + data                                               
            1'b0:  data_reg_next = {1'b0,parity_bit,data[6:0]};  // 0 in the 9th bit + parity + data                                
            endcase                                                                                          
        end
        else
        begin
        // like the reset conditions
            dout_next = 1'b1;
            parity_bit = 1'b0;          
            q_next = 4'b0;
            data_reg_next = 9'b0;
        end
    end
    
    sending:
    begin
        if(q == 4'b0) dout_next = 1'b1;
        else   dout_next = data_reg[0];
        q_next = q - 4'b1;      // decrementing the counter
        data_reg_next = data_reg >> 1;  //shift the data one by one with ever clock
    end
    
    default:
    begin
        // reseting conditions
        dout_next = 1'b1;
        parity_bit = 1'b0;
        q_next = 4'b0;
        data_reg_next = 9'b0;
    end
    endcase
end


assign dout = dout_reg;


endmodule