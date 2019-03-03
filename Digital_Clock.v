module Digital_Clock  // This module uses the 1 HZ clock of the FPGA
(
    input clk,rst,
    output start_sending
);

// Segnal declaration
reg [25:0] q;

always @(posedge clk,posedge rst)
begin
    if(rst)
        q <= 26'b0;
    else
        q <= q + 26'b1;
end

assign start_sending = q[25];  // every 1 second


endmodule