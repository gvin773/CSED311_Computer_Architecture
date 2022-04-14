module UpdateALUOut #(parameter data_width = 32) ( 
    input reset,
	input clk,
    input [data_width - 1 : 0] alu_result,
       	output reg [data_width - 1: 0] ALUOut);

always @(posedge clk) begin
    if(reset) ALUOut <= 0;
    else ALUOut <= alu_result;
end

endmodule
