module UART_Transmitter
#(      // FSMD parameters
    parameter [1:0]
        idle = 2'b00,
        sending = 2'b01,
        stop = 2'b10,
        transition = 2'b11
)
(
    output wire dout,
    input wire [7:0] data,
    input wire start,
    input wire dnum,snum,
    input wire [1:0] bd_rate,par,
    input wire clk,rst,en
);


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
        dout_reg <= 1'b0;
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
    // default values
    next_state = next_state;
    
    // next state logic 
    case(state)
    idle:     if(start) next_state = sending;
        
    sending:  if(q == 4'b0) next_state = stop;
    
    stop:     if(snum) next_state = transition;
              else    next_state = idle;
                
  transition: if(start) next_state = sending;
              else next_state = idle;    
    endcase
end


//Data path of the FSMD ... next data logic
always @(*)
begin
    // default values
    dout_next = dout_next;
    q_next = q_next;
    data_reg_next = data_reg_next;
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
                if(dnum) q_next = 4'd8;   // no parity + 8-bit data
                else     q_next = 4'd7;   // no parity + 7-bit data
                parity_bit = 1'b0;
            end
                          
            2'b01 :
            begin 
                if(dnum)    q_next = 4'd9;  //odd parity +  8-bit data
                else        q_next = 4'd8;  //odd parity +  7-bit data
                parity_bit = (^data);
            end
                    
            2'b10 :
            begin
                if(dnum)    q_next = 4'd9;  //even parity +  8-bit data
                else        q_next = 4'd8;  //even parity +  7-bit data
                parity_bit = (~^data);        
            end
            endcase
            
            data_reg_next = {parity_bit,data};
        end
    end
    sending:
    begin
        if(q == 4'b0) dout_next = 1'b1;
        else   dout_next = data_reg[0];
        q_next = q - 4'b1;
        data_reg_next = data_reg >> 1;
    end
    
    endcase

end


assign dout = dout_reg;


endmodule