module Digital_Clock  // This module uses the 1 HZ clock of the FPGA
(
    input clk,rst,
    output start_sending
);

// Segnal declaration
reg [3:0] q;

always @(posedge clk,posedge rst)
begin
    if(rst)
        q <= 4'b0;
    else
        q <= q + 4'b1;
end

assign start_sending = (q == 4'd15) ? 1'b1 : 1'b0; 


endmodule