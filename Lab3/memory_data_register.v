module MemoryDataRegister #(parameter data_width = 32) ( 
    input reset, 
	input clk,
    input [data_width - 1 : 0] mem_data,
       	output reg [data_width - 1: 0] MDR);

always @(*) begin
    if(reset) MDR <= 0;
    else MDR <= mem_data;
end

endmodule
