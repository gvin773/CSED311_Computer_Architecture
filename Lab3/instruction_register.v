module InstructionRegister #(parameter data_width = 32) ( 
    input reset, 
	input clk,
    input IRWrite,
    input [data_width - 1 : 0] mem_data,
       	output reg [data_width - 1: 0] IR);

always @(*) begin
    if(reset) IR <= 0;
    else if(IRWrite) IR <= mem_data;
end

endmodule
